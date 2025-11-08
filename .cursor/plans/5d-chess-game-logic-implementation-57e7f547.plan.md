<!-- 57e7f547-d873-4142-bb19-629a3414e22f df7e7180-e42e-4213-a56c-1712930127e8 -->
# 5D Chess Game Logic Implementation Plan

## Overview

This plan outlines the implementation of core 5D Chess mechanics based on the Multiverse Chess reference implementation. The game uses a turn-based system where players can make multiple moves before submitting, with timeline branching when moving to past boards. Implementation will be built incrementally, starting with basic chess mechanics and gradually adding time travel complexity.

## Architecture Principles

1. **Separation of Concerns**: Pure Dart logic in `game/logic/` (no Flutter dependencies), UI rendering in `game/rendering/`, state management in `game/state/`
2. **Variant-First Design**: Build variant system early to support different piece sets and rules
3. **Mutable State with Copy-on-Write**: Game state uses mutable objects for performance, but copies when needed for undo/redo
4. **Incremental Complexity**: Start with 2D chess, add time dimensions progressively
5. **Reference-Based Implementation**: Closely follow the JS reference for core mechanics to ensure correctness

---

## Phase 1: Core Data Structures (Foundation)

### 1.1 Piece Representation (`lib/game/logic/piece.dart`)

**Purpose**: Define chess pieces and their properties

**Key Components**:

- `PieceType` enum: King, Queen, Rook, Bishop, Knight, Pawn
- `PieceColor` enum: White, Black
- `Piece` class with:
  - `type: PieceType`
  - `color: PieceColor`
  - `id: String` (unique identifier for time travel tracking)
  - `hasMoved: bool` (for castling/pawn double-move rules)

**Variant Support**:

- `PieceSet` class to define available pieces per variant
- `VariantPieceSet` enum mapping to piece configurations

### 1.2 Position System (`lib/game/logic/position.dart`)

**Purpose**: Represent positions in 2D space and time

**Key Components**:

- `Position2D` class: `{x: int, y: int}` (0-7 for standard board)
- `Position5D` class: 
  - `position: Position2D` (spatial coordinates)
  - `timeline: int` (which timeline/board)
  - `turn: int` (turn number in that timeline)

**Key Methods**:

- `isValid()`: Check if position is within board bounds
- `equals()`: Compare positions
- `distance()`: Calculate Manhattan/Chebyshev distance

### 1.3 Move Representation (`lib/game/logic/move.dart`)

**Purpose**: Represent a move with source, destination, and time travel info

**Key Components**:

- `Move` class:
  - `from: Position5D`
  - `to: Position5D`
  - `piece: Piece`
  - `capturedPiece: Piece?`
  - `isTimeTravel: bool`
  - `timelineSplit: bool` (creates new timeline)
  - `promotion: PieceType?` (pawn promotion)
  - `moveType: MoveType` (normal, castling, en-passant, time-travel)

### 1.4 Board State (`lib/game/logic/board_state.dart`)

**Purpose**: Represent a single 8x8 board at a specific turn

**Key Components**:

- `BoardState` class:
  - `pieces: Map<Position2D, Piece>` (current piece positions)
  - `turn: int` (turn number in this timeline)
  - `whiteKingPosition: Position2D`
  - `blackKingPosition: Position2D`
  - `enPassantTarget: Position2D?`
  - `castlingRights: Map<PieceColor, CastlingRights>`

**Key Methods**:

- `getPiece(Position2D): Piece?`
- `setPiece(Position2D, Piece?)`
- `isSquareAttacked(Position2D, PieceColor): bool`
- `isKingInCheck(PieceColor): bool`
- `copy()`: Create immutable copy

---

## Phase 2: Basic Chess Mechanics (2D Foundation)

### 2.1 Piece Movement Rules (`lib/game/logic/piece_moves.dart`)

**Purpose**: Calculate legal moves for each piece type in 2D space

**Key Components**:

