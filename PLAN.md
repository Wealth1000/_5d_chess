# 5D Chess Game Logic Implementation Plan

## Overview

This plan outlines the implementation of core 5D Chess mechanics based on the Multiverse Chess reference implementation by L0laapk3. The game uses a turn-based system where players can make multiple moves before submitting, with timeline branching when moving to past boards. Implementation will be built incrementally, starting with basic chess mechanics and gradually adding time travel complexity.

## Architecture Principles

1. **Separation of Concerns**: Pure Dart logic in `game/logic/` (no Flutter dependencies), UI rendering in `game/rendering/`, state management in `game/state/`
2. **Variant-First Design**: Build variant system early to support different piece sets and rules
3. **Mutable State with Copy-on-Write**: Game state uses mutable objects for performance, but copies when needed for undo/redo
4. **Incremental Complexity**: Start with 2D chess, add time dimensions progressively
5. **Reference-Based Implementation**: Closely follow the JS reference for core mechanics to ensure correctness

## Key Concepts from Reference Implementation

### Position System (Vec4)
- **Vec4**: `(x, y, l, t)` where:
  - `x, y`: Spatial coordinates (0-7 for standard board)
  - `l`: Timeline index (negative for black side, positive for white side, 0 is main timeline)
  - `t`: Turn number within that timeline
- White pieces start at x=6,7; Black at x=0,1
- Turn alternates between players, and `present` is the minimum turn across all active timelines

### Timeline System
- Timelines are indexed by `l` (timeline number)
- Negative `l` = black player's timelines, positive `l` = white player's timelines
- Each timeline has `start` and `end` turn numbers
- Timeline `0` is the main timeline (starts at t=-1 with turn 0 board)
- When moving to an inactive board in the past, a new timeline branch is created
- Timeline activation: timelines activate when opponent creates a counter-timeline

### Move System
- **Physical Move**: Moves on the same board (same `l` and `t`)
- **Inter-dimensional Move**: Moves across timelines (different `l` or `t`)
- **Null Move**: Creates a new board without moving a piece (used for turn advancement)
- **Multiple Moves Per Turn**: Players can make multiple moves before submitting
- **Submit**: All moves must be submitted together, advancing the global turn
- **Present**: The minimum turn number across all active timelines - determines when turn ends

### Check/Checkmate
- Uses hypercuboid search algorithm for checkmate detection
- Check can occur across timelines (pieces can check kings in other timelines)
- Checkmate requires no legal moves across ALL timelines
- Worker thread/isolate recommended for checkmate checking (expensive operation)

---

## Phase 1: Core Data Structures (Foundation)

### 1.1 Position System (`lib/game/logic/position.dart`)

**Purpose**: Represent positions in 4D space (x, y, l, t)

**Key Components**:
- `Vec4` class:
  - `x: int` (0-7, rank)
  - `y: int` (0-7, file)
  - `l: int` (timeline index, negative=black, positive=white)
  - `t: int` (turn number in timeline)
  
**Key Methods**:
- `Vec4(x, y, l, t)` or `Vec4.fromVec4(Vec4)`
- `add(Vec4): Vec4`
- `sub(Vec4): Vec4`
- `equals(Vec4): bool`
- `isValid(): bool` (check bounds)

### 1.2 Piece Base Classes (`lib/game/logic/piece.dart`)

**Purpose**: Define chess pieces and movement patterns

**Key Components**:
- `BasePiece` abstract class:
  - `game: Game`
  - `board: Board`
  - `side: int` (0=black, 1=white)
  - `x: int, y: int` (position on board)
  - `type: String` (piece type name)
  - `hasMoved: bool` (for castling/pawn rules)
  
- `Piece` mixin/class:
  - `initType(String type): void`
  - `changePosition(Board, int x, int y, Board? sourceBoard, Piece? sourcePiece): void`
  - `cloneToBoard(Board): void`
  - `remove(): void`
  - `pos(): Vec4` (returns Vec4 position)
  - `enumerateMoves(int targetL?): List<Vec4>` (returns possible move positions)

**Piece Types** (created via factory pattern):
- `Pawn`, `Rook`, `Knight`, `Bishop`, `Queen`, `King`
- Each implements `enumerateMoves()` for their movement pattern

### 1.3 Board (`lib/game/logic/board.dart`)

**Purpose**: Represent a single 8x8 board at a specific timeline and turn

**Key Components**:
- `Board` class:
  - `game: Game`
  - `l: int` (timeline index)
  - `t: int` (turn number)
  - `turn: int` (0=black, 1=white)
  - `pieces: List<List<Piece?>>` (8x8 array, indexed as `pieces[x][y]`)
  - `active: bool` (whether board is currently being played on)
  - `deleted: bool` (whether board was removed)
  - `timeline: Timeline` (parent timeline)
  - `castleAvailable: int` (bitmask for castling rights)
  - `enPassantPawn: Piece?` (en passant target)
  - `imminentCheck: bool` (check status)
  
