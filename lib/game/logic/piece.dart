import 'package:chess_5d/game/logic/position.dart';

/// Abstract base class for chess pieces
///
/// This class provides the foundation for all piece types.
/// Pieces are associated with a Game and Board, and track their position.
abstract class BasePiece {

  BasePiece({
    required this.game,
    required this.board,
    required this.side,
    required this.x,
    required this.y,
  });
  /// The game this piece belongs to
  dynamic game; // Game class (forward reference, will be defined later)

  /// The board this piece is currently on
  dynamic board; // Board class (forward reference)

  /// Side: 0 = black, 1 = white
  final int side;

  /// X coordinate on the board (0-7)
  int x;

  /// Y coordinate on the board (0-7)
  int y;

  /// Piece type name (e.g., "pawn", "rook", "king")
  String type = '';

  /// Whether this piece has moved (for castling/pawn rules)
  bool hasMoved = false;

  /// Initialize the piece type
  void initType(String type) {
    this.type = type;
  }

  /// Change position of this piece
  ///
  /// [newBoard] - The board to move to
  /// [newX] - New x coordinate
  /// [newY] - New y coordinate
  /// [sourceBoard] - Original board (for cloning)
  /// [sourcePiece] - Original piece (for cloning)
  void changePosition(
    dynamic newBoard,
    int newX,
    int newY, {
    dynamic sourceBoard,
    dynamic sourcePiece,
  }) {
    // Remove from old board
    if (board != null && board.pieces[x][y] == this) {
      board.pieces[x][y] = null;
    }

    // Update position
    board = newBoard;
    x = newX;
    y = newY;

    // Add to new board
    if (newBoard != null) {
      newBoard.pieces[x][y] = this;
    }
  }

  /// Clone this piece to a new board
  void cloneToBoard(dynamic newBoard) {
    // This will be implemented by concrete piece classes
    // as they need to create instances of their specific type
  }

  /// Remove this piece from the board
  void remove() {
    if (board != null && board.pieces[x][y] == this) {
      board.pieces[x][y] = null;
    }
    board = null;
  }

  /// Get the Vec4 position of this piece
  Vec4 pos() {
    if (board == null) {
      throw StateError('Piece is not on a board');
    }
    return Vec4(x, y, board.l, board.t);
  }

  /// Enumerate all possible moves for this piece
  ///
  /// [targetL] - Optional target timeline. If null, generates moves for current timeline.
  /// Returns a list of Vec4 positions representing possible move destinations.
  List<Vec4> enumerateMoves([int? targetL]) {
    // This will be implemented by concrete piece classes
    return [];
  }

  /// Check if this piece can move to a given position
  ///
  /// This is a helper method that checks if a position is in the enumerated moves.
  bool canMoveTo(Vec4 targetPos, [int? targetL]) {
    final moves = enumerateMoves(targetL);
    return moves.any((move) => move.equals(targetPos));
  }

  @override
  String toString() => 'Piece($type, side:$side, pos:($x,$y))';
}

/// Piece class that extends BasePiece
///
/// This is the concrete implementation that will be used for all pieces.
/// Concrete piece types (Pawn, Rook, etc.) will extend this class.
class Piece extends BasePiece {
  Piece({
    required super.game,
    required super.board,
    required super.side,
    required super.x,
    required super.y,
    String? type,
  }) : super() {
    if (type != null) {
      initType(type);
    }
  }

  /// Create a copy of this piece
  Piece copy() {
    final newPiece = Piece(
      game: game,
      board: board,
      side: side,
      x: x,
      y: y,
      type: type,
    );
    newPiece.hasMoved = hasMoved;
    return newPiece;
  }

  /// Clone this piece to a new board
  @override
  void cloneToBoard(dynamic newBoard) {
    final clonedPiece = Piece(
      game: game,
      board: newBoard,
      side: side,
      x: x,
      y: y,
      type: type,
    );
    clonedPiece.hasMoved = hasMoved;
    newBoard.pieces[x][y] = clonedPiece;
  }
}

/// Piece type constants
class PieceType {
  static const String pawn = 'pawn';
  static const String rook = 'rook';
  static const String knight = 'knight';
  static const String bishop = 'bishop';
  static const String queen = 'queen';
  static const String king = 'king';
}

/// Piece side constants
class PieceSide {
  static const int black = 0;
  static const int white = 1;
}
