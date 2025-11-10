import 'package:chess_5d/game/logic/board.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:chess_5d/game/logic/position.dart';

/// Represents a move in 5D Chess
///
/// A move can be:
/// - Physical move: Moves on the same board (same l and t)
/// - Inter-dimensional move: Moves across timelines (different l or t)
/// - Null move: Internal mechanism to create a new board without moving a piece
///   (used for turn advancement when no moves were made on a timeline)
class Move {
  /// Create a regular move (requires both sourcePiece and targetPos)
  ///
  /// [game] - The game this move belongs to
  /// [sourcePiece] - The piece making the move (required)
  /// [targetPos] - Target position (required)
  /// [promotionTo] - Promotion type (1-4, or null)
  /// [remoteMove] - Whether this is a remote move
  /// [fastForward] - Whether to skip animations
  Move({
    required this.game,
    required Piece sourcePiece,
    required Vec4 targetPos,
    int? promotionTo,
    this.remoteMove = false,
    bool fastForward = false,
  }) : promote = promotionTo,
       to = targetPos,
       sourcePiece = sourcePiece,
       usedBoards = [],
       createdBoards = [],
       nullMove = false,
       isInterDimensionalMove = true,
       sourceBoard = null,
       targetBoard = null {
    // Set from position
    try {
      from = sourcePiece.pos();
    } catch (e) {
      // Piece not on a board yet - this should not happen for valid moves
      throw StateError('Cannot create move: piece is not on a board');
    }

    final sourceBoardOriginal = sourcePiece.board;
    if (sourceBoardOriginal == null) {
      throw StateError('Cannot create move: source piece is not on a board');
    }

    // Get the target board from the timeline
    final targetTimeline = game.getTimeline(targetPos.l);
    var targetOriginBoard = targetTimeline.getBoard(targetPos.t);

    // Get source timeline
    final sourceTimeline = game.getTimeline(sourceBoardOriginal.l);

    // If target board doesn't exist, we need to create it
    // This happens when moving to the next turn on the same timeline
    if (targetOriginBoard == null) {
      // Check if we're moving to the next turn on the same timeline
      if (targetPos.l == sourceBoardOriginal.l &&
          targetPos.t == sourceBoardOriginal.t + 1) {
        // This is a normal move to the next turn - we'll create the board below
        // For now, we'll use the source board as the "target origin" to clone from
        targetOriginBoard = sourceBoardOriginal;
      } else {
        // Cannot move to a non-existent board on a different timeline or turn
        throw StateError(
          'Cannot create move: target board does not exist at timeline ${targetPos.l}, turn ${targetPos.t}',
        );
      }
    }

    // Track used boards (boards that will become inactive)
    usedBoards.add(sourceBoardOriginal);

    // Determine move type and create boards accordingly
    if (!targetOriginBoard.active) {
      // Case 1: Moving to inactive board (past) - create timeline branch
      // Create a copy of the source board
      sourceBoard = game.instantiateBoard(
        sourceBoardOriginal.l,
        sourceBoardOriginal.t,
        sourceBoardOriginal.turn,
        sourceBoardOriginal,
        fastForward,
      );

      // Update source board in its timeline
      sourceTimeline.setBoard(sourceBoardOriginal.t, sourceBoard!);

      // Calculate new timeline index
      // newL = ++timelineCount[targetOriginBoard.turn] * (targetOriginBoard.turn ? 1 : -1)
      final targetSide = targetOriginBoard.turn;
      game.timelineCount[targetSide] = game.timelineCount[targetSide] + 1;
      final newL = game.timelineCount[targetSide] * (targetSide == 1 ? 1 : -1);

      // Create new timeline starting at targetBoard.t + 1
      game.instantiateTimeline(
        newL,
        targetOriginBoard.t + 1,
        sourceBoardOriginal.l,
        fastForward,
      );

      // Create target board on new timeline (branching from the past board)
      targetBoard = game.instantiateBoard(
        newL,
        targetOriginBoard.t + 1,
        targetOriginBoard.turn,
        targetOriginBoard,
        fastForward,
      );

      // Set the board in the new timeline
      game.getTimeline(newL).setBoard(targetOriginBoard.t + 1, targetBoard!);

      isInterDimensionalMove = true;
    } else if (sourceBoardOriginal != targetOriginBoard) {
      // Case 2: Moving to active board on different timeline
      // Create copies of both boards
      sourceBoard = game.instantiateBoard(
        sourceBoardOriginal.l,
        sourceBoardOriginal.t,
        sourceBoardOriginal.turn,
        sourceBoardOriginal,
        fastForward,
      );

      // Update source board in its timeline
      sourceTimeline.setBoard(sourceBoardOriginal.t, sourceBoard!);

      targetBoard = game.instantiateBoard(
        targetOriginBoard.l,
        targetOriginBoard.t,
        targetOriginBoard.turn,
        targetOriginBoard,
        fastForward,
      );

      // Update the target board in its timeline
      targetTimeline.setBoard(targetOriginBoard.t, targetBoard!);

      usedBoards.add(targetOriginBoard);
      isInterDimensionalMove = true;
    } else {
      // Case 3: Moving on the same board (normal move)
      // Check if we're moving to the next turn (board needs to be created)
      if (targetOriginBoard == sourceBoardOriginal &&
          targetPos.l == sourceBoardOriginal.l &&
          targetPos.t == sourceBoardOriginal.t + 1) {
        // Moving to next turn on same timeline - create new board at next turn
        sourceBoard = game.instantiateBoard(
          sourceBoardOriginal.l,
          sourceBoardOriginal.t,
          sourceBoardOriginal.turn,
          sourceBoardOriginal,
          fastForward,
        );

        // Update source board in timeline
        sourceTimeline.setBoard(sourceBoardOriginal.t, sourceBoard!);

        // Create target board at next turn
        targetBoard = game.instantiateBoard(
          targetPos.l,
          targetPos.t,
          1 - sourceBoardOriginal.turn, // Next turn alternates
          sourceBoardOriginal,
          fastForward,
        );

        // Set target board in timeline
        sourceTimeline.setBoard(targetPos.t, targetBoard!);
      } else {
        // Moving on the same board (same turn)
        sourceBoard = game.instantiateBoard(
          sourceBoardOriginal.l,
          sourceBoardOriginal.t,
          sourceBoardOriginal.turn,
          sourceBoardOriginal,
          fastForward,
        );
        targetBoard = sourceBoard;

        // Update the board in its timeline
        sourceTimeline.setBoard(sourceBoardOriginal.t, sourceBoard!);
      }

      isInterDimensionalMove = false;
    }

    // Track created boards (sourceBoard is guaranteed to be non-null here)
    createdBoards.add(sourceBoard!);
    if (isInterDimensionalMove &&
        targetBoard != sourceBoard &&
        targetBoard != null) {
      createdBoards.add(targetBoard!);
    }

    // Remove piece at target position if it exists
    final targetPiece = targetBoard?.getPiece(targetPos.x, targetPos.y);
    if (targetPiece != null) {
      targetPiece.remove();
    }

    // Move the piece (or promote if needed)
    final sourcePieceOnSourceBoard = sourceBoard?.getPiece(from!.x, from!.y);
    if (sourcePieceOnSourceBoard == null) {
      throw StateError('Source piece not found on source board');
    }

    if (targetBoard == null) {
      throw StateError('Target board is null');
    }

    if (promote != null) {
      // Handle promotion (will be fully implemented in a later phase)
      // For now, just move the piece
      sourcePieceOnSourceBoard.changePosition(
        targetBoard,
        targetPos.x,
        targetPos.y,
        sourceBoard: sourceBoardOriginal,
        sourcePiece: sourcePiece,
      );
    } else {
      // Normal move
      sourcePieceOnSourceBoard.changePosition(
        targetBoard,
        targetPos.x,
        targetPos.y,
        sourceBoard: sourceBoardOriginal,
        sourcePiece: sourcePiece,
      );
    }

    // Make used boards inactive
    for (final board in usedBoards) {
      board.makeInactive();
    }
  }

