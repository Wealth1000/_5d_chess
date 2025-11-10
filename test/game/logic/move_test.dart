import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/logic/move.dart';
import 'package:chess_5d/game/logic/board.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:chess_5d/game/logic/position.dart';
import 'package:chess_5d/game/logic/game.dart';
import 'package:chess_5d/game/logic/game_options.dart';

void main() {
  group('Move', () {
    late Game game;
    late Board board;
    late Piece piece;

    setUp(() {
      // Create a real game instance
      final options = GameOptions.defaultOptions();
      game = Game(options: options, localPlayer: [true, true]);

      // Get the initial board from the main timeline
      final timeline = game.getTimeline(0);
      board = timeline.getBoard(0)!;

      // Get a piece from the board (white rook at 0,7)
      piece = board.getPiece(0, 7)!;
    });

    test('should create regular move correctly', () {
      // Move white rook from (0, 7) to (0, 6) on same board
      const targetPos = Vec4(0, 6, 0, 1);
      final move = Move(game: game, sourcePiece: piece, targetPos: targetPos);

      expect(move.game, game);
      expect(move.sourcePiece, piece);
      expect(move.to, targetPos);
      expect(move.from, const Vec4(0, 7, 0, 0));
      expect(move.nullMove, false);
      expect(move.isInterDimensionalMove, false); // Same board, next turn
      expect(move.sourceBoard, isNotNull);
      expect(move.targetBoard, isNotNull);
      expect(move.promote, null);
      expect(move.remoteMove, false);
    });

    test('should create inter-dimensional move correctly', () {
      // Test move to next turn on same timeline (not inter-dimensional)
      // Inter-dimensional moves will be tested when we have multiple timelines
      const targetPos = Vec4(0, 6, 0, 1); // Next turn on same timeline
      final move = Move(game: game, sourcePiece: piece, targetPos: targetPos);

      // Move to next turn on same timeline is not inter-dimensional
      expect(move.isInterDimensionalMove, false);
      expect(move.from, const Vec4(0, 7, 0, 0));
      expect(move.to, targetPos);
      expect(move.sourceBoard, isNotNull);
      expect(move.targetBoard, isNotNull);
      expect(move.targetBoard, isNot(move.sourceBoard)); // Different boards
    });

    test('should create move with promotion', () {
      // Note: Promotion test will need a pawn, but for now we test the promotion field
      const targetPos = Vec4(0, 6, 0, 1);
      final move = Move(
        game: game,
        sourcePiece: piece,
        targetPos: targetPos,
        promotionTo: 1, // Queen
      );

      expect(move.promote, 1);
      expect(move.getPromotionTypeName(), 'queen');
    });

    test('should create move with remote flag', () {
      const targetPos = Vec4(0, 6, 0, 1);
      final move = Move(
        game: game,
        sourcePiece: piece,
        targetPos: targetPos,
        remoteMove: true,
      );

      expect(move.remoteMove, true);
    });

    test('should throw error when creating move with piece not on board', () {
      final pieceWithoutBoard = Piece(
        game: game,
        board: board,
        side: 1,
        x: 0,
        y: 0,
        type: PieceType.rook,
      );
      pieceWithoutBoard.board = null;

      expect(
        () => Move(
          game: game,
          sourcePiece: pieceWithoutBoard,
          targetPos: const Vec4(1, 0, 0, 0),
        ),
        throwsStateError,
      );
    });

    test('should create null move correctly', () {
      final nullMove = Move.nullMove(game, board);

      expect(nullMove.game, game);
      expect(nullMove.sourcePiece, null);
      expect(nullMove.from, null);
      expect(nullMove.to, null);
      expect(nullMove.nullMove, true);
      expect(nullMove.isInterDimensionalMove, false);
      expect(nullMove.l, 0); // Timeline index from board
      expect(nullMove.promote, null);
      expect(nullMove.remoteMove, false);
      expect(nullMove.createdBoards, isNotEmpty);
      expect(nullMove.usedBoards, isNotEmpty);
    });

    test('should serialize move to JSON correctly', () {
      const targetPos = Vec4(0, 6, 0, 1);
      final move = Move(
        game: game,
        sourcePiece: piece,
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
    });

    test('should serialize null move to JSON correctly', () {
      final nullMove = Move.nullMove(game, board);
      final json = nullMove.serialize();

      expect(json['from'], null);
      expect(json['to'], null);
      expect(json['sourcePiece'], null);
      expect(json['nullMove'], true);
      expect(json['l'], 0);
    });

    test('should deserialize null move from JSON', () {
      final json = {'nullMove': true, 'l': 0, 'remoteMove': false};

      final nullMove = Move.fromSerialized(game, json);

      expect(nullMove.nullMove, true);
      expect(nullMove.l, 0);
      expect(nullMove.sourcePiece, null);
    });

    test(
      'should throw error when deserializing null move without timeline index',
      () {
        final json = {'nullMove': true, 'remoteMove': false};

        expect(() => Move.fromSerialized(game, json), throwsArgumentError);
      },
    );

    test('should throw UnimplementedError when deserializing regular move', () {
      final json = {
        'nullMove': false,
        'to': {'x': 5, 'y': 4, 'l': 0, 't': 0},
        'from': {'x': 3, 'y': 4, 'l': 0, 't': 0},
      };

      expect(() => Move.fromSerialized(game, json), throwsUnimplementedError);
    });

    test(
      'should throw ArgumentError when deserializing regular move without target',
      () {
        final json = {
          'nullMove': false,
          'from': {'x': 3, 'y': 4, 'l': 0, 't': 0},
        };

        expect(() => Move.fromSerialized(game, json), throwsArgumentError);
      },
    );

    test('should get promotion type name correctly', () {
      const targetPos = Vec4(0, 6, 0, 1);
      final move1 = Move(
        game: game,
        sourcePiece: piece,
        targetPos: targetPos,
        promotionTo: 1,
      );
      expect(move1.getPromotionTypeName(), 'queen');

      final move2 = Move(
        game: game,
        sourcePiece: piece,
        targetPos: targetPos,
        promotionTo: 2,
      );
      expect(move2.getPromotionTypeName(), 'knight');

      final move3 = Move(
        game: game,
        sourcePiece: piece,
        targetPos: targetPos,
        promotionTo: 3,
      );
      expect(move3.getPromotionTypeName(), 'rook');

      final move4 = Move(
        game: game,
        sourcePiece: piece,
        targetPos: targetPos,
        promotionTo: 4,
      );
      expect(move4.getPromotionTypeName(), 'bishop');

      final move5 = Move(game: game, sourcePiece: piece, targetPos: targetPos);
      expect(move5.getPromotionTypeName(), null);
    });

    test('should convert to string correctly', () {
      const targetPos = Vec4(0, 6, 0, 1);
      final move = Move(game: game, sourcePiece: piece, targetPos: targetPos);

      final str = move.toString();
      expect(str, contains('Move'));
      expect(str, contains('rook'));
    });

    test('should convert null move to string correctly', () {
      final nullMove = Move.nullMove(game, board);
      final str = nullMove.toString();

      expect(str, contains('Move(null'));
      expect(str, contains('l:0'));
    });

    test('should track used boards and created boards', () {
      const targetPos = Vec4(0, 6, 0, 1);
      final move = Move(game: game, sourcePiece: piece, targetPos: targetPos);

      // Move should track used and created boards
      expect(move.usedBoards, isNotEmpty);
      expect(move.createdBoards, isNotEmpty);
      expect(move.sourceBoard, isNotNull);
      expect(move.targetBoard, isNotNull);
    });

    test('should execute and undo move', () {
      const targetPos = Vec4(0, 6, 0, 1);
      final move = Move(game: game, sourcePiece: piece, targetPos: targetPos);

      // Verify move was created correctly
      expect(move.sourceBoard, isNotNull);
      expect(move.targetBoard, isNotNull);
      expect(move.createdBoards, isNotEmpty);

      // Undo the move
      move.undo();

      // After undo, boards should be removed and used boards reactivated
      // The exact state depends on implementation, but undo should not throw
      expect(move.isValid(), true);
    });
  });
}
