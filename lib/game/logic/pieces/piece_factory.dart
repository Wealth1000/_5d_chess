import 'package:chess_5d/game/logic/piece.dart';
import 'package:chess_5d/game/logic/board.dart';

/// Factory for creating chess pieces
///
/// This factory creates pieces of specific types based on piece type strings.
class PieceFactory {
  /// Create a piece of the specified type
  ///
  /// [game] - The game this piece belongs to
  /// [board] - The board this piece is on
  /// [type] - Piece type (pawn, rook, knight, bishop, queen, king)
  /// [side] - Piece side (0 = black, 1 = white)
  /// [x] - X coordinate
  /// [y] - Y coordinate
  static Piece createPiece({
    required dynamic game,
    required Board board,
    required String type,
    required int side,
    required int x,
    required int y,
  }) {
    final piece = Piece(
      game: game,
      board: board,
      side: side,
      x: x,
      y: y,
      type: type,
    );
    return piece;
  }

  /// Create a piece from a type string
  ///
  /// This is a convenience method that uses the standard piece type constants.
  static Piece createPieceFromType({
    required dynamic game,
    required Board board,
    required String type,
    required int side,
    required int x,
    required int y,
  }) {
    return createPiece(
      game: game,
      board: board,
      type: type,
      side: side,
      x: x,
      y: y,
    );
  }
}
