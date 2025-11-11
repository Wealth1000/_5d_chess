import 'package:chess_5d/game/logic/check_detector.dart';
import 'package:chess_5d/game/logic/position.dart';

/// Simple checkmate detector using brute-force search
///
/// This is a simpler, more reliable alternative to the hypercuboid algorithm.
/// It works by:
/// 1. Checking if the current player is in check
/// 2. Generating all possible moves for the current player
/// 3. Testing if any move would get out of check
/// 4. If no moves get out of check, it's checkmate
///
/// This is slower than the hypercuboid algorithm but more reliable and easier to debug.
class SimpleCheckmateDetector {
  /// Check if the current player is in checkmate
  ///
  /// [game] - The game state
  ///
  /// Returns true if the current player is in checkmate (in check with no legal moves).
  static bool isCheckmate(dynamic game) {
    // First, check if the player is in check
    final inCheck = _isPlayerInCheck(game);
    if (!inCheck) {
      return false; // Not in check, so not checkmate
    }

    // If in check, check if there are any legal moves that would get out of check
    return !_hasEscapeMoves(game);
  }

  /// Check if the current player is in stalemate
  ///
  /// [game] - The game state
  ///
  /// Returns true if the current player is in stalemate (not in check but has no legal moves).
  static bool isStalemate(dynamic game) {
    // First, check if the player is in check
    final inCheck = _isPlayerInCheck(game);
    if (inCheck) {
      return false; // In check, so not stalemate (would be checkmate if no moves)
    }

    // If not in check, check if there are any legal moves
    return !_hasLegalMoves(game);
  }

  /// Check if the current player has any legal moves
  ///
  /// [game] - The game state
  ///
  /// Returns true if the current player has at least one legal move.
  static bool hasLegalMoves(dynamic game) {
    return _hasLegalMoves(game);
  }

  /// Check if the current player is in check
  ///
  /// [game] - The game state
  ///
  /// Returns true if the current player's king is in check.
  static bool isPlayerInCheck(dynamic game) {
    return _isPlayerInCheck(game);
  }

  /// Internal: Check if the current player is in check
  static bool _isPlayerInCheck(dynamic game) {
    final currentTurn = game.turn;

    // Check all active timelines for boards with the current player's turn
    for (final timelineDirection in game.timelines) {
      for (final timeline in timelineDirection) {
        if (!timeline.isActive) continue;

        final currentBoard = timeline.getCurrentBoard();
        if (currentBoard == null) continue;

        // Check if this board's turn matches current turn
        if (currentBoard.turn == currentTurn) {
          // Check if king is in check (cross-timeline)
          final inCheck = CheckDetector.isKingInCheckCrossTimeline(
            game,
            currentBoard,
            currentTurn,
          );

          if (inCheck) {
            return true; // Found a check
          }
        }
      }
    }

    return false; // Not in check
  }

  /// Internal: Check if the current player has any legal moves
  static bool _hasLegalMoves(dynamic game) {
    final currentTurn = game.turn;

    // Check all active timelines for boards with the current player's turn
    for (final timelineDirection in game.timelines) {
      for (final timeline in timelineDirection) {
        if (!timeline.isActive) continue;

        final currentBoard = timeline.getCurrentBoard();
        if (currentBoard == null) continue;

        // Check if this board's turn matches current turn
        if (currentBoard.turn == currentTurn) {
          // Get all pieces on this board for the current player
          for (int x = 0; x < 8; x++) {
            for (int y = 0; y < 8; y++) {
              final piece = currentBoard.getPiece(x, y);
              if (piece == null || piece.side != currentTurn) {
                continue;
              }

              // Get all possible moves for this piece (including time travel)
              final moves = piece.enumerateMoves();

              // Test each move to see if it's legal (doesn't leave king in check)
              for (final move in moves) {
                try {
                  // Use CheckDetector to check if move would leave king in check
                  // This method simulates the move internally without modifying game state
                  final wouldLeaveInCheck =
                      CheckDetector.wouldMoveLeaveKingInCheckCrossTimeline(
                        game,
                        currentBoard,
                        piece,
                        move,
                      );

                  // If this move doesn't leave the king in check, we have a legal move
                  if (!wouldLeaveInCheck) {
                    return true; // Found a legal move
                  }
                } catch (e) {
                  // Invalid move, skip it
                  continue;
                }
              }
            }
          }
        }
      }
    }

    return false; // No legal moves found
  }

