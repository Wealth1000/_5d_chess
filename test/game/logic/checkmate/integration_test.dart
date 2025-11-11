import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/logic/checkmate/hypercuboid_interface.dart';
import 'package:chess_5d/game/logic/checkmate/hypercuboid.dart';
import 'package:chess_5d/game/logic/checkmate/move_combination.dart';
import 'package:chess_5d/game/logic/game.dart';
import 'package:chess_5d/game/logic/game_options.dart';

/// Integration test for checkmate detection
///
/// This test verifies that the checkmate detection system works
/// as a whole, from game state to hypercuboid search.
void main() {
  group('Checkmate Detection Integration', () {
    late Game game;

    setUp(() {
      final options = GameOptions.defaultOptions();
      game = Game(options: options, localPlayer: [true, true]);
    });

    test('should detect that a new game has legal moves', () {
      // In a new game, white should have legal moves
      final playableTimelines = HypercuboidInterface.getPlayableTimelines(game);
      expect(playableTimelines, isNotEmpty);

      // Get moves from the main timeline
      final moves = HypercuboidInterface.movesFrom(game, 0);
      expect(moves.length, greaterThan(0));
    });

    test('should build hypercuboids for a new game', () {
      // This test verifies that the hypercuboid algorithm can
      // at least build the search space without crashing
      expect(() {
        final searchResults = HypercuboidSearch.search(game);
        // Just iterate a few times to see if it works
        final results = searchResults.take(5).toList();
        expect(results, isNotEmpty);
      }, returnsNormally);
    });

    test('should handle interface functions correctly', () {
      // Test that all interface functions work
      final newL = HypercuboidInterface.getNewL(game);
      expect(newL, isA<int>());

      final opL = HypercuboidInterface.getOpL(game);
      expect(opL, isA<int>());

      final endT = HypercuboidInterface.getEndT(game, 0);
      expect(endT, greaterThanOrEqualTo(0));

      final playable = HypercuboidInterface.getPlayableTimelines(game);
      expect(playable, isA<List<int>>());

      final posExists = HypercuboidInterface.posExists(game, [0, 0, 4, 4]);
      expect(posExists, isA<bool>());

      final pieceAt = HypercuboidInterface.getPieceAt(game, [0, 0, 0, 6]);
      expect(pieceAt, isNotNull);
    });

    test('should create move combinations from search results', () {
      // Test that search results can be converted to move combinations
      final searchResults = HypercuboidSearch.search(game);

      // Take first few results
      int count = 0;
      for (final result in searchResults) {
        if (result is MoveCombination) {
          expect(result.moves, isNotEmpty);
          expect(result.toSerializable(), isA<List>());
          count++;
          if (count >= 1) break; // Just check one
        } else if (result == null) {
          // Checkmate - no moves available
          break;
        }
        // false means still searching, continue
        if (count >= 10) break; // Limit iterations
      }
    });

    test('should handle game state queries', () {
      // Test that we can query the game state through the interface
      final timeline = game.getTimeline(0);
      expect(timeline, isNotNull);

      final board = timeline.getCurrentBoard();
      expect(board, isNotNull);

      // Verify that moves can be generated
      final moves = HypercuboidInterface.movesFrom(game, 0);
      expect(moves, isA<List>());
    });
  });
}