**Key Methods**:
- `Board(Game, int l, int t, int turn, Board? initialBoard, bool fastForward)`
- `Board.fromBoard(Board, bool isBranch, int? newL)` (clone constructor)
- `hasImminentChecks(): bool` (check if board has imminent checks)
- `makeInactive(): void`
- `makeActive(): void`
- `remove(): void` (removes board, returns animation callback)

### 1.4 Timeline (`lib/game/logic/timeline.dart`)

**Purpose**: Manage a sequence of boards in a timeline

**Key Components**:
- `Timeline` class:
  - `game: Game`
  - `l: int` (timeline index)
  - `start: int` (first turn number)
  - `end: int` (last turn number)
  - `side: int` (0=black if l<0, 1=white if l>=0)
  - `boards: List<Board>` (boards indexed by turn, accessed as `boards[t - start]`)
  
**Key Methods**:
- `Timeline(Game, int l, int t, int? sourceL, bool fastForward)`
- `getBoard(int t): Board?` (get board at turn t)
- `setBoard(int t, Board): void` (set board at turn t)
- `pop(): Board?` (remove last board, returns it)
- `remove(): void` (remove timeline from game)
- `activate(): void` / `deactivate(): void`
- `isSubmitReady(): bool` (check if timeline is ready for submit)

### 1.5 Move (`lib/game/logic/move.dart`)

**Purpose**: Represent a move with source, destination, and boards affected

**Key Components**:
- `Move` class:
  - `game: Game`
  - `sourceBoard: Board?` (board move starts from)
  - `targetBoard: Board?` (board move ends on)
  - `from: Vec4?` (source position)
  - `to: Vec4?` (destination position)
  - `isInterDimensionalMove: bool` (move across timelines)
  - `nullMove: bool` (no piece movement, just board creation)
  - `remoteMove: bool` (move from remote player)
  - `promote: int?` (pawn promotion: 1=Queen, 2=Knight, 3=Rook, 4=Bishop)
  - `usedBoards: List<Board>` (boards that become inactive)
  - `createdBoards: List<Board>` (boards created by this move)
  - `l: int?` (for null moves, which timeline)
  
**Key Methods**:
- `Move(Game, Piece? sourcePiece, Vec4? targetPos, int? promotionTo, bool remoteMove, bool fastForward)`
- `Move.nullMove(Game, Board)` (create null move)
- `undo(): void` (undo this move)
- `serialize(): Map<String, dynamic>` (serialize for network/undo)

### 1.6 Player (`lib/game/logic/player.dart`)

**Purpose**: Manage player state (time, clock)

**Key Components**:
- `Player` class:
  - `game: Game`
  - `side: int` (0=black, 1=white)
  - `timeRemaining: int` (milliseconds)
  - `timeRunning: bool`
  - `lastStartTime: double?` (performance timestamp)
  - `lastTurnTime: int` (time taken last turn)
  - `lastGrace: int` (grace period)
  - `lastIncr: int` (time increment)
  
**Key Methods**:
- `updateTime(int time, bool fromStop): int`
- `startTime(int? skipGraceAmount, int? skipAmount): void`
- `stopTime(bool fromFlag): int?`
- `startClock(int?, int?): void` / `stopClock(): void`
- `flag(bool fromStop): void`

---

## Phase 2: Basic Chess Mechanics (2D Foundation)

### 2.1 Piece Movement Patterns (`lib/game/logic/pieces/`)

**Purpose**: Implement movement rules for each piece type

**Files to Create**:
- `piece_factory.dart` - Factory to create piece types
- `pawn.dart` - Pawn movement (forward, capture, en-passant, promotion)
- `rook.dart` - Rook movement (horizontal/vertical)
- `knight.dart` - Knight movement (L-shape)
- `bishop.dart` - Bishop movement (diagonal)
- `queen.dart` - Queen movement (all directions)
- `king.dart` - King movement + castling

**Key Implementation Details**:
- Each piece's `enumerateMoves(int? targetL)` returns `List<Vec4>` of possible destinations
- For 2D moves: `targetL` is same as current board's `l`, `t` is current or next turn
- Must check for:
  - Piece blocking path
  - Own pieces blocking destination
  - Enemy pieces (can capture)
  - Board bounds
  - Special rules (castling, en-passant, promotion)

**Reference Implementation Notes**:
- Pieces store their position as `x, y` on the board
- `changePosition()` updates position and moves piece to new board if needed
- `cloneToBoard()` creates copy of piece on new board (for timeline branching)

### 2.2 Move Generation (`lib/game/logic/move_generator.dart`)

**Purpose**: Generate all legal moves for a piece