  /// Internal: Check if the current player has any escape moves (moves that get out of check)
  static bool _hasEscapeMoves(dynamic game) {
    final currentTurn = game.turn;

    // Check all active timelines for boards with the current player's turn
    for (final timelineDirection in game.timelines) {
      for (final timeline in timelineDirection) {
        if (!timeline.isActive) continue;

        final currentBoard = timeline.getCurrentBoard();
        if (currentBoard == null) continue;

        // Check if this board's turn matches current turn
        if (currentBoard.turn == currentTurn) {
          // Get all pieces on this board for the current player
          for (int x = 0; x < 8; x++) {
            for (int y = 0; y < 8; y++) {
              final piece = currentBoard.getPiece(x, y);
              if (piece == null || piece.side != currentTurn) {
                continue;
              }

              // Get all possible moves for this piece (including time travel)
              final moves = piece.enumerateMoves();

              // Test each move to see if it gets out of check
              for (final move in moves) {
                try {
                  // Use CheckDetector to check if move would leave king in check
                  // This method simulates the move internally without modifying game state
                  final stillInCheck =
                      CheckDetector.wouldMoveLeaveKingInCheckCrossTimeline(
                        game,
                        currentBoard,
                        piece,
                        move,
                      );

                  // If this move gets us out of check, we have an escape
                  if (!stillInCheck) {
                    return true; // Found an escape move
                  }
                } catch (e) {
                  // Invalid move, skip it
                  continue;
                }
              }
            }
          }
        }
      }
    }

    return false; // No escape moves found
  }

  /// Get all legal moves for the current player
  ///
  /// [game] - The game state
  ///
  /// Returns a list of legal moves (piece, target position pairs).
  static List<Map<String, dynamic>> getLegalMoves(dynamic game) {
    final legalMoves = <Map<String, dynamic>>[];
    final currentTurn = game.turn;

    // Check all active timelines for boards with the current player's turn
    for (final timelineDirection in game.timelines) {
      for (final timeline in timelineDirection) {
        if (!timeline.isActive) continue;

        final currentBoard = timeline.getCurrentBoard();
        if (currentBoard == null) continue;

        // Check if this board's turn matches current turn
        if (currentBoard.turn == currentTurn) {
          // Get all pieces on this board for the current player
          for (int x = 0; x < 8; x++) {
            for (int y = 0; y < 8; y++) {
              final piece = currentBoard.getPiece(x, y);
              if (piece == null || piece.side != currentTurn) {
                continue;
              }

              // Get all possible moves for this piece (including time travel)
              final moves = piece.enumerateMoves();

              // Test each move to see if it's legal
              for (final move in moves) {
                try {
                  // Use CheckDetector to check if move would leave king in check
                  // This method simulates the move internally without modifying game state
                  final wouldLeaveInCheck =
                      CheckDetector.wouldMoveLeaveKingInCheckCrossTimeline(
                        game,
                        currentBoard,
                        piece,
                        move,
                      );

                  // If this move is legal, add it to the list
                  if (!wouldLeaveInCheck) {
                    legalMoves.add({
                      'piece': piece,
                      'from': Vec4(
                        piece.x,
                        piece.y,
                        currentBoard.l,
                        currentBoard.t,
                      ),
                      'to': move,
                    });
                  }
                } catch (e) {
                  // Invalid move, skip it
                  continue;
                }
              }
            }
          }
        }
      }
    }

    return legalMoves;
  }
}
