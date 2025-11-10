import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/logic/move.dart';
import 'package:chess_5d/game/logic/board.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:chess_5d/game/logic/position.dart';

// Mock Game class for testing
class MockGame {
  // Minimal mock implementation
}

void main() {
  group('Move', () {
    late MockGame mockGame;
    late Board mockBoard;
    late Piece mockPiece;

    setUp(() {
      mockGame = MockGame();
      mockBoard = Board(game: mockGame, l: 0, t: 0, turn: 1);
      mockPiece = Piece(
        game: mockGame,
        board: mockBoard,
        side: 1,
        x: 3,
        y: 4,
        type: PieceType.rook,
      );
      mockBoard.setPiece(3, 4, mockPiece);
    });

    test('should create regular move correctly', () {
      const targetPos = Vec4(5, 4, 0, 0);
      final move = Move(
        game: mockGame,
        sourcePiece: mockPiece,
        targetPos: targetPos,
      );

      expect(move.game, mockGame);
      expect(move.sourcePiece, mockPiece);
      expect(move.to, targetPos);
      expect(move.from, const Vec4(3, 4, 0, 0));
      expect(move.nullMove, false);
      expect(move.isInterDimensionalMove, false);
      expect(move.sourceBoard, mockBoard);
      expect(move.promote, null);
      expect(move.remoteMove, false);
    });

    test('should create inter-dimensional move correctly', () {
      const targetPos = Vec4(5, 4, 1, 0); // Different timeline
      final move = Move(
        game: mockGame,
        sourcePiece: mockPiece,
        targetPos: targetPos,
      );

      expect(move.isInterDimensionalMove, true);
      expect(move.from, const Vec4(3, 4, 0, 0));
      expect(move.to, targetPos);
    });

    test('should create move with promotion', () {
      const targetPos = Vec4(5, 4, 0, 0);
      final move = Move(
        game: mockGame,
        sourcePiece: mockPiece,
        targetPos: targetPos,
        promotionTo: 1, // Queen
      );

      expect(move.promote, 1);
      expect(move.getPromotionTypeName(), 'queen');
    });

    test('should create move with remote flag', () {
      const targetPos = Vec4(5, 4, 0, 0);
      final move = Move(
        game: mockGame,
        sourcePiece: mockPiece,
        targetPos: targetPos,
        remoteMove: true,
      );

      expect(move.remoteMove, true);
    });

    test('should throw error when creating move with piece not on board', () {
      final pieceWithoutBoard = Piece(
        game: mockGame,
        board: mockBoard,
        side: 1,
        x: 0,
        y: 0,
        type: PieceType.rook,
      );
      pieceWithoutBoard.board = null;

      expect(
        () => Move(
          game: mockGame,
          sourcePiece: pieceWithoutBoard,
          targetPos: const Vec4(1, 0, 0, 0),
        ),
        throwsStateError,
      );
    });

    test('should create null move correctly', () {
      final nullMove = Move.nullMove(mockGame, mockBoard);

      expect(nullMove.game, mockGame);
      expect(nullMove.sourcePiece, null);
      expect(nullMove.from, null);
      expect(nullMove.to, null);
      expect(nullMove.nullMove, true);
      expect(nullMove.isInterDimensionalMove, false);
      expect(nullMove.l, 0); // Timeline index from board
      expect(nullMove.promote, null);
      expect(nullMove.remoteMove, false);
    });

    test('should serialize move to JSON correctly', () {
      const targetPos = Vec4(5, 4, 0, 0);
      final move = Move(
        game: mockGame,
        sourcePiece: mockPiece,
        targetPos: targetPos,
        promotionTo: 1,
        remoteMove: true,
      );

      final json = move.serialize();
      expect(json['from'], isNotNull);
      expect(json['to'], isNotNull);
      expect(json['sourcePiece'], isNotNull);
      expect(json['sourcePiece']!['type'], PieceType.rook);
      expect(json['sourcePiece']!['side'], 1);
      expect(json['promote'], 1);
      expect(json['remoteMove'], true);
      expect(json['nullMove'], false);
      expect(json['isInterDimensionalMove'], false);
    });

    test('should serialize null move to JSON correctly', () {
      final nullMove = Move.nullMove(mockGame, mockBoard);
      final json = nullMove.serialize();

      expect(json['from'], null);
      expect(json['to'], null);
      expect(json['sourcePiece'], null);
      expect(json['nullMove'], true);
      expect(json['l'], 0);
    });

    test('should deserialize null move from JSON', () {
      final json = {'nullMove': true, 'l': 0, 'remoteMove': false};

      final nullMove = Move.fromSerialized(mockGame, json);

      expect(nullMove.nullMove, true);
      expect(nullMove.l, 0);
      expect(nullMove.sourcePiece, null);
    });

    test(
      'should throw error when deserializing null move without timeline index',
      () {
        final json = {'nullMove': true, 'remoteMove': false};

        expect(() => Move.fromSerialized(mockGame, json), throwsArgumentError);
      },
    );

    test('should throw UnimplementedError when deserializing regular move', () {
      final json = {
        'nullMove': false,
        'to': {'x': 5, 'y': 4, 'l': 0, 't': 0},
        'from': {'x': 3, 'y': 4, 'l': 0, 't': 0},
      };

      expect(
        () => Move.fromSerialized(mockGame, json),
        throwsUnimplementedError,
      );
    });

    test(
      'should throw ArgumentError when deserializing regular move without target',
      () {
        final json = {
          'nullMove': false,
          'from': {'x': 3, 'y': 4, 'l': 0, 't': 0},
        };

        expect(() => Move.fromSerialized(mockGame, json), throwsArgumentError);
      },
    );

    test('should get promotion type name correctly', () {
      final move1 = Move(
        game: mockGame,
        sourcePiece: mockPiece,
        targetPos: const Vec4(5, 4, 0, 0),
        promotionTo: 1,
      );
      expect(move1.getPromotionTypeName(), 'queen');

      final move2 = Move(
        game: mockGame,
        sourcePiece: mockPiece,
        targetPos: const Vec4(5, 4, 0, 0),
        promotionTo: 2,
      );
      expect(move2.getPromotionTypeName(), 'knight');

      final move3 = Move(
        game: mockGame,
        sourcePiece: mockPiece,
        targetPos: const Vec4(5, 4, 0, 0),
        promotionTo: 3,
      );
      expect(move3.getPromotionTypeName(), 'rook');

      final move4 = Move(
        game: mockGame,
        sourcePiece: mockPiece,
        targetPos: const Vec4(5, 4, 0, 0),
        promotionTo: 4,
      );
      expect(move4.getPromotionTypeName(), 'bishop');

      final move5 = Move(
        game: mockGame,
        sourcePiece: mockPiece,
        targetPos: const Vec4(5, 4, 0, 0),
      );
      expect(move5.getPromotionTypeName(), null);
    });

    test('should convert to string correctly', () {
      final move = Move(
        game: mockGame,
        sourcePiece: mockPiece,
        targetPos: const Vec4(5, 4, 0, 0),
      );

      final str = move.toString();
      expect(str, contains('Move'));
      expect(str, contains('rook'));
      expect(str, contains('interDim:false'));
    });

    test('should convert null move to string correctly', () {
      final nullMove = Move.nullMove(mockGame, mockBoard);
      final str = nullMove.toString();

      expect(str, contains('Move(null'));
      expect(str, contains('l:0'));
    });

    test('should track used boards and created boards', () {
      const targetPos = Vec4(5, 4, 0, 0);
      final move = Move(
        game: mockGame,
        sourcePiece: mockPiece,
        targetPos: targetPos,
      );

      expect(move.usedBoards, isEmpty);
      expect(move.createdBoards, isEmpty);

      final usedBoard = Board(game: mockGame, l: 0, t: 1, turn: 0);
      move.usedBoards.add(usedBoard);

      expect(move.usedBoards.length, 1);
      expect(move.usedBoards, contains(usedBoard));
    });

    test('should execute and undo move (placeholder)', () {
      const targetPos = Vec4(5, 4, 0, 0);
      final move = Move(
        game: mockGame,
        sourcePiece: mockPiece,
        targetPos: targetPos,
      );

      // Placeholder implementation - just checks that methods exist
      move.execute();
      expect(move.isValid(), true); // Placeholder returns true

      move.undo();
      // After undo, move should still be valid (placeholder)
      expect(move.isValid(), true);
    });
  });
}