  /// Private constructor for null moves (internal use only)
  ///
  /// Null moves are used internally by the game engine to advance timelines
  /// when no piece moves were made on that timeline during a turn.
  Move._nullMove({
    required this.game,
    required int timelineIndex,
    this.remoteMove = false,
  }) : sourcePiece = null,
       from = null,
       to = null,
       promote = null,
       usedBoards = [],
       createdBoards = [],
       nullMove = true,
       isInterDimensionalMove = false,
       sourceBoard = null,
       targetBoard = null,
       l = timelineIndex;

  /// Create a null move (creates a new board without moving a piece)
  ///
  /// Null moves are internal game mechanics used during submit() to advance
  /// timelines when no piece moves were made on that timeline.
  ///
  /// [game] - The game
  /// [board] - The board/timeline to create the null move for
  /// [fastForward] - Whether to skip animations
  factory Move.nullMove(dynamic game, Board board, {bool fastForward = false}) {
    final move = Move._nullMove(game: game, timelineIndex: board.l);

    // Create a new board for the next turn on this timeline
    final timeline = game.getTimeline(board.l);
    final nextTurn = board.t + 1;
    final nextTurnBoard = game.instantiateBoard(
      board.l,
      nextTurn,
      board.turn,
      board,
      fastForward,
    );

    timeline.setBoard(nextTurn, nextTurnBoard);
    move.createdBoards.add(nextTurnBoard);
    move.usedBoards.add(board);
    board.makeInactive();

    return move;
  }