- `MoveGenerator` class with methods:
  - `getMovesForPiece(Piece, Position2D, BoardState): List<Move>`
  - `getKingMoves()`, `getQueenMoves()`, `getRookMoves()`, etc.
  - `getPawnMoves()` (handles double-move, en-passant, promotion)
  - `getCastlingMoves()` (kingside/queenside)

**Variant Support**:

- `VariantMoveGenerator` interface
- Different generators for different variants (e.g., no-bishops variant)

### 2.2 Move Validation (`lib/game/logic/move_validator.dart`)

**Purpose**: Validate moves and ensure they don't leave king in check

**Key Components**:

- `MoveValidator` class:
  - `isLegalMove(Move, BoardState): bool`
  - `wouldLeaveKingInCheck(Move, BoardState): bool`
  - `getAllLegalMoves(BoardState, PieceColor): List<Move>`
  - `isCheckmate(BoardState, PieceColor): bool`
  - `isStalemate(BoardState, PieceColor): bool`

### 2.3 Game State (Single Timeline) (`lib/game/logic/game_state_2d.dart`)

**Purpose**: Manage game state for standard 2D chess (foundation for 5D)

**Key Components**:

- `GameState2D` class:
  - `currentBoard: BoardState`
  - `currentPlayer: PieceColor`
  - `moveHistory: List<Move>`
  - `gameStatus: GameStatus` (playing, checkmate, stalemate, draw)

**Key Methods**:

- `makeMove(Move): GameState2D` (returns new state)
- `undoMove(): GameState2D`
- `isGameOver(): bool`

---

## Phase 3: Time Travel Mechanics (5D Core)

### 3.1 Timeline System (`lib/game/logic/timeline.dart`)

**Purpose**: Manage multiple timelines and their relationships

**Key Components**:

- `Timeline` class:
  - `id: int` (unique timeline identifier)
  - `parentTimelineId: int?` (which timeline it branched from)
  - `branchTurn: int` (turn number when branch occurred)
  - `boards: List<BoardState>` (history of boards in this timeline)
  - `isActive: bool` (whether timeline is still being played)

**Key Methods**:

- `getBoardAtTurn(int): BoardState?`
- `addBoard(BoardState): void`
- `getCurrentBoard(): BoardState`
- `splitTimeline(int): Timeline` (create new timeline branch)

### 3.2 Time Travel Move Logic (`lib/game/logic/time_travel_moves.dart`)

**Purpose**: Calculate and validate time-traveling moves

**Key Concepts**:

- **Hypermove**: Piece moves through time to same spatial position in past/future
- **Paradox**: Moving to past where piece already exists
- **Timeline Split**: Moving to past creates new timeline branch

**Key Components**:

- `TimeTravelMoveGenerator` class:
  - `getHyperMoves(Piece, Position5D, TimelineManager): List<Move>`
  - `canTimeTravelTo(Position5D, TimelineManager): bool`
  - `wouldCreateParadox(Move, TimelineManager): bool`
  - `createTimelineBranch(Move, Timeline): Timeline`

**Rules to Implement**:

1. Pieces can move to same square in past/future timelines
2. Moving to past creates timeline branch (unless moving to original timeline)
3. Cannot create paradox (two pieces of same type/color on same square)
4. Captured pieces in past affect all future timelines

### 3.3 Timeline Manager (`lib/game/logic/timeline_manager.dart`)

**Purpose**: Manage all timelines and their relationships

**Key Components**:

- `TimelineManager` class:
  - `timelines: Map<int, Timeline>`
  - `activeTimelines: List<int>`
  - `currentTimelineId: int`
  - `globalTurn: int` (overall game turn counter)

**Key Methods**:

- `getTimeline(int): Timeline?`
- `addTimeline(Timeline): void`
- `splitTimeline(int, int): Timeline` (split at specific turn)
- `getAllBoardsAtTurn(int): List<BoardState>` (all timelines at turn)
- `propagateCapture(Piece, Position5D): void` (remove piece from all futures)

### 3.4 5D Game State (`lib/game/logic/game_state_5d.dart`)

**Purpose**: Full 5D chess game state management

**Key Components**:

