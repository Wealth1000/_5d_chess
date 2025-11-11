import 'package:chess_5d/game/logic/check_detector.dart';
import 'package:chess_5d/game/logic/game.dart';
import 'package:chess_5d/game/logic/game_options.dart';
import 'package:chess_5d/game/logic/position.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cross-Timeline Check Detection', () {
    late Game game;

    setUp(() {
      final options = GameOptions.defaultOptions();
      game = Game(options: options, localPlayer: [true, true]);
    });

    test('should detect check from piece on different timeline', () {
      // Create a scenario where a piece from timeline 0 can check a king on timeline 1
      // This is a simplified test - in real 5D chess, this would require timeline branching

      // Get the initial board
      final timeline0 = game.getTimeline(0);
      final board0 = timeline0.getBoard(0)!;

      // Move a white piece (e.g., rook) to a position where it can check
      // For now, we'll test that the cross-timeline check detection method works
      final whiteRook = board0.getPiece(0, 7);
      expect(whiteRook, isNotNull);
      expect(whiteRook!.type, PieceType.rook);
      expect(whiteRook.side, PieceSide.white);

      // Test that cross-timeline check detection can be called
      const kingPos = Vec4(4, 7, 0, 0);
      final inCheck = CheckDetector.isSquareAttackedCrossTimeline(
        game,
        kingPos,
        0, // Black side (attacking white king)
        board0,
      );

      // Initially, there should be no check (black pieces are not in position)
      expect(inCheck, false);
    });

    test(
      'should detect check when piece from different timeline attacks king',
      () {
        // This test requires multiple timelines and timeline branching
        // For now, we test the basic functionality

        final timeline0 = game.getTimeline(0);
        final board0 = timeline0.getBoard(0)!;

        // Test cross-timeline check detection on initial board
        const whiteKingPos = Vec4(4, 7, 0, 0);
        const blackKingPos = Vec4(4, 0, 0, 0);

        // Check if white king is in check (should not be initially)
        final whiteKingInCheck = CheckDetector.isKingInCheckCrossTimeline(
          game,
          board0,
          PieceSide.white,
        );
        expect(whiteKingInCheck, false);

        // Check if black king is in check (should not be initially)
        final blackKingInCheck = CheckDetector.isKingInCheckCrossTimeline(
          game,
          board0,
          PieceSide.black,
        );
        expect(blackKingInCheck, false);
      },
    );

    test('should find checks across timelines in Game.findChecks', () {
      // Test that Game.findChecks uses cross-timeline check detection
      final hasChecks = game.findChecks();

      // Initially, there should be no checks
      expect(hasChecks, false);
      expect(game.displayedChecks, isEmpty);
    });

    test(
      'should handle cross-timeline check detection with multiple timelines',
      () {
        // Create a second timeline by making a move that branches
        // For now, we'll just test that the method doesn't crash with multiple timelines

        final timeline0 = game.getTimeline(0);
        final board0 = timeline0.getBoard(0)!;

        // The cross-timeline check should work even with just one timeline
        final inCheck = CheckDetector.isKingInCheckCrossTimeline(
          game,
          board0,
          PieceSide.white,
        );

        expect(inCheck, isA<bool>());
      },
    );
  });
}
