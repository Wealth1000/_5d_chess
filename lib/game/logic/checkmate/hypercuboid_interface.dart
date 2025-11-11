import 'package:chess_5d/game/logic/board.dart';
import 'package:chess_5d/game/logic/check_detector.dart';
import 'package:chess_5d/game/logic/move.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:chess_5d/game/logic/position.dart';

/// Interface functions for the hypercuboid algorithm
///
/// These functions provide the hypercuboid algorithm with access to game state
/// in a way that matches the JavaScript reference implementation.
class HypercuboidInterface {
  /// Get the l-index where a new timeline would be created
  ///
  /// [game] - The game state
  ///
  /// Returns the next timeline index for the current player.
  static int getNewL(dynamic game) {
    final side = game.turn;
    if (side == 1) {
      // White: positive timelines
      return game.timelineCount[1];
    } else {
      // Black: negative timelines
      return -(game.timelineCount[0] + 1);
    }
  }

  /// Get the l-index of the timeline most recently created by the opponent
  ///
  /// [game] - The game state
  ///
  /// Returns the opponent's most recent timeline index.
  static int getOpL(dynamic game) {
    final side = game.turn;
    if (side == 1) {
      // White's turn, so opponent (black) created negative timelines
      return -game.timelineCount[0];
    } else {
      // Black's turn, so opponent (white) created positive timelines
      return game.timelineCount[1] - 1;
    }
  }

  /// Get the end turn (t) for a timeline
  ///
  /// [game] - The game state
  /// [l] - Timeline index
  ///
  /// Returns the end turn number for the timeline.
  static int getEndT(dynamic game, int l) {
    final timeline = game.getTimeline(l);
    return timeline.end;
  }

  /// Get all moves from a timeline
  ///
  /// [game] - The game state
  /// [l] - Timeline index
  ///
  /// Returns a list of move data structures.
  /// Each move data contains:
  /// - start: [l, t, x, y]
  /// - end: [l, t, x, y]
  /// - newBoards: Map of board l-index to board state
  static List<Map<String, dynamic>> movesFrom(dynamic game, int l) {
    final timeline = game.getTimeline(l);
    final currentBoard = timeline.getCurrentBoard();
    if (currentBoard == null) {
      return [];
    }

    final moves = <Map<String, dynamic>>[];

    // Get all pieces on the board that belong to the current player
    for (int x = 0; x < 8; x++) {
      for (int y = 0; y < 8; y++) {
        final piece = currentBoard.getPiece(x, y);
        if (piece == null || piece.side != currentBoard.turn) {
          continue;
        }

        // Get all possible moves for this piece
        final destinations = piece.enumerateMoves();
        for (final dest in destinations) {
          try {
            // Create a move to get the board states
            // The move constructor executes the move, so we need to capture
            // the board states before undoing
            final move = game.instantiateMove(
              piece,
              dest,
              null, // no promotion
              false, // not remote
              true, // fastForward
            );

            // Extract move data before undoing
            // Store board states as arrays before they're removed
            final newBoards = <int, dynamic>{};
            for (final board in move.createdBoards) {
              // Create a snapshot of the board before undo removes it
              newBoards[board.l] = _boardToArray(board);
            }

            final startPos = move.from;
            final endPos = move.to;
            if (startPos == null || endPos == null) {
              continue; // Skip moves without positions
            }

            // Undo the move to restore original state
            move.undo();

            moves.add({
              'start': [startPos.l, startPos.t, startPos.x, startPos.y],
              'end': [endPos.l, endPos.t, endPos.x, endPos.y],
              'newBoards': newBoards,
            });
          } catch (e) {
            // Skip invalid moves
            continue;
          }
        }
      }
    }

    return moves;
  }

  /// Get playable timelines (timelines where it's the current player's turn)
  ///
  /// [game] - The game state
  ///
  /// Returns a list of timeline indices where the current player can move.
  static List<int> getPlayableTimelines(dynamic game) {
    final result = <int>[];
    final minL = -game.timelineCount[0];
    final maxL = game.timelineCount[1];

    for (int l = minL; l <= maxL; l++) {
      try {
        final timeline = game.getTimeline(l);
        if (!timeline.isActive) continue;

        final currentBoard = timeline.getCurrentBoard();
        if (currentBoard == null) continue;

        // Check if it's the current player's turn on this timeline
        // A timeline is playable if (end + 1) % 2 == turn
        if ((timeline.end + 1) % 2 == game.turn) {
          result.add(l);
        }
      } catch (e) {
        // Timeline doesn't exist, skip
        continue;
      }
    }

    return result;
  }