  /// Create a move from serialized data
  ///
  /// Note: This is a simplified version. Full deserialization will require
  /// access to the game state to reconstruct pieces and boards.
  ///
  /// For null moves, this will create a null move. For regular moves,
  /// sourcePiece will need to be reconstructed from the game state in Phase 2.
  factory Move.fromSerialized(dynamic game, Map<String, dynamic> data) {
    final isNullMove = data['nullMove'] ?? false;

    if (isNullMove) {
      // Create null move
      final timelineIndex = data['l'] as int?;
      if (timelineIndex == null) {
        throw ArgumentError('Null move must have timeline index (l)');
      }
      return Move._nullMove(
        game: game,
        timelineIndex: timelineIndex,
        remoteMove: data['remoteMove'] ?? false,
      );
    } else {
      // Create regular move (sourcePiece will need to be set later)
      // This is a temporary object that will be fully reconstructed in Phase 2
      final targetPos = data['to'] != null ? Vec4.fromJson(data['to']) : null;
      if (targetPos == null) {
        throw ArgumentError('Regular move must have target position');
      }

      // We need a sourcePiece, but we can't reconstruct it yet without game state
      // For now, throw an error - this will be properly implemented in Phase 2
      throw UnimplementedError(
        'Deserialization of regular moves requires game state access. '
        'This will be implemented in Phase 2 when Game class is available.',
      );
    }
  }

  /// The game this move belongs to
  dynamic game; // Game class (forward reference)

  /// Board the move starts from
  Board? sourceBoard;

  /// Board the move ends on
  Board? targetBoard;

  /// Source position (Vec4)
  Vec4? from;

  /// Destination position (Vec4)
  Vec4? to;

  /// Source piece (null only for null moves)
  Piece? sourcePiece;

  /// Whether this is an inter-dimensional move (across timelines)
  bool isInterDimensionalMove;

  /// Whether this is a null move (no piece movement, internal game mechanic)
  bool nullMove;

  /// Whether this move is from a remote player
  bool remoteMove;

  /// Pawn promotion: 1=Queen, 2=Knight, 3=Rook, 4=Bishop
  int? promote;

  /// Boards that become inactive due to this move
  List<Board> usedBoards;

  /// Boards created by this move
  List<Board> createdBoards;

  /// Timeline index (for null moves, specifies which timeline to advance)
  int? l;

  /// Whether this move has been executed
  bool _executed = false;

  /// Execute this move
  ///
  /// This is a placeholder - full implementation will come in Phase 2
  void execute({bool fastForward = false}) {
    if (_executed) {
      return;
    }

    // TODO: Implement move execution in Phase 2
    // For now, just mark as executed
    _executed = true;
  }

  /// Undo this move
  ///
  /// Reverses the move by removing created boards and reactivating used boards
  void undo() {
    // Remove created boards and reactivate used boards
    for (int i = 0; i < createdBoards.length; i++) {
      final createdBoard = createdBoards[i];

      // Remove the board from its timeline
      final timeline = game.getTimeline(createdBoard.l);
      timeline.boards[createdBoard.t - timeline.start] = null;

      // Remove the board (this will clean up pieces)
      createdBoard.remove();

      // Reactivate the corresponding used board if it exists
      if (i < usedBoards.length) {
        final usedBoard = usedBoards[i];
        usedBoard.makeActive();
      }
    }

    // If this was a timeline branch, we may need to remove the timeline
    if (isInterDimensionalMove &&
        targetBoard != sourceBoard &&
        targetBoard != null) {
      final targetTimeline = game.getTimeline(targetBoard!.l);
      // Check if timeline is now empty
      if (targetTimeline.boardCount == 0) {
        // Remove the timeline (this is handled by the timeline itself)
        targetTimeline.remove();

        // Update timeline count
        final side = targetBoard!.l < 0 ? 0 : 1;
        if (game.timelineCount[side] > 0) {
          game.timelineCount[side] = game.timelineCount[side] - 1;
        }
      }
    }

    _executed = false;
  }

  /// Serialize this move to JSON
  ///
  /// Used for network transmission and undo/redo
  Map<String, dynamic> serialize() {
    return {
      'from': from?.toJson(),
      'to': to?.toJson(),
      'sourcePiece': sourcePiece != null
          ? {
              'type': sourcePiece!.type,
              'side': sourcePiece!.side,
              'x': sourcePiece!.x,
              'y': sourcePiece!.y,
            }
          : null,
      'sourceBoard': sourceBoard != null
          ? {'l': sourceBoard!.l, 't': sourceBoard!.t}
          : null,
      'targetBoard': targetBoard != null
          ? {'l': targetBoard!.l, 't': targetBoard!.t}
          : null,
      'isInterDimensionalMove': isInterDimensionalMove,
      'nullMove': nullMove,
      'remoteMove': remoteMove,
      'promote': promote,
      'l': l,
    };
  }

  /// Check if this move is valid
  ///
  /// This is a placeholder - full validation will come in Phase 2
  bool isValid() {
    // TODO: Implement move validation in Phase 2
    return true;
  }

  /// Get promotion piece type name
  String? getPromotionTypeName() {
    switch (promote) {
      case 1:
        return 'queen';
      case 2:
        return 'knight';
      case 3:
        return 'rook';
      case 4:
        return 'bishop';
      default:
        return null;
    }
  }

  @override
  String toString() {
    if (nullMove) {
      return 'Move(null, l:$l)';
    }
    return 'Move($from -> $to, piece:${sourcePiece?.type}, interDim:$isInterDimensionalMove)';
  }
}
