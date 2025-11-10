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
       isInterDimensionalMove = false,
       sourceBoard = sourcePiece.board {
    // Set from position
    try {
      from = sourcePiece.pos();
    } catch (e) {
      // Piece not on a board yet - this should not happen for valid moves
      throw StateError('Cannot create move: piece is not on a board');
    }

    // Determine if this is an inter-dimensional move
    isInterDimensionalMove = from!.l != targetPos.l || from!.t != targetPos.t;
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
  factory Move.nullMove(dynamic game, Board board) {
    return Move._nullMove(game: game, timelineIndex: board.l);
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
  /// This is a placeholder - full implementation will come in Phase 2
  void undo() {
    if (!_executed) {
      return;
    }

    // TODO: Implement move undo in Phase 2
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