- `GameState5D` class:
  - `timelineManager: TimelineManager`
  - `currentPlayer: PieceColor`
  - `globalTurn: int`
  - `moveHistory: List<Move>` (with timeline context)
  - `gameStatus: GameStatus`

**Key Methods**:

- `makeMove(Move): GameState5D`
- `getAllLegalMoves(PieceColor): List<Move>` (across all timelines)
- `isCheckmate(PieceColor): bool` (king in check in all timelines)
- `getActiveTimelines(): List<Timeline>`

---

## Phase 4: Variant System Architecture

### 4.1 Variant Definition (`lib/game/logic/variants/variant.dart`)

**Purpose**: Define variant rules and configurations

**Key Components**:

- `Variant` abstract class:
  - `name: String`
  - `pieceSet: PieceSet`
  - `initialBoardSetup(): BoardState`
  - `getMoveGenerator(): MoveGenerator`
  - `getMoveValidator(): MoveValidator`
  - `specialRules: List<SpecialRule>`

### 4.2 Variant Implementations (`lib/game/logic/variants/`)

**Purpose**: Implement specific variants

**Files to Create**:

- `standard_variant.dart`: Standard 5D Chess
- `simple_variants.dart`: No-Bishops, No-Knights, etc.
- `random_variant.dart`: Random piece placement
- `knights_vs_bishops_variant.dart`: Custom piece sets

**Example Structure**:

```dart
class StandardVariant extends Variant {
  @override
  PieceSet get pieceSet => StandardPieceSet();
  
  @override
  BoardState initialBoardSetup() {
    // Standard chess starting position
  }
}

class NoBishopsVariant extends Variant {
  @override
  PieceSet get pieceSet => NoBishopsPieceSet(); // Excludes bishops
  
  @override
  BoardState initialBoardSetup() {
    // Standard setup without bishops
  }
}
```

### 4.3 Variant Factory (`lib/game/logic/variants/variant_factory.dart`)

**Purpose**: Create variant instances from string names

**Key Components**:

- `VariantFactory` class:
  - `createVariant(String name): Variant`
  - `getAvailableVariants(): List<String>`
  - `getVariantDescription(String name): String`

---

## Phase 5: Rendering System

### 5.1 Board Painter (`lib/game/rendering/board_painter.dart`)

**Purpose**: Draw 8x8 chess board with pieces

**Key Components**:

- `BoardPainter` class extending `CustomPainter`:
  - `drawBoard(Canvas, Size)`
  - `drawPieces(Canvas, BoardState)`
  - `drawHighlights(Canvas, List<Position2D>)` (selected square, legal moves)
  - `drawTimeTravelArrows(Canvas, List<Move>)` (visualize time travel)

### 5.2 Timeline View (`lib/game/rendering/timeline_view.dart`)

**Purpose**: Display multiple timelines (horizontally scrollable or tabbed)

**Key Components**:

- `TimelineView` widget:
  - `timelines: List<Timeline>`
  - `selectedTimelineId: int`
  - `onTimelineSelected(int): void`
  - Horizontal scrollable list of boards
  - Turn indicator/navigator

### 5.3 Game Scene (`lib/game/rendering/game_scene.dart`)

**Purpose**: Main game rendering container

**Key Components**:

- `GameScene` widget:
  - `gameState: GameState5D`
  - `selectedPiece: Position5D?`
  - `legalMoves: List<Move>`
  - Handles tap/drag gestures
  - Coordinates board painting and timeline views

### 5.4 Piece Widget (`lib/game/rendering/piece_widget.dart`)

**Purpose**: Individual piece rendering with drag support

**Key Components**:

- `PieceWidget` widget:
  - `piece: Piece`
  - `position: Position2D`
  - `isDragging: bool`
  - `onDragStart()`, `onDragUpdate()`, `onDragEnd()`

---

## Phase 6: State Management

### 6.1 Game State Provider (`lib/game/state/game_provider.dart`)

**Purpose**: Bridge game logic to UI using Provider/ChangeNotifier

**Key Components**:

