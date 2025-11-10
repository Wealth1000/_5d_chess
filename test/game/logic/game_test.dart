import 'package:chess_5d/game/logic/game.dart';
import 'package:chess_5d/game/logic/game_options.dart';
import 'package:chess_5d/game/logic/position.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Game', () {
    late GameOptions defaultOptions;
    late List<bool> localPlayers;

    setUp(() {
      defaultOptions = GameOptions.defaultOptions();
      localPlayers = [true, true]; // Both players local
    });

    test('should create game with default options', () {
      final game = Game(options: defaultOptions, localPlayer: localPlayers);

      expect(game.options, defaultOptions);
      expect(game.turn, 1); // White starts
      expect(game.finished, false);
      expect(game.canSubmit, false);
      expect(game.players.length, 2);
      expect(game.timelines.length, 2); // Negative and positive timelines
    });

    test('should initialize main timeline', () {
      final game = Game(options: defaultOptions, localPlayer: localPlayers);

      final mainTimeline = game.getTimeline(0);
      expect(mainTimeline, isNotNull);
      expect(mainTimeline.l, 0);
      expect(mainTimeline.isActive, true);
    });

    test('should have initial board with pieces', () {
      final game = Game(options: defaultOptions, localPlayer: localPlayers);

      final mainTimeline = game.getTimeline(0);
      final initialBoard = mainTimeline.getBoard(0);
      expect(initialBoard, isNotNull);

      // Check that pieces are placed
      // White king should be at (4, 7)
      final whiteKing = initialBoard!.getPiece(4, 7);
      expect(whiteKing, isNotNull);
      expect(whiteKing!.type, PieceType.king);
      expect(whiteKing.side, PieceSide.white);

      // Black king should be at (4, 0)
      final blackKing = initialBoard.getPiece(4, 0);
      expect(blackKing, isNotNull);
      expect(blackKing!.type, PieceType.king);
      expect(blackKing.side, PieceSide.black);
    });

    test('should get timeline by index', () {
      final game = Game(options: defaultOptions, localPlayer: localPlayers);

      final timeline0 = game.getTimeline(0);
      expect(timeline0.l, 0);

      // Getting a non-existent timeline should create it
      final timeline1 = game.getTimeline(1);
      expect(timeline1.l, 1);

      final timelineNeg1 = game.getTimeline(-1);
      expect(timelineNeg1.l, -1);
    });

    test('should get piece at position', () {
      final game = Game(options: defaultOptions, localPlayer: localPlayers);

      // Get white king at (4, 7) on timeline 0, turn 0
      const whiteKingPos = Vec4(4, 7, 0, 0);
      final whiteKing = game.getPiece(whiteKingPos);
      expect(whiteKing, isNotNull);
      expect(whiteKing!.type, PieceType.king);
      expect(whiteKing.side, PieceSide.white);

      // Get black king at (4, 0) on timeline 0, turn 0
      const blackKingPos = Vec4(4, 0, 0, 0);
      final blackKing = game.getPiece(blackKingPos);
      expect(blackKing, isNotNull);
      expect(blackKing!.type, PieceType.king);
      expect(blackKing.side, PieceSide.black);

      // Get empty square
      const emptyPos = Vec4(4, 4, 0, 0);
      final emptyPiece = game.getPiece(emptyPos);
      expect(emptyPiece, isNull);
    });

    test('should calculate present correctly', () {
      final game = Game(options: defaultOptions, localPlayer: localPlayers);

      // Initially, present should be 0 (the initial board)
      game.movePresent(true);
      expect(game.present, 0);
    });

    test('should find checks on initial board', () {
      final game = Game(options: defaultOptions, localPlayer: localPlayers);

      // Initially, there should be no checks
      final hasChecks = game.findChecks();
      expect(hasChecks, false);
    });

    test('should check submit availability', () {
      final game = Game(options: defaultOptions, localPlayer: localPlayers);

      // Initially, submit should not be available
      final canSubmit = game.checkSubmitAvailable();
      expect(canSubmit, false);
    });

    test('should create players with correct time', () {
      final timeControl = TimeControl.equal(300000, incrementMs: 5000);
      final options = GameOptions.defaultOptions();
      final game = Game(
        options: GameOptions(
          time: timeControl,
          players: options.players,
          variant: options.variant,
        ),
        localPlayer: localPlayers,
      );

      expect(game.players[0].timeRemaining, timeControl.start[0]);
      expect(game.players[1].timeRemaining, timeControl.start[1]);
    });

    test('should initialize timeline counts', () {
      final game = Game(options: defaultOptions, localPlayer: localPlayers);

      expect(game.timelineCount[0], 0); // Black timelines
      expect(game.timelineCount[1], 0); // White timelines (0 is main, not counted)
    });

    test('should have empty current turn moves initially', () {
      final game = Game(options: defaultOptions, localPlayer: localPlayers);

      expect(game.currentTurnMoves, isEmpty);
    });

    test('should have empty displayed checks initially', () {
      final game = Game(options: defaultOptions, localPlayer: localPlayers);

      expect(game.displayedChecks, isEmpty);
    });

    test('should handle game with finished flag', () {
      final options = GameOptions(
        time: TimeControl.unlimited(),
        players: [
          PlayerInfo(name: 'Black', side: 0),
          PlayerInfo(name: 'White', side: 1),
        ],
        variant: 'Standard',
        finished: true,
        winner: 1, // White wins
        winCause: 1,
        winReason: 'checkmate',
      );

      final game = Game(options: options, localPlayer: localPlayers);

      expect(game.finished, true);
    });

    test('should handle remote players', () {
      final remotePlayers = [false, true]; // Black remote, White local

      final game = Game(options: defaultOptions, localPlayer: remotePlayers);

      expect(game.localPlayer, remotePlayers);
    });

    test('should instantiate move', () {
      final game = Game(options: defaultOptions, localPlayer: localPlayers);

      final whiteKing = game.getPiece(const Vec4(4, 7, 0, 0))!;
      const targetPos = Vec4(4, 6, 0, 1);

      final move = game.instantiateMove(
        whiteKing,
        targetPos,
        null,
        false,
        false,
      );

      expect(move.sourcePiece, whiteKing);
      expect(move.to, targetPos);
      expect(move.nullMove, false);
    });

    test('should instantiate timeline', () {
      final game = Game(options: defaultOptions, localPlayer: localPlayers);

      final timeline = game.instantiateTimeline(1, 0, null, true);

      expect(timeline.l, 1);
      expect(timeline.start, 0);
      expect(timeline.game, game);
    });

    test('should instantiate board', () {
      final game = Game(options: defaultOptions, localPlayer: localPlayers);

      final board = game.instantiateBoard(0, 1, 0, null, true);

      expect(board.l, 0);
      expect(board.t, 1);
      expect(board.turn, 0);
      expect(board.game, game);
    });

    test('should instantiate player', () {
      final game = Game(options: defaultOptions, localPlayer: localPlayers);

      final player = game.instantiatePlayer(0);

      expect(player.side, 0);
      expect(player.game, game);
    });

    test('should end game', () {
      final game = Game(options: defaultOptions, localPlayer: localPlayers);

      game.end(1, 1, 'checkmate', false);

      expect(game.finished, true);
    });

    test('should destroy game', () {
      final game = Game(options: defaultOptions, localPlayer: localPlayers);

      // Should not throw
      game.destroy();
    });

    test('should handle getPiece with invalid coordinates', () {
      final game = Game(options: defaultOptions, localPlayer: localPlayers);

      // Invalid x coordinate
      final invalidX = game.getPiece(const Vec4(-1, 4, 0, 0));
      expect(invalidX, isNull);

      // Invalid y coordinate
      final invalidY = game.getPiece(const Vec4(4, 8, 0, 0));
      expect(invalidY, isNull);
    });

    test('should handle getPiece with non-existent timeline', () {
      final game = Game(options: defaultOptions, localPlayer: localPlayers);

      // Timeline should be created on access
      final piece = game.getPiece(const Vec4(4, 4, 5, 0));
      expect(piece, isNull); // Empty square, but timeline exists
    });
  });
}

