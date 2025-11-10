import 'package:chess_5d/game/logic/board.dart';
import 'package:chess_5d/game/logic/piece.dart';

/// Detects check and checkmate conditions
///
/// This class provides methods to check if squares are attacked,
/// if kings are in check, and to find all checks on the board.
class CheckDetector {
  /// Check if a square is attacked by any piece of the attacking side
  ///
  /// [board] - The board to check on
  /// [x] - X coordinate of the square
  /// [y] - Y coordinate of the square
  /// [attackingSide] - Side of the attacking pieces (0 = black, 1 = white)
  /// [targetL] - Optional target timeline (for time travel moves)
  ///
  /// Returns true if the square is attacked by any enemy piece.
  static bool isSquareAttacked(
    Board board,
    int x,
    int y,
    int attackingSide, [
    int? targetL,
  ]) {
    // Check all pieces on the board
    for (int px = 0; px < 8; px++) {
      for (int py = 0; py < 8; py++) {
        final piece = board.getPiece(px, py);
        if (piece == null || piece.side != attackingSide) {
          continue; // Skip empty squares and friendly pieces
        }

        // Get all possible moves for this piece
        final moves = piece.enumerateMoves(targetL);

        // Check if any move targets the square
        if (moves.any((move) => move.x == x && move.y == y)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Check if the king of the specified side is in check
  ///
  /// [board] - The board to check on
  /// [side] - Side of the king to check (0 = black, 1 = white)
  /// [targetL] - Optional target timeline (for time travel moves)
  ///
  /// Returns true if the king is in check.
  static bool isKingInCheck(Board board, int side, [int? targetL]) {
    // Find the king
    Piece? king;
    for (int x = 0; x < 8; x++) {
      for (int y = 0; y < 8; y++) {
        final piece = board.getPiece(x, y);
        if (piece != null &&
            piece.type == PieceType.king &&
            piece.side == side) {
          king = piece;
          break;
        }
      }
      if (king != null) break;
    }

    if (king == null) {
      // No king found - this shouldn't happen in a valid game
      return false;
    }

    // Check if the king's square is attacked by the enemy
    final enemySide = side == 0 ? 1 : 0;
    return isSquareAttacked(board, king.x, king.y, enemySide, targetL);
  }

  /// Find all checks on the board
  ///
  /// This is a placeholder that will be expanded in Phase 3 when we have
  /// the Game class to check across timelines.
  ///
  /// [board] - The board to check
  /// [side] - Side to check for (0 = black, 1 = white)
  ///
  /// Returns true if the king of the specified side is in check.
  static bool findChecks(Board board, int side) {
    return isKingInCheck(board, side);
  }

  /// Check if a move would leave the king in check
  ///
  /// This is used by MoveGenerator to filter out illegal moves.
  ///
  /// [board] - The board before the move
  /// [piece] - The piece making the move
  /// [targetX] - Target X coordinate
  /// [targetY] - Target Y coordinate
  /// [targetL] - Optional target timeline
  ///
  /// Returns true if the move would leave the king in check.
  ///
  /// Implementation: Creates a temporary board with the move applied,
  /// then checks if the king is in check on that board.
  static bool wouldMoveLeaveKingInCheck(
    Board board,
    Piece piece,
    int targetX,
    int targetY, [
    int? targetL,
  ]) {
    // Create a temporary board by cloning the current board
    final tempBoard = Board.fromBoard(board);

    // Find the piece on the temporary board (it will be a clone)
    final tempPiece = tempBoard.getPiece(piece.x, piece.y);
    if (tempPiece == null ||
        tempPiece.type != piece.type ||
        tempPiece.side != piece.side) {
      // Piece not found or doesn't match - this shouldn't happen
      return false;
    }

    // Capture any piece at the target square
    final targetPiece = tempBoard.getPiece(targetX, targetY);
    if (targetPiece != null) {
      // Remove the captured piece
      tempBoard.setPiece(targetX, targetY, null);
    }

    // Move the piece on the temporary board using setPiece (which updates board reference)
    tempBoard.setPiece(piece.x, piece.y, null);
    tempBoard.setPiece(targetX, targetY, tempPiece);
    // Note: setPiece already updates tempPiece.x, tempPiece.y, and tempPiece.board

    // Check if the king of the moving piece's side is in check
    return isKingInCheck(tempBoard, piece.side, targetL);
  }
}
