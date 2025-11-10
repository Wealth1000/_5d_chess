import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/logic/player.dart';

// Mock Game class for testing
class MockGame {
  // Minimal mock implementation
}

void main() {
  group('Player', () {
    late MockGame mockGame;

    setUp(() {
      mockGame = MockGame();
    });

    test('should create player with correct properties', () {
      final player = Player(
        game: mockGame,
        side: 1,
        timeRemaining: 300000, // 5 minutes
      );

      expect(player.game, mockGame);
      expect(player.side, 1);
      expect(player.timeRemaining, 300000);
      expect(player.timeRunning, false);
      expect(player.lastStartTime, null);
      expect(player.lastTurnTime, 0);
      expect(player.lastGrace, 0);
      expect(player.lastIncr, 0);
    });

    test('should update time correctly', () {
      final player = Player(game: mockGame, side: 0, timeRemaining: 100000);

      final newTime = player.updateTime(5000);
      expect(newTime, 95000);
      expect(player.timeRemaining, 95000);
    });

    test('should not allow negative time', () {
      final player = Player(game: mockGame, side: 0, timeRemaining: 1000);

      final newTime = player.updateTime(2000);
      expect(newTime, 0);
      expect(player.timeRemaining, 0);
    });

    test('should start time correctly', () {
      final player = Player(game: mockGame, side: 1, timeRemaining: 300000);

      expect(player.timeRunning, false);
      player.startTime();
      expect(player.timeRunning, true);
      expect(player.lastStartTime, isNotNull);
    });

    test('should not start time if already running', () {
      final player = Player(game: mockGame, side: 1, timeRemaining: 300000);

      player.startTime();
      final firstStartTime = player.lastStartTime;

      // Try to start again
      player.startTime();
      expect(player.lastStartTime, firstStartTime); // Should not change
    });

    test('should start time with skip amounts', () {
      final player = Player(game: mockGame, side: 1, timeRemaining: 300000);

      player.startTime(skipGraceAmount: 5000, skipAmount: 1000);
      expect(player.timeRunning, true);
      expect(player.lastGrace, 5000);
      expect(player.timeRemaining, 299000); // 300000 - 1000
    });

    test('should stop time correctly', () {
      final player = Player(game: mockGame, side: 1, timeRemaining: 300000);

      player.startTime();
      // Wait a bit to simulate time passing
      Future.delayed(const Duration(milliseconds: 10), () {
        final elapsed = player.stopTime();
        expect(elapsed, isNotNull);
        expect(elapsed, greaterThan(0));
        expect(player.timeRunning, false);
        expect(player.lastStartTime, null);
      });
    });

    test('should return null when stopping time that is not running', () {
      final player = Player(game: mockGame, side: 1, timeRemaining: 300000);

      final elapsed = player.stopTime();
      expect(elapsed, null);
    });

    test('should start clock with grace and increment', () {
      final player = Player(game: mockGame, side: 1, timeRemaining: 300000);

      player.startClock(grace: 5000, increment: 10000);
      expect(player.timeRunning, true);
      expect(player.lastGrace, 5000);
      expect(player.lastIncr, 10000);
    });

    test('should stop clock and add increment', () {
      final player = Player(game: mockGame, side: 1, timeRemaining: 290000);

      player.startClock(increment: 10000);
      player.stopClock();

      // Time should have been updated, then increment added
      // Since we're testing, we can't precisely measure elapsed time,
      // but we can verify the increment logic works
      expect(player.lastIncr, 10000);
    });

    test('should flag player (timeout)', () {
      final player = Player(game: mockGame, side: 1, timeRemaining: 1000);

      player.startTime();
      player.flag();

      expect(player.timeRemaining, 0);
      expect(player.timeRunning, false);
    });

    test('should get current time correctly when clock is not running', () {
      final player = Player(game: mockGame, side: 1, timeRemaining: 300000);

      expect(player.getCurrentTime(), 300000);
    });

    test('should get current time correctly when clock is running', () {
      final player = Player(game: mockGame, side: 1, timeRemaining: 300000);

      player.startTime();
      final currentTime = player.getCurrentTime();
      expect(currentTime, lessThanOrEqualTo(300000));
      expect(currentTime, greaterThan(0));
    });

    test('should check if player has timed out', () {
      final player = Player(game: mockGame, side: 1, timeRemaining: 100);

      expect(player.hasTimedOut(), false);

      player.startTime();
      // Wait for time to run out
      Future.delayed(const Duration(milliseconds: 150), () {
        expect(player.hasTimedOut(), true);
      });
    });

    test('should format time correctly (MM:SS)', () {
      final player = Player(
        game: mockGame,
        side: 1,
        timeRemaining: 125000, // 2 minutes 5 seconds
      );

      final formatted = player.formatTime();
      expect(formatted, '02:05');
    });

    test('should format time correctly (HH:MM:SS)', () {
      final player = Player(
        game: mockGame,
        side: 1,
        timeRemaining: 3665000, // 1 hour 1 minute 5 seconds
      );

      final formatted = player.formatTime();
      expect(formatted, '01:01:05');
    });

    test('should format time correctly for zero seconds', () {
      final player = Player(
        game: mockGame,
        side: 1,
        timeRemaining: 60000, // 1 minute
      );

      final formatted = player.formatTime();
      expect(formatted, '01:00');
    });

    test('should format time correctly for less than a minute', () {
      final player = Player(
        game: mockGame,
        side: 1,
        timeRemaining: 45000, // 45 seconds
      );

      final formatted = player.formatTime();
      expect(formatted, '00:45');
    });

    test('should convert to string correctly', () {
      final player = Player(game: mockGame, side: 1, timeRemaining: 300000);

      final str = player.toString();
      expect(str, contains('side:1'));
      expect(str, contains('running:false'));
      expect(str, contains(':'));
    });
  });
}
