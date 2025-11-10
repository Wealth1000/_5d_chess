import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/logic/timeline.dart';
import 'package:chess_5d/game/logic/board.dart';

// Mock Game class for testing
class MockGame {
  // Minimal mock implementation
}

void main() {
  group('Timeline', () {
    late MockGame mockGame;

    setUp(() {
      mockGame = MockGame();
    });

    test('should create timeline with correct properties', () {
      final timeline = Timeline(game: mockGame, l: 0, t: 0);

      expect(timeline.game, mockGame);
      expect(timeline.l, 0);
      expect(timeline.start, 0);
      expect(timeline.end, 0);
      expect(timeline.isActive, true);
      expect(timeline.boards, isEmpty);
    });

    test('should determine side correctly based on timeline index', () {
      final blackTimeline = Timeline(game: mockGame, l: -1, t: 0);
      final whiteTimeline = Timeline(game: mockGame, l: 1, t: 0);
      final mainTimeline = Timeline(game: mockGame, l: 0, t: 0);

      expect(blackTimeline.side, 0); // Black
      expect(whiteTimeline.side, 1); // White
      expect(mainTimeline.side, 1); // White (0 >= 0)
    });

    test('should get board at turn number', () {
      final timeline = Timeline(game: mockGame, l: 0, t: 0);

      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);
      timeline.setBoard(0, board);

      expect(timeline.getBoard(0), board);
      expect(timeline.getBoard(1), null);
      expect(timeline.getBoard(-1), null);
    });

    test('should set board at turn number', () {
      final timeline = Timeline(game: mockGame, l: 0, t: 0);

      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);
      timeline.setBoard(0, board);

      expect(timeline.getBoard(0), board);
      expect(timeline.end, 0);
      expect(board.timeline, timeline);
    });

    test('should update end when setting board at later turn', () {
      final timeline = Timeline(game: mockGame, l: 0, t: 0);

      final board0 = Board(game: mockGame, l: 0, t: 0, turn: 1);
      final board1 = Board(game: mockGame, l: 0, t: 1, turn: 0);

      timeline.setBoard(0, board0);
      expect(timeline.end, 0);

      timeline.setBoard(1, board1);
      expect(timeline.end, 1);
      expect(timeline.getBoard(1), board1);
    });

    test('should get current board (board at end)', () {
      final timeline = Timeline(game: mockGame, l: 0, t: 0);

      final board0 = Board(game: mockGame, l: 0, t: 0, turn: 1);
      final board1 = Board(game: mockGame, l: 0, t: 1, turn: 0);

      timeline.setBoard(0, board0);
      timeline.setBoard(1, board1);

      expect(timeline.getCurrentBoard(), board1);
    });

    test('should pop last board', () {
      final timeline = Timeline(game: mockGame, l: 0, t: 0);

      final board0 = Board(game: mockGame, l: 0, t: 0, turn: 1);
      final board1 = Board(game: mockGame, l: 0, t: 1, turn: 0);

      timeline.setBoard(0, board0);
      timeline.setBoard(1, board1);

      expect(timeline.end, 1);
      final popped = timeline.pop();
      expect(popped, board1);
      expect(timeline.end, 0);
      expect(timeline.getBoard(1), null);
    });

    test('should return null when popping empty timeline', () {
      final timeline = Timeline(game: mockGame, l: 0, t: 0);

      expect(timeline.pop(), null);
    });

    test('should remove timeline and all boards', () {
      final timeline = Timeline(game: mockGame, l: 0, t: 0);

      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);
      timeline.setBoard(0, board);

      timeline.remove();

      expect(timeline.isActive, false);
      expect(timeline.boards, isEmpty);
      expect(board.deleted, true);
    });

    test('should activate and deactivate timeline', () {
      final timeline = Timeline(game: mockGame, l: 0, t: 0);

      expect(timeline.isActive, true);
      timeline.deactivate();
      expect(timeline.isActive, false);
      timeline.activate();
      expect(timeline.isActive, true);
    });

    test('should check if timeline is ready for submit', () {
      final timeline = Timeline(game: mockGame, l: 0, t: 0);

      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);
      timeline.setBoard(0, board);

      expect(timeline.isSubmitReady(0), true);
      expect(timeline.isSubmitReady(1), false);

      final board1 = Board(game: mockGame, l: 0, t: 1, turn: 0);
      timeline.setBoard(1, board1);

      expect(timeline.isSubmitReady(1), true);
      expect(timeline.isSubmitReady(2), false);

      timeline.deactivate();
      expect(timeline.isSubmitReady(1), false);
    });

    test('should get active boards', () {
      final timeline = Timeline(game: mockGame, l: 0, t: 0);

      final board0 = Board(game: mockGame, l: 0, t: 0, turn: 1);
      final board1 = Board(game: mockGame, l: 0, t: 1, turn: 0);

      timeline.setBoard(0, board0);
      timeline.setBoard(1, board1);

      final activeBoards = timeline.getActiveBoards();
      expect(activeBoards.length, 2);
      expect(activeBoards, contains(board0));
      expect(activeBoards, contains(board1));

      board1.makeInactive();
      final activeBoards2 = timeline.getActiveBoards();
      expect(activeBoards2.length, 1);
      expect(activeBoards2, contains(board0));
      expect(activeBoards2, isNot(contains(board1)));
    });

    test('should get board count', () {
      final timeline = Timeline(game: mockGame, l: 0, t: 0);

      expect(timeline.boardCount, 0);

      final board0 = Board(game: mockGame, l: 0, t: 0, turn: 1);
      timeline.setBoard(0, board0);
      expect(timeline.boardCount, 1);

      final board1 = Board(game: mockGame, l: 0, t: 1, turn: 0);
      timeline.setBoard(1, board1);
      expect(timeline.boardCount, 2);
    });

    test('should handle boards with gaps in turn numbers', () {
      final timeline = Timeline(game: mockGame, l: 0, t: 0);

      final board0 = Board(game: mockGame, l: 0, t: 0, turn: 1);
      final board2 = Board(game: mockGame, l: 0, t: 2, turn: 1);

      timeline.setBoard(0, board0);
      timeline.setBoard(2, board2);

      expect(timeline.getBoard(0), board0);
      expect(timeline.getBoard(1), null);
      expect(timeline.getBoard(2), board2);
      expect(timeline.end, 2);
    });

    test('should convert to string correctly', () {
      final timeline = Timeline(game: mockGame, l: 1, t: 0);

      final str = timeline.toString();
      expect(str, contains('l:1'));
      expect(str, contains('start:0'));
      expect(str, contains('end:0'));
      expect(str, contains('side:1'));
    });
  });
}
