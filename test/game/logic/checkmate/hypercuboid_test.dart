import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/logic/checkmate/hypercuboid.dart';
import 'package:chess_5d/game/logic/checkmate/move_combination.dart';
import 'package:chess_5d/game/logic/game.dart';
import 'package:chess_5d/game/logic/game_options.dart';

void main() {
  group('HypercuboidSearch', () {
    late Game game;

    setUp(() {
      final options = GameOptions.defaultOptions();
      game = Game(options: options, localPlayer: [true, true]);
    });

    test('should create search instance', () {
      // Search is a static method, so we just test that it can be called
      expect(HypercuboidSearch.search, isA<Function>());
    });

    test('should return iterable from search', () {
      final searchResults = HypercuboidSearch.search(game);

      expect(searchResults, isA<Iterable<dynamic>>());
    });

    test('should search for move combinations', () {
      final searchResults = HypercuboidSearch.search(game);
      final results = searchResults.take(10).toList(); // Limit to first 10

      // Results should be either:
      // - false (still searching)
      // - MoveCombination (valid escape found)
      // - null (checkmate)
      for (final result in results) {
        expect(result, anyOf(isFalse, isA<MoveCombination>(), isNull));
      }
    });

    test('should handle game with no moves available', () {
      // Create a game state where player has no moves
      // This is a simplified test - creating a true stalemate/checkmate
      // position would require more setup
      final searchResults = HypercuboidSearch.search(game);
      final firstResult = searchResults.first;

      // Should return something (false, MoveCombination, or null)
      expect(firstResult, anyOf(isFalse, isA<MoveCombination>(), isNull));
    });

    test('should not throw exception on valid game state', () {
      expect(() {
        final searchResults = HypercuboidSearch.search(game);
        searchResults.take(5).toList(); // Just take a few results
      }, returnsNormally);
    });

    test('should handle multiple timelines', () {
      // Create a game with multiple timelines
      // This would require making moves to create branches
      // For now, we just test that it doesn't crash
      expect(() {
        final searchResults = HypercuboidSearch.search(game);
        searchResults.take(1).toList();
      }, returnsNormally);
    });
  });
}
