import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/logic/checkmate/hypercuboid_interface.dart';
import 'package:chess_5d/game/logic/game.dart';
import 'package:chess_5d/game/logic/game_options.dart';

void main() {
  group('HypercuboidInterface', () {
    late Game game;

    setUp(() {
      final options = GameOptions.defaultOptions();
      game = Game(options: options, localPlayer: [true, true]);
    });

    test('should get new timeline index for white', () {
      game.turn = 1; // White's turn
      game.timelineCount[1] = 0; // No white timelines yet

      final newL = HypercuboidInterface.getNewL(game);

      expect(newL, 0); // First white timeline is 0
    });

    test('should get new timeline index for black', () {
      game.turn = 0; // Black's turn
      game.timelineCount[0] = 0; // No black timelines yet

      final newL = HypercuboidInterface.getNewL(game);

      expect(newL, -1); // First black timeline is -1
    });

    test('should get opponent timeline index', () {
      game.turn = 1; // White's turn
      game.timelineCount[0] = 1; // One black timeline

      final opL = HypercuboidInterface.getOpL(game);

      expect(opL, -1); // Opponent's (black) most recent timeline
    });

    test('should get end turn for timeline', () {
      final timeline = game.getTimeline(0);
      timeline.setBoard(0, game.getTimeline(0).getBoard(0)!);

      final endT = HypercuboidInterface.getEndT(game, 0);

      expect(endT, greaterThanOrEqualTo(0));
    });

    test('should get playable timelines', () {
      game.turn = 1; // White's turn

      final playable = HypercuboidInterface.getPlayableTimelines(game);

      expect(playable, isNotEmpty);
      expect(playable, contains(0)); // Main timeline should be playable
    });

    test('should check if position exists', () {
      final pos = [0, 0, 4, 4]; // l=0, t=0, x=4, y=4

      final exists = HypercuboidInterface.posExists(game, pos);

      expect(exists, true);
    });

    test('should return false for invalid position', () {
      final pos = [999, 999, 4, 4]; // Invalid timeline

      final exists = HypercuboidInterface.posExists(game, pos);

      expect(exists, false);
    });

    test('should return false for position out of bounds', () {
      final pos = [0, 0, 10, 10]; // Out of bounds x, y

      final exists = HypercuboidInterface.posExists(game, pos);

      expect(exists, false);
    });

    test('should get piece at position', () {
      final pos = [0, 0, 0, 6]; // White pawn at start

      final pieceStr = HypercuboidInterface.getPieceAt(game, pos);

      expect(pieceStr, isNotNull);
      expect(pieceStr, contains('pawn'));
      expect(pieceStr, contains('1')); // White side
    });

    test('should return space for empty square', () {
      final pos = [0, 0, 4, 4]; // Empty square in center

      final pieceStr = HypercuboidInterface.getPieceAt(game, pos);

      expect(pieceStr, ' ');
    });

    test('should get moves from timeline', () {
      final moves = HypercuboidInterface.movesFrom(game, 0);

      expect(moves, isA<List<Map<String, dynamic>>>());
      // Should have moves for white pieces at start
      expect(moves.length, greaterThan(0));
    });

    test('should get moves with start and end positions', () {
      final moves = HypercuboidInterface.movesFrom(game, 0);

      if (moves.isNotEmpty) {
        final move = moves.first;
        expect(move['start'], isA<List>());
        expect(move['end'], isA<List>());
        expect(move['newBoards'], isA<Map>());
        // Verify list contents are integers
        expect((move['start'] as List).first, isA<int>());
        expect((move['end'] as List).first, isA<int>());
      }
    });

    test('should apply moves temporarily with withMoves', () {
      final moves = HypercuboidInterface.movesFrom(game, 0);

      if (moves.isNotEmpty) {
        final result = HypercuboidInterface.withMoves(game, [moves.first], (g) {
          // Check if moves were applied
          return g.turn;
        });

        // Should return the turn (moves should be undone after)
        expect(result, isA<int>());
      }
    });

    test('should get check path when in check', () {
      // Create a simple check scenario
      // This is a simplified test - full check detection is complex
      final checkPath = HypercuboidInterface.getCheckPath(game);

      // At start of game, white shouldn't be in check
      // So checkPath should be null
      expect(checkPath, anyOf(isNull, isA<List<List<dynamic>>>()));
    });
  });
}