  /// Check if a position exists in the game state
  ///
  /// [game] - The game state
  /// [pos] - Position as [l, t, x, y]
  ///
  /// Returns true if the position exists.
  static bool posExists(dynamic game, List<int> pos) {
    if (pos.length != 4) return false;

    final l = pos[0];
    final t = pos[1];
    final x = pos[2];
    final y = pos[3];

    // Check bounds
    if (l < -game.timelineCount[0] || l > game.timelineCount[1]) {
      return false;
    }

    if (x < 0 || y < 0 || x >= 8 || y >= 8) {
      return false;
    }

    try {
      final timeline = game.getTimeline(l);
      if (t < timeline.start || t > timeline.end) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get piece at a position
  ///
  /// [game] - The game state
  /// [pos] - Position as [l, t, x, y]
  ///
  /// Returns piece string representation or null.
  static String? getPieceAt(dynamic game, List<int> pos) {
    if (!posExists(game, pos)) {
      return null;
    }

    final l = pos[0];
    final t = pos[1];
    final x = pos[2];
    final y = pos[3];

    try {
      final timeline = game.getTimeline(l);
      final board = timeline.getBoard(t);
      if (board == null) {
        return null;
      }

      final piece = board.getPiece(x, y);
      if (piece == null) {
        return ' ';
      }

      return '${piece.type}_${piece.side}';
    } catch (e) {
      return null;
    }
  }

  /// Apply moves temporarily and execute a function
  ///
  /// [game] - The game state
  /// [moves] - List of move data to apply
  /// [fn] - Function to execute with moves applied
  ///
  /// Returns the result of the function.
  /// The moves are automatically undone after the function returns.
  static T withMoves<T>(
    dynamic game,
    List<Map<String, dynamic>> moves,
    T Function(dynamic game) fn,
  ) {
    final appliedMoves = <Move>[];

    // Apply moves
    for (final moveData in moves) {
      final start = (moveData['start'] as List).map((e) => e as int).toList();
      final end = (moveData['end'] as List).map((e) => e as int).toList();

      try {
        final piece = game.getPiece(
          Vec4(start[2], start[3], start[0], start[1]),
        );
        if (piece == null) continue;

        final targetPos = Vec4(end[2], end[3], end[0], end[1]);
        final move = game.instantiateMove(piece, targetPos, null, false, true);
        appliedMoves.add(move);
      } catch (e) {
        // Skip invalid moves
        continue;
      }
    }

    // Execute function
    final result = fn(game);

    // Undo moves in reverse order
    for (int i = appliedMoves.length - 1; i >= 0; i--) {
      appliedMoves[i].undo();
    }

    return result;
  }

  /// Get check path if in check
  ///
  /// [game] - The game state
  ///
  /// Returns a list of [position, piece] pairs representing the check path,
  /// or null if not in check.
  ///
  /// This is a simplified implementation. The full implementation would
  /// trace the attack path from the attacking piece to the king.
  static List<List<dynamic>>? getCheckPath(dynamic game) {
    // Check all timelines for boards with the current player's turn
    for (final timelineDirection in game.timelines) {
      for (final timeline in timelineDirection) {
        if (!timeline.isActive) continue;

        final board = timeline.getCurrentBoard();
        if (board == null) continue;

        // Check if this board's turn matches current turn
        if (board.turn == game.turn) {
          // Check if king is in check
          final inCheck = CheckDetector.isKingInCheckCrossTimeline(
            game,
            board,
            game.turn,
          );

          if (inCheck) {
            // Find the king and attacking pieces
            final path = <List<dynamic>>[];

            // Find the king
            for (int x = 0; x < 8; x++) {
              for (int y = 0; y < 8; y++) {
                final piece = board.getPiece(x, y);
                if (piece != null &&
                    piece.type == PieceType.king &&
                    piece.side == game.turn) {
                  // Add king position
                  path.add([
                    [board.l, board.t, x, y],
                    '${piece.type}_${piece.side}',
                  ]);

                  // Find attacking pieces (simplified - just find any piece that can attack)
                  // In a full implementation, we would trace the attack path
                  for (final otherTimelineDirection in game.timelines) {
                    for (final otherTimeline in otherTimelineDirection) {
                      if (!otherTimeline.isActive) continue;

                      final otherBoard = otherTimeline.getCurrentBoard();
                      if (otherBoard == null) continue;

                      if (otherBoard.turn != game.turn) {
                        for (int px = 0; px < 8; px++) {
                          for (int py = 0; py < 8; py++) {
                            final attackingPiece = otherBoard.getPiece(px, py);
                            if (attackingPiece != null &&
                                attackingPiece.side != game.turn) {
                              final moves = attackingPiece.enumerateMoves(
                                board.l,
                              );
                              if (moves.any(
                                (move) =>
                                    move.x == x &&
                                    move.y == y &&
                                    move.l == board.l &&
                                    move.t == board.t,
                              )) {
                                path.insert(0, [
                                  [otherBoard.l, otherBoard.t, px, py],
                                  '${attackingPiece.type}_${attackingPiece.side}',
                                ]);
                                return path;
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    return null;
  }

  /// Convert a board to a 2D array representation
  ///
  /// [board] - The board to convert
  ///
  /// Returns a 2D array of piece strings.
  static List<List<String>> _boardToArray(Board board) {
    final result = <List<String>>[];
    for (int y = 0; y < 8; y++) {
      final row = <String>[];
      for (int x = 0; x < 8; x++) {
        final piece = board.getPiece(x, y);
        if (piece == null) {
          row.add(' ');
        } else {
          row.add('${piece.type}_${piece.side}');
        }
      }
      result.add(row);
    }
    return result;
  }
}
