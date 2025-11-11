import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/state/game_state_model.dart';
import 'package:chess_5d/game/logic/game.dart';
import 'package:chess_5d/game/logic/game_options.dart';

void main() {
  group('GameStateModel', () {
    late Game game;
    late GameStateModel model;

    setUp(() {
      final options = GameOptions.defaultOptions();
      game = Game(options: options, localPlayer: [true, true]);
      model = GameStateModel.fromGame(game);
    });

    test('should create model from game', () {
      expect(model.options, game.options);
      expect(model.localPlayer, game.localPlayer);
      expect(model.turn, game.turn);
      expect(model.present, game.present);
      expect(model.finished, game.finished);
    });

    test('should serialize to JSON', () {
      final json = model.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['options'], isA<Map<String, dynamic>>());
      expect(json['localPlayer'], isA<List>());
      expect(json['turn'], isA<int>());
      expect(json['present'], isA<int>());
      expect(json['finished'], isA<bool>());
      expect(json['moves'], isA<List>());
      expect(json['currentTurnMoves'], isA<List>());
    });

    test('should deserialize from JSON', () {
      final json = model.toJson();
      final deserialized = GameStateModel.fromJson(json);

      expect(deserialized.options.variant, model.options.variant);
      expect(deserialized.localPlayer, model.localPlayer);
      expect(deserialized.turn, model.turn);
      expect(deserialized.present, model.present);
      expect(deserialized.finished, model.finished);
    });

    test('should handle empty moves', () {
      expect(model.moves, isEmpty);
      expect(model.currentTurnMoves, isEmpty);
    });

    test('should create model with custom values', () {
      final customModel = GameStateModel(
        options: GameOptions.defaultOptions(),
        localPlayer: [true, false],
        turn: 0,
        present: 5,
        finished: false,
        moves: [],
        currentTurnMoves: [],
      );

      expect(customModel.localPlayer, [true, false]);
      expect(customModel.turn, 0);
      expect(customModel.present, 5);
      expect(customModel.finished, false);
    });
  });
}