**Key Components**:
- `MoveGenerator` class:
  - `getMovesForPiece(Piece, int? targetL): List<Vec4>`
  - Filters moves based on:
    - Board bounds
    - Friendly pieces blocking
    - Check constraints (would move leave king in check?)
  
**Implementation**:
- Call `piece.enumerateMoves(targetL)` to get raw moves
- Filter out moves that would leave king in check
- Return valid moves

### 2.3 Check Detection (`lib/game/logic/check_detector.dart`)

**Purpose**: Detect check and checkmate conditions

**Key Components**:
- `CheckDetector` class:
  - `isSquareAttacked(Board, int x, int y, int attackingSide, int? targetL): bool`
  - `isKingInCheck(Board, int side): bool`
  - `findChecks(Game): bool` (find all checks, returns true if any found)

**Implementation**:
- For each enemy piece, check if it can attack king's square
- Must check across timelines (pieces in other timelines can check)
- Store check information for UI display (arrows, highlights)

### 2.4 Board Initialization (`lib/game/logic/board_setup.dart`)

**Purpose**: Set up initial board state

**Key Components**:
- `BoardSetup` class:
  - `createInitialBoard(Game, int l, int t, int turn, Variant): Board`
  - Standard setup: pieces in starting positions
  - Variant support: different piece arrangements

---

## Phase 3: Game State Management

### 3.1 Game Class (`lib/game/logic/game.dart`)

**Purpose**: Main game state manager (core of the game)

**Key Components**:
- `Game` class:
  - `options: GameOptions` (game settings, time controls, variant)
  - `turn: int` (0=black, 1=white)
  - `present: int` (current turn, minimum across all active timelines)
  - `timelines: List<List<Timeline>>` (array of 2 arrays: negative and positive timelines)
  - `timelineCount: List<int>` (count of timelines for each side: [black, white])
  - `lastTimelineCount: List<int>` (previous count for animation)
  - `currentTurnMoves: List<Move>` (moves made this turn, not yet submitted)
  - `canSubmit: bool` (whether moves can be submitted)
  - `finished: bool` (game over flag)
  - `timeRemaining: List<int>` (time for each player in milliseconds)
  - `displayedChecks: List<List<Vec4>>` (check arrows to display)
  - `localPlayer: List<bool>` (which players are local: [black, white])
  - `players: List<Player>` (player objects)
  - `Pieces: Map<String, Type>` (piece type classes)
  
**Key Methods**:
- `Game(GameOptions options, List<bool> localPlayer)`
- `getTimeline(int l): Timeline` (get timeline by index)
- `getPiece(Vec4 pos, int? incrBoardNum): Piece?` (get piece at position)
- `instantiateMove(Piece, Vec4, int?, bool, bool): Move` (factory method)
- `instantiateTimeline(int l, int t, int? sourceL, bool): Timeline` (factory method)
- `instantiateBoard(int l, int t, int turn, Board? initialBoard, bool): Board` (factory method)
- `instantiatePlayer(int side): Player` (factory method)
- `instantiatePieceTypes(): void` (setup piece classes)
- `movePresent(bool fastForward): void` (update present to minimum end turn)
- `findChecks(): bool` (find and store all checks)
- `checkSubmitAvailable(): bool` (check if moves can be submitted)
- `submit(bool remote, bool fastForward, bool skipTime): Map<String, dynamic>` (submit moves, advance turn)
- `move(Piece sourcePiece, Vec4 targetPos, int? promotionTo): bool` (make a move)
- `applyMove(Move, bool fastForward): void` (apply move to game state)
- `executeMove(String action, List<Move>, int timeTaken, bool fastForward): List<Move>` (execute moves, handle remote)
- `undo(): void` (undo last move)
- `end(int winner, int cause, String reason, bool inPast): void` (end game)
- `destroy(): void` (cleanup)

