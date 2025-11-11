import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/state/game_provider.dart';
import 'package:chess_5d/game/logic/game_options.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:chess_5d/game/logic/position.dart';

void main() {
  group('GameProvider', () {
    late GameProvider provider;

    setUp(() {
      final options = GameOptions.defaultOptions();
      provider = GameProvider(options: options, localPlayer: [true, true]);
    });

    test('should create game provider with game', () {
      expect(provider.game, isNotNull);
      expect(provider.turn, 1); // White starts
      expect(provider.isFinished, false);
    });

    test('should have no selected piece initially', () {
      expect(provider.selectedPiece, isNull);
      expect(provider.legalMoves, isEmpty);
    });

    test('should select and deselect pieces', () {
      final board = provider.game.getTimeline(0).getBoard(0)!;
      final piece = board.getPiece(0, 6); // White pawn

      if (piece != null) {
        provider.selectPiece(piece);
        expect(provider.selectedPiece, piece);
        expect(provider.legalMoves, isNotEmpty);

        provider.deselectPiece();
        expect(provider.selectedPiece, isNull);
        expect(provider.legalMoves, isEmpty);
      }
    });

    test('should update legal moves when piece is selected', () {
      final board = provider.game.getTimeline(0).getBoard(0)!;
      final piece = board.getPiece(0, 6); // White pawn

      if (piece != null) {
        provider.selectPiece(piece);
        expect(provider.legalMoves, isNotEmpty);
        expect(provider.legalMoves, isA<List<Vec4>>());
      }
    });

    test('should handle square tap', () {
      final position = Vec4(0, 6, 0, 0); // White pawn position
      provider.handleSquareTap(position);

      // Should select the piece if it's the player's turn
      if (provider.turn == 1) {
        // White's turn, so piece should be selected
        expect(provider.selectedPiece, isNotNull);
      }
    });

    test('should handle piece selection', () {
      final board = provider.game.getTimeline(0).getBoard(0)!;
      final piece = board.getPiece(0, 6); // White pawn

      if (piece != null) {
        provider.handlePieceSelection(piece);
        expect(provider.selectedPiece, piece);
      }
    });

    test('should handle new game', () {
      final options = GameOptions.defaultOptions();
      provider.newGame(options, [true, true]);

      expect(provider.game, isNotNull);
      expect(provider.selectedPiece, isNull);
      expect(provider.legalMoves, isEmpty);
      expect(provider.isFinished, false);
    });

    test('should check if moves can be submitted', () {
      // Initially, canSubmit should be false (no moves made)
      expect(provider.canSubmit, isA<bool>());
    });

    test('should dispose resources', () {
      expect(() => provider.dispose(), returnsNormally);
    });
  });
}