- `GameProvider` extends `ChangeNotifier`:
  - `gameState: GameState5D`
  - `selectedPosition: Position5D?`
  - `legalMoves: List<Move>`
  - `variant: Variant`

**Key Methods**:

- `selectPiece(Position5D): void`
  - Updates selected position
  - Calculates legal moves
  - Notifies listeners

- `makeMove(Move): void`
  - Validates move
  - Updates game state
  - Updates UI
  - Checks game over conditions

- `newGame(Variant): void`
  - Initializes new game with variant
  - Resets state

- `undoMove(): void`
  - Reverts last move
  - Updates state

### 6.2 Game State Model (`lib/game/state/game_state_model.dart`)

**Purpose**: Serializable game state for save/load

**Key Components**:

- `GameStateModel` class:
  - JSON serialization
  - `toJson()`, `fromJson()`
  - Save/load game functionality

---

## Phase 7: UI Integration

### 7.1 Game Screen (`lib/ui/screens/game_screen.dart`)

**Purpose**: Main game playing interface

**Key Components**:

- `GameScreen` widget:
  - `GameProvider` integration
  - `TimelineView` for multiple boards
  - `GameScene` for board interaction
  - Move history panel
  - Game status display
  - Undo/redo buttons

### 7.2 New Game Integration (`lib/ui/screens/new_game_screen.dart`)

**Purpose**: Connect variant selection to game initialization

**Key Changes**:

- Update `_startGame()` method:
  - Get selected variant from `VariantFactory`
  - Initialize `GameProvider` with variant
  - Navigate to `GameScreen` with provider

---

## Implementation Order (Step-by-Step)

### Step 1: Basic Data Structures (Week 1)

1. Create `Piece`, `PieceType`, `PieceColor` in `lib/game/logic/piece.dart`
2. Create `Position2D`, `Position5D` in `lib/game/logic/position.dart`
3. Create `Move` class in `lib/game/logic/move.dart`
4. Create `BoardState` in `lib/game/logic/board_state.dart`
5. Write unit tests for each component

### Step 2: 2D Chess Logic (Week 2)

1. Implement `MoveGenerator` for all piece types
2. Implement `MoveValidator` with check detection
3. Create `GameState2D` for single-timeline play
4. Test with standard chess positions (checkmate, stalemate scenarios)

### Step 3: Variant Foundation (Week 3)

1. Create `Variant` abstract class
2. Implement `StandardVariant`
3. Implement `PieceSet` system
4. Create `VariantFactory`
5. Test variant switching

### Step 4: Time Travel Basics (Week 4)

1. Create `Timeline` class
2. Create `TimelineManager`
3. Implement basic timeline branching
4. Test timeline creation and navigation

### Step 5: Time Travel Moves (Week 5)

1. Implement `TimeTravelMoveGenerator`
2. Implement paradox detection
3. Implement timeline splitting on time travel
4. Test time travel move validation

### Step 6: 5D Game State (Week 6)

1. Create `GameState5D` class
2. Integrate timeline manager
3. Implement cross-timeline move validation
4. Implement checkmate across timelines
5. Test full 5D game flow

### Step 7: Additional Variants (Week 7)

1. Implement `NoBishopsVariant`
2. Implement `NoKnightsVariant`
3. Implement `RandomVariant`
4. Implement `KnightsVsBishopsVariant`
5. Test each variant thoroughly

### Step 8: Rendering (Week 8)

1. Create `BoardPainter` for single board
2. Create `PieceWidget` with drag support
3. Create `TimelineView` for multiple boards
4. Create `GameScene` container
5. Test rendering with different board states

### Step 9: State Management (Week 9)

1. Create `GameProvider` with ChangeNotifier
2. Integrate with game logic
3. Implement move making from UI
4. Implement undo/redo
5. Test state updates and UI responsiveness

### Step 10: UI Integration (Week 10)

1. Create `GameScreen` widget
2. Integrate `GameProvider`
3. Connect variant selection from `NewGameScreen`
4. Implement game over detection and display
5. Polish UI/UX

### Step 11: Testing & Refinement (Week 11+)