**Critical Logic**:
1. **Present Calculation**: `present` is the minimum `end` turn across all active timelines
2. **Submit Conditions**: 
   - `present % 2 == turn` (present must match player's turn)
   - All active timelines must have `end >= present`
   - No immediate checks on boards being submitted
3. **Timeline Branching**: When moving to inactive board in past, create new timeline
4. **Turn Advancement**: After submit, `turn = 1 - turn`, `present` advances

### 3.2 Game Options (`lib/game/logic/game_options.dart`)

**Purpose**: Store game configuration

**Key Components**:
- `GameOptions` class:
  - `time: TimeControl` (time settings)
  - `players: List<PlayerInfo>` (player information)
  - `variant: String` (variant name)
  - `public: bool` (public/private game)
  - `finished: bool` (game over)
  - `winner: int?` (winner side)
  - `winCause: int?` (cause side)
  - `winReason: String?` (reason: checkmate, stalemate, resign, timeout, draw)
  - `moves: List<List<Move>>?` (move history for replay)
  - `runningClocks: bool` (whether clocks are running)
  - `runningClockGraceTime: int?`
  - `runningClockTime: int?`

- `TimeControl` class:
  - `start: List<int>` (starting time for each player: [black, white])
  - `incr: int?` (increment per move)
  - `incrScale: int?` (scaling increment for new timelines)
  - `grace: int?` (grace period)
  - `graceScale: int?` (scaling grace for new timelines)

---

## Phase 4: Time Travel Mechanics

### 4.1 Inter-Dimensional Moves (`lib/game/logic/time_travel.dart`)

**Purpose**: Handle moves across timelines and time

**Key Concepts**:
- **Physical Move**: `from.l == to.l && from.t == to.t` (same board) or `from.l == to.l && to.t == from.t + 1` (next turn same timeline)
- **Time Travel Move**: `from.l != to.l` or `from.t != to.t` (different timeline or turn)
- **Timeline Branching**: Moving to inactive board in past creates new timeline
- **Active Board**: Board where `t == timeline.end` and timeline is active
- **Inactive Board**: Board in the past (`t < timeline.end`) or future

**Implementation**:
- In `Move` constructor:
  1. Check if target board exists and is active
  2. If inactive board: create timeline branch
  3. If active board but different timeline: move across timelines
  4. If same board: normal move
- Timeline branching:
  - Create new timeline with `l = ++timelineCount[targetBoard.turn] * (targetBoard.turn ? 1 : -1)`
  - New timeline starts at `t = targetBoard.t + 1`
  - Source board becomes inactive
  - New board created on new timeline

### 4.2 Present Management (`lib/game/logic/present.dart`)

**Purpose**: Manage the "present" turn across all timelines

**Key Logic**:
- `present` = minimum `end` turn across all active timelines
- Active timelines: `-min(timelineCount[0], timelineCount[1] + 1)` to `min(timelineCount[0] + 1, timelineCount[1])`
- After submit: `present` advances to next turn
- Turn alternates: even `present` = white, odd `present` = black

**Implementation**:
```dart
void movePresent(bool fastForward) {
  present = double.infinity;
  int minL = -math.min(timelineCount[0], timelineCount[1] + 1);
  int maxL = math.min(timelineCount[0] + 1, timelineCount[1]);
  for (int l = minL; l <= maxL; l++) {
    Timeline timeline = getTimeline(l);
    int t = math.max(timeline.end, timeline.start);
    if (t < present) {
      present = t;
    }
  }
}
```

### 4.3 Check Across Timelines (`lib/game/logic/cross_timeline_check.dart`)

**Purpose**: Detect checks that span multiple timelines

**Key Implementation**:
- When checking for check, must check pieces from ALL timelines
- Piece in timeline A can check king in timeline B
- `hasImminentChecks()` checks:
  - Current board's turn matches
  - For each enemy piece in any timeline, can it attack king?
  - Store check information for UI (arrows between timelines)

---

## Phase 5: Variant System

### 5.1 Variant Interface (`lib/game/logic/variants/variant.dart`)

**Purpose**: Define variant rules and piece sets

**Key Components**:
- `Variant` abstract class:
  - `name: String`
  - `getPieceSet(): PieceSet` (which pieces are available)
  - `createInitialBoard(Game, int l, int t, int turn): Board` (initial setup)
  - `getPieceFactory(): PieceFactory` (custom piece creation if needed)

### 5.2 Piece Set (`lib/game/logic/variants/piece_set.dart`)

**Purpose**: Define available pieces for a variant

**Key Components**:
- `PieceSet` class:
  - `availablePieces: List<String>` (piece type names)
  - `hasPiece(String type): bool`
  - `getStartingPieces(int side): List<PieceInfo>` (starting positions)

### 5.3 Variant Implementations (`lib/game/logic/variants/`)

**Files to Create**:
- `standard_variant.dart`: Standard 5D Chess (all pieces)
- `no_bishops_variant.dart`: No bishops
- `no_knights_variant.dart`: No knights
- `no_rooks_variant.dart`: No rooks
- `no_queens_variant.dart`: No queens
- `knights_vs_bishops_variant.dart`: Custom piece set
- `random_variant.dart`: Random piece placement
- `simple_variant.dart`: Simplified piece set

**Implementation Pattern**:
```dart
class StandardVariant extends Variant {
  @override
  String get name => 'Standard';
  
  @override
  Board createInitialBoard(Game game, int l, int t, int turn) {
    Board board = Board(game, l, t, turn, null, false);
    // Setup pieces...
    return board;
  }
}
```

### 5.4 Variant Factory (`lib/game/logic/variants/variant_factory.dart`)

**Purpose**: Create variant instances

**Key Components**:
- `VariantFactory` class:
  - `createVariant(String name): Variant`
  - `getAvailableVariants(): List<String>`
  - `getVariantDescription(String name): String`

---

## Phase 6: Checkmate Detection (Hypercuboid Algorithm)

### 6.1 Hypercuboid Search (`lib/game/logic/checkmate/hypercuboid.dart`)

**Purpose**: Implement checkmate detection using hypercuboid search

**Key Concepts** (from `hcuboid.js`):
- **Hypercuboid**: Multi-dimensional space representing all possible move combinations
- **Point**: A specific combination of moves (one move per timeline)
- **Slice**: A subset of the hypercuboid to remove invalid combinations
- **Problem**: A reason why a point is invalid (check, paradox, order inconsistency)

**Key Components**:
- `HypercuboidSearch` class:
  - `search(GameState): Generator<MoveCombination>` (generator for move combinations)
  - `buildHypercuboids(GameState): (Map, List)` (build search space)
  - `takePoint(Map): Map?` (extract valid point from hypercuboid)
  - `findProblem(GameState, Map, Map): Map?` (find why point is invalid)
  - `removeSlice(Map, Map): List<Map>` (remove invalid slice)
  - `removePoint(Map, Map): List<Map>` (remove invalid point)

**Implementation Notes**:
- This is complex and can be expensive
- Should run in isolate/worker thread
- Returns generator to allow incremental checking
- Can yield `false` (invalid) or `MoveCombination` (valid escape)

### 6.2 Checkmate Worker (`lib/game/logic/checkmate/checkmate_worker.dart`)

**Purpose**: Run checkmate detection in background

**Key Components**:
- `CheckmateWorker` class (runs in isolate):
  - `startMateSearch(GameState): void`
  - `stopMateSearch(): void`
  - `searchMate(): Generator<bool>` (yields false if checking, true if checkmate found)
  
**Usage**:
- Game sends current state to worker
- Worker runs hypercuboid search
- Worker sends result back: `true` = checkmate, `false` = has escape

---

## Phase 7: Rendering System

### 7.1 Board Painter (`lib/game/rendering/board_painter.dart`)

**Purpose**: Draw 8x8 chess board with pieces

**Key Components**:
- `BoardPainter` extends `CustomPainter`:
  - `board: Board`
  - `selectedSquare: Vec4?`
  - `legalMoves: List<Vec4>`
  - `highlights: List<Highlight>`
  - `arrows: List<Arrow>`
  
**Key Methods**:
- `paint(Canvas canvas, Size size)`
- `drawBoard(Canvas, Size)` (draw squares)
- `drawPieces(Canvas, Board)` (draw pieces)
- `drawHighlights(Canvas, List<Vec4>)` (selected, legal moves)
- `drawArrows(Canvas, List<Arrow>)` (time travel arrows, check arrows)

### 7.2 Piece Widget (`lib/game/rendering/piece_widget.dart`)

**Purpose**: Individual piece with drag support

**Key Components**:
- `PieceWidget` extends `StatefulWidget`:
  - `piece: Piece`
  - `position: Vec4`
  - `isDragging: bool`
  - `onDragStart()`, `onDragUpdate()`, `onDragEnd()`

### 7.3 Timeline View (`lib/game/rendering/timeline_view.dart`)

**Purpose**: Display timeline with boards

**Key Components**:
- `TimelineView` widget:
  - `timeline: Timeline`
  - `selectedTurn: int`
  - `onBoardSelected(int turn)`
  - Horizontal scrollable list of boards
  - Present indicator
  - Turn navigator

### 7.4 Game Scene (`lib/game/rendering/game_scene.dart`)

**Purpose**: Main game rendering container

**Key Components**:
- `GameScene` widget:
  - `game: Game`
  - `selectedPiece: Piece?`
  - `legalMoves: List<Vec4>`
  - Handles:
    - Pan/zoom gestures
    - Piece selection
    - Move making
    - Timeline navigation

**Layout**:
- Vertical: timelines stacked
- Horizontal: boards in timeline (left to right = past to present)
- Present marker: vertical line showing current turn
- Zoom/pan: allow navigation of large timeline spaces

---

## Phase 8: State Management

### 8.1 Game Provider (`lib/game/state/game_provider.dart`)

**Purpose**: Bridge game logic to UI

**Key Components**:
- `GameProvider` extends `ChangeNotifier`:
  - `game: Game`
  - `selectedPiece: Piece?`
  - `legalMoves: List<Vec4>`
  - `hoveredPiece: Piece?`
  - `ghostPiece: Piece?` (drag preview)
  
**Key Methods**:
- `selectPiece(Piece): void`
- `deselectPiece(): void`
- `makeMove(Piece, Vec4, int? promotion): bool`
- `undoMove(): void`
- `submitMoves(): void`
- `newGame(Variant, TimeControl): void`

### 8.2 Game State Model (`lib/game/state/game_state_model.dart`)

**Purpose**: Serializable game state

**Key Components**:
- `GameStateModel` class:
  - `toJson(): Map<String, dynamic>`
  - `fromJson(Map<String, dynamic>): GameStateModel`
  - Save/load functionality

---

## Phase 9: UI Integration

### 9.1 Game Screen (`lib/ui/screens/game_screen.dart`)

**Purpose**: Main game playing interface

**Key Components**:
- `GameScreen` widget:
  - `GameProvider` integration
  - `GameScene` for board rendering
  - Timeline selector/navigator
  - Move history panel
  - Game status display
  - Undo/submit buttons
  - Time displays
  - Promotion selector

### 9.2 New Game Integration

**Purpose**: Connect variant selection to game start

**Key Changes to `new_game_screen.dart`:
- Update `Play` button to:
  1. Get selected variant from `VariantFactory`
  2. Create `GameOptions` with variant and time controls
  3. Initialize `GameProvider` with options
  4. Navigate to `GameScreen`

---

## Implementation Order (Detailed Steps)

### Step 1: Core Data Structures (Week 1)

1. **Day 1-2: Position System**
   - Create `Vec4` class in `lib/game/logic/position.dart`
   - Implement methods: `add()`, `sub()`, `equals()`, `isValid()`
   - Write unit tests

2. **Day 3-4: Piece Base Classes**
   - Create `BasePiece` abstract class
   - Create `Piece` mixin with position management
   - Implement `changePosition()`, `cloneToBoard()`, `remove()`, `pos()`
   - Write unit tests

3. **Day 5: Move Class**
   - Create `Move` class in `lib/game/logic/move.dart`
   - Implement basic move structure (from, to, boards)
   - Implement `serialize()` and basic `undo()`
   - Write unit tests

### Step 2: Board and Timeline (Week 2)

1. **Day 1-2: Board Class**
   - Create `Board` class in `lib/game/logic/board.dart`
   - Implement 8x8 piece array
   - Implement board initialization (standard setup)
   - Implement `hasImminentChecks()` (basic version)
   - Write unit tests

2. **Day 3-4: Timeline Class**
   - Create `Timeline` class in `lib/game/logic/timeline.dart`
   - Implement board storage and retrieval
   - Implement `getBoard()`, `setBoard()`, `pop()`, `remove()`
   - Write unit tests

3. **Day 5: Basic Game Structure**
   - Create `Game` class skeleton
   - Implement timeline management (`getTimeline()`, timeline creation)
   - Implement basic `movePresent()`
   - Write integration tests

### Step 3: Piece Movement (Week 3)

1. **Day 1: Pawn**
   - Implement `Pawn` class
   - Movement: forward, capture, double move, en-passant, promotion
   - Write unit tests

2. **Day 2: Rook and Bishop**
   - Implement `Rook` class (horizontal/vertical)
   - Implement `Bishop` class (diagonal)
   - Write unit tests

3. **Day 3: Knight and Queen**
   - Implement `Knight` class (L-shape)
   - Implement `Queen` class (all directions)
   - Write unit tests

4. **Day 4: King**
   - Implement `King` class
   - Add castling logic
   - Write unit tests

5. **Day 5: Piece Factory**
   - Create `PieceFactory` to instantiate pieces
   - Test all pieces together
   - Integration test with board

### Step 4: Move System (Week 4)

1. **Day 1-2: Physical Moves**
   - Implement move creation for same-board moves
   - Implement piece capture
   - Implement pawn promotion
   - Test move application and undo

2. **Day 3-4: Inter-Dimensional Moves**
   - Implement timeline branching logic
   - Implement moves across timelines
   - Implement moves to past/future
   - Test timeline creation

3. **Day 5: Move Submission**
   - Implement `submit()` logic
   - Implement `checkSubmitAvailable()`
   - Implement turn advancement
   - Test full turn cycle

### Step 5: Check System (Week 5)

1. **Day 1-2: Check Detection**
   - Implement `isSquareAttacked()`
   - Implement `isKingInCheck()`
   - Implement `findChecks()` across timelines
   - Test check detection

2. **Day 3: Check Prevention**
   - Filter moves that leave king in check
   - Update move generation to respect check
   - Test illegal move filtering

3. **Day 4-5: Checkmate Basics**
   - Implement basic checkmate detection (brute force)
   - Test checkmate scenarios
   - Later: optimize with hypercuboid algorithm

### Step 6: Variant System (Week 6)

1. **Day 1: Variant Interface**
   - Create `Variant` abstract class
   - Create `PieceSet` class
   - Create `VariantFactory`

2. **Day 2: Standard Variant**
   - Implement `StandardVariant`
   - Test standard game setup

3. **Day 3-4: Simple Variants**
   - Implement `NoBishopsVariant`
   - Implement `NoKnightsVariant`
   - Implement `NoRooksVariant`
   - Implement `NoQueensVariant`
   - Test each variant

4. **Day 5: Custom Variants**
   - Implement `KnightsVsBishopsVariant`
   - Implement `RandomVariant`
   - Test variants

### Step 7: Rendering (Week 7)

1. **Day 1-2: Board Painter**
   - Create `BoardPainter` with `CustomPainter`
   - Draw chess board squares
   - Draw pieces
   - Test rendering

2. **Day 3: Highlights and Arrows**
   - Implement move highlights
   - Implement check arrows
   - Implement time travel arrows
   - Test visual feedback

3. **Day 4: Timeline View**
   - Create `TimelineView` widget
   - Display multiple boards horizontally
   - Implement scrolling
   - Test timeline navigation

4. **Day 5: Game Scene**
   - Create `GameScene` container
   - Integrate board painter and timeline view
   - Implement pan/zoom
   - Test full rendering

### Step 8: Interaction (Week 8)

1. **Day 1-2: Piece Selection**
   - Implement piece tap selection
   - Show legal moves
   - Implement piece deselection
   - Test selection logic

2. **Day 3: Move Making**
   - Implement move on tap
   - Implement drag and drop
   - Handle promotion selection
   - Test move making

3. **Day 4: Undo/Redo**
   - Implement undo functionality
   - Update UI on undo
   - Test undo/redo

4. **Day 5: Submit System**
   - Implement submit button
   - Show submit availability
   - Handle submit logic
   - Test submit flow

### Step 9: Game Provider (Week 9)

1. **Day 1-2: Provider Setup**
   - Create `GameProvider` with `ChangeNotifier`
   - Connect to `Game` class
   - Implement state updates
   - Test provider

2. **Day 3: UI Integration**
   - Connect `GameScreen` to `GameProvider`
   - Update UI on state changes
   - Test reactive updates

3. **Day 4: Game Lifecycle**
   - Implement new game
   - Implement game end detection
   - Handle game over UI
   - Test full game flow

4. **Day 5: Polish**
   - Add animations
   - Improve UX
   - Fix bugs
   - Test thoroughly

### Step 10: Integration (Week 10)

1. **Day 1: New Game Screen**
   - Connect variant selection to game start
   - Pass time controls to game
   - Test game creation

2. **Day 2-3: Game Screen Polish**
   - Add time displays
   - Add move history
   - Add game status
   - Test full UI

3. **Day 4-5: Testing**
   - Test all variants
   - Test time travel moves
   - Test edge cases
   - Fix bugs

### Step 11: Advanced Features (Week 11+)

1. **Hypercuboid Algorithm** (if time permits)
   - Implement hypercuboid search
   - Create checkmate worker
   - Optimize checkmate detection

2. **Performance Optimization**
   - Profile and optimize
   - Cache move calculations
   - Optimize rendering

3. **Additional Features**
   - Save/load games
   - Move notation
   - Game replay
   - AI opponent (future)

---

## Key Files to Create

### Core Logic (`lib/game/logic/`)
- `position.dart` - Vec4 position system
- `piece.dart` - BasePiece and Piece classes
- `pieces/piece_factory.dart` - Piece creation
- `pieces/pawn.dart` - Pawn implementation
- `pieces/rook.dart` - Rook implementation
- `pieces/knight.dart` - Knight implementation
- `pieces/bishop.dart` - Bishop implementation
- `pieces/queen.dart` - Queen implementation
- `pieces/king.dart` - King implementation
- `board.dart` - Board class
- `timeline.dart` - Timeline class
- `move.dart` - Move class
- `player.dart` - Player class
- `game.dart` - Main Game class
- `game_options.dart` - GameOptions and TimeControl
- `check_detector.dart` - Check detection
- `move_generator.dart` - Move generation
- `board_setup.dart` - Board initialization
- `variants/variant.dart` - Variant interface
- `variants/piece_set.dart` - PieceSet class
- `variants/variant_factory.dart` - Variant factory
- `variants/standard_variant.dart` - Standard variant
- `variants/no_bishops_variant.dart` - No bishops variant
- `variants/no_knights_variant.dart` - No knights variant
- `variants/no_rooks_variant.dart` - No rooks variant
- `variants/no_queens_variant.dart` - No queens variant
- `variants/knights_vs_bishops_variant.dart` - Custom variant
- `variants/random_variant.dart` - Random variant
- `checkmate/hypercuboid.dart` - Hypercuboid search (advanced)
- `checkmate/checkmate_worker.dart` - Checkmate worker (advanced)

### Rendering (`lib/game/rendering/`)
- `board_painter.dart` - Board CustomPainter
- `piece_widget.dart` - Piece widget
- `timeline_view.dart` - Timeline display
- `game_scene.dart` - Game container

### State Management (`lib/game/state/`)
- `game_provider.dart` - GameProvider
- `game_state_model.dart` - Serializable state

### UI (`lib/ui/screens/`)
- `game_screen.dart` - Main game screen

---

## Testing Strategy

### Unit Tests
- Test each piece's movement
- Test board operations
- Test timeline management
- Test move creation and undo
- Test check detection
- Test variant setups

### Integration Tests
- Test full game flow
- Test time travel moves
- Test timeline branching
- Test move submission
- Test checkmate detection
- Test variant switching

### Manual Testing
- Playtest each variant
- Test on different screen sizes
- Test touch interactions
- Test performance with many timelines
- Test edge cases

---

## Critical Implementation Details

### Timeline Indexing
- Timeline `l = 0` is the main timeline (starts at t=-1)
- Negative `l` = black player's timelines
- Positive `l` = white player's timelines
- Timeline count: `timelineCount[0]` = black, `timelineCount[1]` = white
- New timeline: `l = ++timelineCount[side] * (side ? 1 : -1)`

### Present Calculation
- `present` = minimum `end` turn across active timelines
- Active timelines: `-min(timelineCount[0], timelineCount[1] + 1)` to `min(timelineCount[0] + 1, timelineCount[1])`
- Turn alternates: `present % 2 == 0` = white, `present % 2 == 1` = black

### Move Submission
- Player can make multiple moves before submitting
- Submit available when:
  - `present % 2 == turn` (present matches player's turn)
  - All active timelines have `end >= present`
  - No immediate checks on boards being submitted
- After submit: `turn = 1 - turn`, `present` advances

### Timeline Branching
- Moving to inactive board creates timeline branch
- Inactive board: `t < timeline.end` (board in the past)
- New timeline starts at `t = targetBoard.t + 1`
- Source board becomes inactive
- New board created on new timeline with piece moved

### Check Detection
- Check can occur across timelines
- Piece in timeline A can check king in timeline B
- Must check all enemy pieces in all timelines
- Store check information for UI (arrows, highlights)

---

## Performance Considerations

### Optimization Strategies
- Cache legal move calculations
- Limit timeline depth (archive old boards)
- Lazy load timeline boards (only render visible)
- Use isolates for expensive operations (checkmate)
- Optimize rendering (only redraw changed areas)

### Memory Management
- Archive old timeline boards (keep last N turns)
- Clear move history after game end
- Implement game state compression for save/load

---

## User Experience Features

### Visual Feedback
- Highlight selected piece
- Show legal moves
- Show check indicators (arrows, board highlights)
- Show time travel arrows
- Animate piece movement
- Animate board creation/removal

### Interaction
- Tap to select piece
- Tap to make move
- Drag and drop pieces
- Pan/zoom timeline view
- Timeline navigation (scroll, jump to turn)
- Undo/redo moves

### Information Display
- Current turn indicator
- Present marker
- Time remaining for each player
- Move history
- Game status (check, checkmate, stalemate)
- Variant name

---

## Future Enhancements

### Phase 12+: Advanced Features
- AI opponent
- Online multiplayer
- Game replay with move-by-move navigation
- Move notation (algebraic + time travel notation)
- Puzzle mode
- Tutorial mode
- Analysis mode
- Export/import games

---

## Resources & References

1. **Multiverse Chess by L0laapk3**: 
   - GitHub: https://github.com/L0laapk3/multiverse-chess
   - Reference implementation in JavaScript
   - Key files: `game.js`, `client.js`, `hcuboid.js`, `gameCheckmate.js`

2. **5D Chess with Multiverse Time Travel**: 
   - Original game by Thunkspace
   - Official rules and mechanics

3. **Chess Programming Wiki**: 
   - Standard chess logic reference
   - Move generation techniques
   - Check detection algorithms

4. **Flutter Documentation**:
   - CustomPainter for rendering
   - Gesture detection
   - State management (Provider/ChangeNotifier)

---

## Next Steps

1. **Start with Step 1**: Create core data structures (Vec4, Piece, Move)
2. **Write tests as you go**: Each component should have unit tests
3. **Build incrementally**: 2D → Timeline → Time Travel → Variants → Rendering
4. **Test each phase**: Don't move to next phase until current works
5. **Refactor as needed**: As complexity grows, refactor for maintainability
6. **Reference JS code**: When stuck, check JS reference implementation
7. **Iterate on UX**: Polish UI/UX as you build

This plan provides a comprehensive roadmap from basic data structures to full 5D Chess with variant support. Each phase builds on the previous one, making the implementation manageable and testable. The reference implementation provides crucial insights into the complex mechanics of timeline branching, present management, and checkmate detection.

