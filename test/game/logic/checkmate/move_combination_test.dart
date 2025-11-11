import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/logic/checkmate/move_combination.dart';
import 'package:chess_5d/game/logic/position.dart';
import 'package:chess_5d/game/logic/game.dart';
import 'package:chess_5d/game/logic/game_options.dart';
import 'package:chess_5d/game/logic/board.dart';
import 'package:chess_5d/game/logic/piece.dart';

void main() {
  group('MoveCombination', () {
    late Game game;
    late Board board;
    late Piece piece;

    setUp(() {
      final options = GameOptions.defaultOptions();
      game = Game(options: options, localPlayer: [true, true]);
      board = game.getTimeline(0).getBoard(0)!;
      piece = board.getPiece(0, 6)!; // White pawn
    });

    test('should create a move combination with moves', () {
      // Create a simple move
      final move = game.instantiateMove(
        piece,
        const Vec4(0, 5, 0, 1), // Move pawn forward
        null,
        false,
        false,
      );

      final combination = MoveCombination([move]);

      expect(combination.moves.length, 1);
      expect(combination.moves.first, move);
    });

    test('should create a move combination with multiple moves', () {
      // Create multiple moves
      final move1 = game.instantiateMove(
        piece,
        const Vec4(0, 5, 0, 1),
        null,
        false,
        false,
      );

      final piece2 = board.getPiece(1, 6)!; // Another white pawn
      final move2 = game.instantiateMove(
        piece2,
        const Vec4(1, 5, 0, 1),
        null,
        false,
        false,
      );

      final combination = MoveCombination([move1, move2]);

      expect(combination.moves.length, 2);
      expect(combination.moves, contains(move1));
      expect(combination.moves, contains(move2));
    });

    test('should serialize move combination', () {
      final move = game.instantiateMove(
        piece,
        const Vec4(0, 5, 0, 1),
        null,
        false,
        false,
      );

      final combination = MoveCombination([move]);
      final serialized = combination.toSerializable();

      expect(serialized.length, 1);
      expect(serialized[0], isA<Map<String, dynamic>>());
      expect(serialized[0]['from'], isNotNull);
      expect(serialized[0]['to'], isNotNull);
    });

    test('should have string representation', () {
      final move = game.instantiateMove(
        piece,
        const Vec4(0, 5, 0, 1),
        null,
        false,
        false,
      );

      final combination = MoveCombination([move]);
      final str = combination.toString();

      expect(str, contains('MoveCombination'));
      expect(str, contains('1 moves'));
    });

    test('should handle empty move combination', () {
      final combination = MoveCombination([]);

      expect(combination.moves.isEmpty, true);
      expect(combination.toSerializable().isEmpty, true);
    });
  });

  group('AxisLocationType', () {
    test('should have all required location types', () {
      expect(AxisLocationType.physical, AxisLocationType.physical);
      expect(AxisLocationType.leave, AxisLocationType.leave);
      expect(AxisLocationType.arrive, AxisLocationType.arrive);
      expect(AxisLocationType.pass, AxisLocationType.pass);
    });
  });
}