1. Write comprehensive unit tests
2. Test all variants
3. Test edge cases (paradox prevention, timeline branching)
4. Performance optimization
5. Bug fixes and refinements

---

## Key Files to Create

### Core Logic (`lib/game/logic/`)

- `piece.dart` - Piece representation
- `position.dart` - Position system (2D and 5D)
- `move.dart` - Move representation
- `board_state.dart` - Single board state
- `piece_moves.dart` - Move generation
- `move_validator.dart` - Move validation
- `game_state_2d.dart` - 2D chess game state
- `timeline.dart` - Timeline representation
- `timeline_manager.dart` - Timeline management
- `time_travel_moves.dart` - Time travel logic
- `game_state_5d.dart` - Full 5D game state
- `variants/variant.dart` - Variant interface
- `variants/variant_factory.dart` - Variant creation
- `variants/standard_variant.dart` - Standard variant
- `variants/simple_variants.dart` - Simple variants
- `variants/random_variant.dart` - Random variant

### Rendering (`lib/game/rendering/`)

- `board_painter.dart` - Board drawing
- `piece_widget.dart` - Piece widget
- `timeline_view.dart` - Timeline display
- `game_scene.dart` - Game container

### State Management (`lib/game/state/`)

- `game_provider.dart` - State provider
- `game_state_model.dart` - Serializable state

### UI (`lib/ui/screens/`)

- `game_screen.dart` - Main game screen (update existing)

---

## Testing Strategy

### Unit Tests

- Test each piece's move generation
- Test move validation (check detection, illegal moves)
- Test timeline branching logic
- Test paradox prevention
- Test variant piece sets

### Integration Tests

- Test full game flow (start to checkmate)
- Test time travel moves end-to-end
- Test variant switching
- Test undo/redo functionality

### Manual Testing

- Playtest each variant
- Test on different screen sizes
- Test touch/drag interactions
- Test performance with many timelines

---

## Considerations

### Performance

- Limit number of active timelines (e.g., max 10)
- Cache legal move calculations
- Optimize board state copying
- Lazy load timeline boards

### Memory Management

- Archive old timeline boards (keep last N turns)
- Implement game state compression
- Clear move history after game end

### User Experience

- Visual indicators for time travel moves
- Timeline navigation (scroll, jump to turn)
- Highlight legal moves
- Show check/checkmate status
- Move animation

### Future Enhancements

- AI opponent
- Online multiplayer
- Game replay/save
- Move notation (algebraic + time travel notation)
- Puzzle mode

---

## Resources & References

1. **Multiverse Chess by L0laapk3**: Reference implementation for rules and mechanics
2. **5D Chess with Multiverse Time Travel**: Original game rules
3. **Chess Programming Wiki**: For standard chess logic reference
4. **Flutter CustomPainter**: For board rendering

---

## Next Steps

1. Start with Step 1: Create basic data structures
2. Write tests as you go
3. Build incrementally: 2D → Variants → Time Travel → 5D
4. Test each phase before moving to next
5. Refactor as needed when adding complexity

This plan provides a clear roadmap from basic chess to full 5D Chess with variant support. Each phase builds on the previous one, making the implementation manageable and testable.

### To-dos

- [ ] Phase 1: Create core data structures (Piece, Position, Move, BoardState)
- [ ] Phase 2: Implement basic 2D chess mechanics (move generation, validation)
- [ ] Phase 3: Build variant system foundation (Variant interface, StandardVariant)
- [ ] Phase 4: Implement timeline system (Timeline, TimelineManager)
- [ ] Phase 5: Implement time travel mechanics (hyper moves, paradox detection, timeline splitting)
- [ ] Phase 6: Create 5D game state (GameState5D, cross-timeline validation)
- [ ] Phase 7: Implement additional variants (NoBishops, NoKnights, Random, etc.)
- [ ] Phase 8: Build rendering system (BoardPainter, TimelineView, GameScene)
- [ ] Phase 9: Implement state management (GameProvider, UI integration)
- [ ] Phase 10: Create GameScreen and integrate with NewGameScreen
- [ ] Phase 11: Comprehensive testing and refinement