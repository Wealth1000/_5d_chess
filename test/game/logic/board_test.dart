import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/logic/board.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:chess_5d/game/logic/position.dart';

// Mock Game class for testing
class MockGame {
  // Minimal mock implementation
}

void main() {
  group('Board', () {
    late MockGame mockGame;

    setUp(() {
      mockGame = MockGame();
    });

    test('should create empty board correctly', () {
      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);

      expect(board.game, mockGame);
      expect(board.l, 0);
      expect(board.t, 0);
      expect(board.turn, 1);
      expect(board.active, true);
      expect(board.deleted, false);
      expect(board.castleAvailable, 0);
      expect(board.enPassantPawn, null);
      expect(board.imminentCheck, false);
    });

    test('should create board with pieces from initial board', () {
      final initialBoard = Board(game: mockGame, l: 0, t: 0, turn: 1);

      final piece = Piece(
        game: mockGame,
        board: initialBoard,
        side: 1,
        x: 3,
        y: 4,
        type: PieceType.rook,
      );
      initialBoard.setPiece(3, 4, piece);

      final newBoard = Board(
        game: mockGame,
        l: 0,
        t: 1,
        turn: 0,
        initialBoard: initialBoard,
      );

      final clonedPiece = newBoard.getPiece(3, 4);
      expect(clonedPiece, isNotNull);
      expect(clonedPiece!.type, PieceType.rook);
      expect(clonedPiece.board, newBoard);
      // Original piece should still be on original board
      expect(initialBoard.getPiece(3, 4), piece);
    });

    test('should create board from another board using factory', () {
      final sourceBoard = Board(game: mockGame, l: 0, t: 0, turn: 1);

      final piece = Piece(
        game: mockGame,
        board: sourceBoard,
        side: 1,
        x: 3,
        y: 4,
        type: PieceType.rook,
      );
      sourceBoard.setPiece(3, 4, piece);

      final clonedBoard = Board.fromBoard(sourceBoard, newL: 1);
      expect(clonedBoard.l, 1);
      expect(clonedBoard.t, 0);
      expect(clonedBoard.turn, 1);
      expect(clonedBoard.getPiece(3, 4), isNotNull);
    });

    test('should get piece at coordinates correctly', () {
      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);

      final piece = Piece(
        game: mockGame,
        board: board,
        side: 1,
        x: 3,
        y: 4,
        type: PieceType.rook,
      );
      board.setPiece(3, 4, piece);

      expect(board.getPiece(3, 4), piece);
      expect(board.getPiece(0, 0), null);
    });

    test('should return null for out of bounds coordinates', () {
      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);

      expect(board.getPiece(-1, 0), null);
      expect(board.getPiece(8, 0), null);
      expect(board.getPiece(0, -1), null);
      expect(board.getPiece(0, 8), null);
    });

    test('should get piece at Vec4 position correctly', () {
      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);

      final piece = Piece(
        game: mockGame,
        board: board,
        side: 1,
        x: 3,
        y: 4,
        type: PieceType.rook,
      );
      board.setPiece(3, 4, piece);

      const pos = Vec4(3, 4, 0, 0);
      expect(board.getPieceAt(pos), piece);

      const wrongTimeline = Vec4(3, 4, 1, 0);
      expect(board.getPieceAt(wrongTimeline), null);

      const wrongTurn = Vec4(3, 4, 0, 1);
      expect(board.getPieceAt(wrongTurn), null);
    });

    test('should set piece at coordinates correctly', () {
      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);

      final piece = Piece(
        game: mockGame,
        board: board,
        side: 1,
        x: 0,
        y: 0,
        type: PieceType.rook,
      );

      board.setPiece(3, 4, piece);
      expect(board.getPiece(3, 4), piece);
      expect(piece.x, 3);
      expect(piece.y, 4);
      expect(piece.board, board);
    });

    test('should not set piece for out of bounds coordinates', () {
      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);

      final piece = Piece(
        game: mockGame,
        board: board,
        side: 1,
        x: 0,
        y: 0,
        type: PieceType.rook,
      );

      board.setPiece(-1, 0, piece);
      board.setPiece(8, 0, piece);
      board.setPiece(0, -1, piece);
      board.setPiece(0, 8, piece);

      // Piece should not be set at invalid coordinates
      expect(board.getPiece(-1, 0), null);
      expect(board.getPiece(8, 0), null);
    });

    test('should check if square is empty', () {
      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);

      expect(board.isEmpty(3, 4), true);

      final piece = Piece(
        game: mockGame,
        board: board,
        side: 1,
        x: 3,
        y: 4,
        type: PieceType.rook,
      );
      board.setPiece(3, 4, piece);

      expect(board.isEmpty(3, 4), false);
    });

    test('should check if square has enemy piece', () {
      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);

      final whitePiece = Piece(
        game: mockGame,
        board: board,
        side: 1,
        x: 3,
        y: 4,
        type: PieceType.rook,
      );
      board.setPiece(3, 4, whitePiece);

      expect(board.hasEnemyPiece(3, 4, 0), true); // Black checking white
      expect(board.hasEnemyPiece(3, 4, 1), false); // White checking white
      expect(board.hasEnemyPiece(0, 0, 0), false); // Empty square
    });

    test('should check if square has friendly piece', () {
      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);

      final whitePiece = Piece(
        game: mockGame,
        board: board,
        side: 1,
        x: 3,
        y: 4,
        type: PieceType.rook,
      );
      board.setPiece(3, 4, whitePiece);

      expect(board.hasFriendlyPiece(3, 4, 1), true); // White checking white
      expect(board.hasFriendlyPiece(3, 4, 0), false); // Black checking white
      expect(board.hasFriendlyPiece(0, 0, 1), false); // Empty square
    });

    test('should check if coordinates are valid', () {
      expect(Board.isValidCoordinate(0, 0), true);
      expect(Board.isValidCoordinate(7, 7), true);
      expect(Board.isValidCoordinate(3, 4), true);
      expect(Board.isValidCoordinate(-1, 0), false);
      expect(Board.isValidCoordinate(8, 0), false);
      expect(Board.isValidCoordinate(0, -1), false);
      expect(Board.isValidCoordinate(0, 8), false);
    });

    test('should make board inactive', () {
      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);

      expect(board.active, true);
      board.makeInactive();
      expect(board.active, false);
    });

    test('should make board active', () {
      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);

      board.makeInactive();
      expect(board.active, false);
      board.makeActive();
      expect(board.active, true);
    });

    test('should remove board and all pieces', () {
      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);

      final piece1 = Piece(
        game: mockGame,
        board: board,
        side: 1,
        x: 3,
        y: 4,
        type: PieceType.rook,
      );
      final piece2 = Piece(
        game: mockGame,
        board: board,
        side: 0,
        x: 0,
        y: 0,
        type: PieceType.pawn,
      );
      board.setPiece(3, 4, piece1);
      board.setPiece(0, 0, piece2);

      board.remove();

      expect(board.deleted, true);
      expect(board.active, false);
      expect(board.getPiece(3, 4), null);
      expect(board.getPiece(0, 0), null);
      expect(piece1.board, null);
      expect(piece2.board, null);
    });

    test('should check castling rights correctly', () {
      expect(
        CastlingRights.canBlackCastleKingside(CastlingRights.blackKingside),
        true,
      );
      expect(
        CastlingRights.canBlackCastleQueenside(CastlingRights.blackQueenside),
        true,
      );
      expect(
        CastlingRights.canWhiteCastleKingside(CastlingRights.whiteKingside),
        true,
      );
      expect(
        CastlingRights.canWhiteCastleQueenside(CastlingRights.whiteQueenside),
        true,
      );

      expect(CastlingRights.canBlackCastleKingside(0), false);
    });

    test('should remove castling rights correctly', () {
      int rights = CastlingRights.blackKingside | CastlingRights.whiteKingside;

      rights = CastlingRights.removeCastlingRights(rights, 0);
      expect(CastlingRights.canBlackCastleKingside(rights), false);
      expect(CastlingRights.canWhiteCastleKingside(rights), true);

      rights = CastlingRights.removeCastlingRights(rights, 1);
      expect(CastlingRights.canWhiteCastleQueenside(rights), false);
    });

    test('should convert to string correctly', () {
      final board = Board(game: mockGame, l: 1, t: 5, turn: 0);

      final str = board.toString();
      expect(str, contains('l:1'));
      expect(str, contains('t:5'));
      expect(str, contains('turn:0'));
    });
  });
}
