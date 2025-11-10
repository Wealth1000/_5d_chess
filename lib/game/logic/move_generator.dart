import 'package:chess_5d/game/logic/board.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:chess_5d/game/logic/position.dart';
import 'package:chess_5d/game/logic/check_detector.dart';

/// Generates all legal moves for a piece
///
/// This class filters moves based on:
/// - Board bounds (handled by piece.enumerateMoves)
/// - Friendly pieces blocking (handled by piece.enumerateMoves)
/// - Check constraints (would move leave king in check?)
class MoveGenerator {
  /// Get all legal moves for a piece
  ///
  /// [piece] - The piece to get moves for
  /// [targetL] - Optional target timeline
  ///
  /// Returns a list of Vec4 positions representing legal move destinations.
  static List<Vec4> getMovesForPiece(Piece piece, [int? targetL]) {
    final board = piece.board;
    if (board == null) {
      return [];
    }

    // Get all possible moves from the piece's movement pattern
    final allMoves = piece.enumerateMoves(targetL);

    // Filter out moves that would leave the king in check
    final legalMoves = <Vec4>[];
    for (final move in allMoves) {
      // Check if this move would leave the king in check
      final wouldLeaveInCheck = CheckDetector.wouldMoveLeaveKingInCheck(
        board,
        piece,
        move.x,
        move.y,
        targetL,
      );

      if (!wouldLeaveInCheck) {
        legalMoves.add(move);
      }
    }

    return legalMoves;
  }

  /// Get all legal moves for all pieces of a side on a board
  ///
  /// [board] - The board to check
  /// [side] - Side to get moves for (0 = black, 1 = white)
  /// [targetL] - Optional target timeline
  ///
  /// Returns a map of pieces to their legal moves.
  static Map<Piece, List<Vec4>> getAllMovesForSide(
    Board board,
    int side, [
    int? targetL,
  ]) {
    final moves = <Piece, List<Vec4>>{};

    // Find all pieces of the specified side
    for (int x = 0; x < 8; x++) {
      for (int y = 0; y < 8; y++) {
        final piece = board.getPiece(x, y);
        if (piece != null && piece.side == side) {
          final pieceMoves = getMovesForPiece(piece, targetL);
          if (pieceMoves.isNotEmpty) {
            moves[piece] = pieceMoves;
          }
        }
      }
    }

    return moves;
  }

  /// Check if a side has any legal moves
  ///
  /// [board] - The board to check
  /// [side] - Side to check (0 = black, 1 = white)
  /// [targetL] - Optional target timeline
  ///
  /// Returns true if the side has at least one legal move.
  static bool hasLegalMoves(Board board, int side, [int? targetL]) {
    final allMoves = getAllMovesForSide(board, side, targetL);
    return allMoves.values.any((moves) => moves.isNotEmpty);
  }
}
