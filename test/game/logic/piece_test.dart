import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:chess_5d/game/logic/position.dart';
import 'package:chess_5d/game/logic/board.dart';

// Mock Game class for testing
class MockGame {
  // Minimal mock implementation
}

void main() {
  group('Piece', () {
    late MockGame mockGame;
    late Board mockBoard;

    setUp(() {
      mockGame = MockGame();
      mockBoard = Board(game: mockGame, l: 0, t: 0, turn: 1);
    });

    test('should create piece with correct properties', () {
      final piece = Piece(
        game: mockGame,
        board: mockBoard,
        side: 1,
        x: 3,
        y: 4,
        type: PieceType.pawn,
      );

      expect(piece.game, mockGame);
      expect(piece.board, mockBoard);
      expect(piece.side, 1);
      expect(piece.x, 3);
      expect(piece.y, 4);
      expect(piece.type, PieceType.pawn);
      expect(piece.hasMoved, false);
    });

    test('should initialize type correctly', () {
      final piece = Piece(
        game: mockGame,
        board: mockBoard,
        side: 0,
        x: 0,
        y: 0,
      );
      piece.initType(PieceType.queen);
      expect(piece.type, PieceType.queen);
    });

    test('should get position correctly', () {
      final piece = Piece(
        game: mockGame,
        board: mockBoard,
        side: 1,
        x: 3,
        y: 4,
        type: PieceType.rook,
      );
      mockBoard.setPiece(3, 4, piece);

      final pos = piece.pos();
      expect(pos.x, 3);
      expect(pos.y, 4);
      expect(pos.l, 0);
      expect(pos.t, 0);
    });

    test('should throw error when getting position without board', () {
      final piece = Piece(
        game: mockGame,
        board: mockBoard,
        side: 1,
        x: 3,
        y: 4,
        type: PieceType.rook,
      );
      piece.board = null;

      expect(() => piece.pos(), throwsStateError);
    });

    test('should change position correctly', () {
      final piece = Piece(
        game: mockGame,
        board: mockBoard,
        side: 1,
        x: 3,
        y: 4,
        type: PieceType.rook,
      );
      mockBoard.setPiece(3, 4, piece);

      final newBoard = Board(game: mockGame, l: 0, t: 1, turn: 0);

      piece.changePosition(newBoard, 5, 6);
      expect(piece.x, 5);
      expect(piece.y, 6);
      expect(piece.board, newBoard);
      expect(mockBoard.getPiece(3, 4), null);
      expect(newBoard.getPiece(5, 6), piece);
    });

    test('should remove piece from board correctly', () {
      final piece = Piece(
        game: mockGame,
        board: mockBoard,
        side: 1,
        x: 3,
        y: 4,
        type: PieceType.rook,
      );
      mockBoard.setPiece(3, 4, piece);

      piece.remove();
      expect(piece.board, null);
      expect(mockBoard.getPiece(3, 4), null);
    });

    test('should clone piece to new board', () {
      final piece = Piece(
        game: mockGame,
        board: mockBoard,
        side: 1,
        x: 3,
        y: 4,
        type: PieceType.rook,
      );
      piece.hasMoved = true;
      mockBoard.setPiece(3, 4, piece);

      final newBoard = Board(game: mockGame, l: 1, t: 0, turn: 1);

      piece.cloneToBoard(newBoard);
      final clonedPiece = newBoard.getPiece(3, 4);
      expect(clonedPiece, isNotNull);
      expect(clonedPiece!.side, 1);
      expect(clonedPiece.x, 3);
      expect(clonedPiece.y, 4);
      expect(clonedPiece.type, PieceType.rook);
      expect(clonedPiece.hasMoved, true);
      expect(clonedPiece.board, newBoard);
      // Original piece should still be on original board
      expect(mockBoard.getPiece(3, 4), piece);
    });

    test('should copy piece correctly', () {
      final piece = Piece(
        game: mockGame,
        board: mockBoard,
        side: 1,
        x: 3,
        y: 4,
        type: PieceType.rook,
      );
      piece.hasMoved = true;

      final copy = piece.copy();
      expect(copy.side, 1);
      expect(copy.x, 3);
      expect(copy.y, 4);
      expect(copy.type, PieceType.rook);
      expect(copy.hasMoved, true);
      expect(copy.game, mockGame);
      expect(copy.board, mockBoard);
    });

    test('should enumerate moves for rook', () {
      final piece = Piece(
        game: mockGame,
        board: mockBoard,
        side: 1,
        x: 3,
        y: 4,
        type: PieceType.rook,
      );
      mockBoard.setPiece(3, 4, piece);

      final moves = piece.enumerateMoves();
      // Rook in center should have moves in all 4 directions
      expect(moves, isNotEmpty);
      // Should be able to move horizontally and vertically
      expect(moves.any((m) => m.x == 4 && m.y == 4), true); // Right
      expect(moves.any((m) => m.x == 2 && m.y == 4), true); // Left
      expect(moves.any((m) => m.x == 3 && m.y == 5), true); // Up
      expect(moves.any((m) => m.x == 3 && m.y == 3), true); // Down
    });

    test('should check if piece can move to position', () {
      final piece = Piece(
        game: mockGame,
        board: mockBoard,
        side: 1,
        x: 3,
        y: 4,
        type: PieceType.rook,
      );
      mockBoard.setPiece(3, 4, piece);

      // Rook should be able to move to adjacent square
      expect(piece.canMoveTo(const Vec4(3, 5, 0, 1)), true);
      // But not to an invalid position
      expect(
        piece.canMoveTo(const Vec4(3, 5, 1, 1)),
        false,
      ); // Different timeline
    });

    test('should convert to string correctly', () {
      final piece = Piece(
        game: mockGame,
        board: mockBoard,
        side: 1,
        x: 3,
        y: 4,
        type: PieceType.queen,
      );

      expect(piece.toString(), contains('queen'));
      expect(piece.toString(), contains('side:1'));
      expect(piece.toString(), contains('(3,4)'));
    });

    test('should use piece type constants correctly', () {
      expect(PieceType.pawn, 'pawn');
      expect(PieceType.rook, 'rook');
      expect(PieceType.knight, 'knight');
      expect(PieceType.bishop, 'bishop');
      expect(PieceType.queen, 'queen');
      expect(PieceType.king, 'king');
    });

    test('should use piece side constants correctly', () {
      expect(PieceSide.black, 0);
      expect(PieceSide.white, 1);
    });
  });
}
