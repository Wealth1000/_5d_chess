import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/logic/board.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:chess_5d/game/logic/check_detector.dart';
import 'package:chess_5d/game/logic/board_setup.dart';

// Mock Game class for testing
class MockGame {
  // Minimal mock implementation
}

void main() {
  group('CheckDetector', () {
    late MockGame mockGame;
    late Board mockBoard;

    setUp(() {
      mockGame = MockGame();
      mockBoard = BoardSetup.createInitialBoard(mockGame, 0, 0, 1);
    });

    test('should detect if square is attacked by rook', () {
      // Place a white rook
      final rook = Piece(
        game: mockGame,
        board: mockBoard,
        side: 1,
        x: 3,
        y: 3,
        type: PieceType.rook,
      );
      mockBoard.setPiece(3, 3, rook);

      // Check if square (3, 4) is attacked (should be, by the rook)
      expect(CheckDetector.isSquareAttacked(mockBoard, 3, 4, 1), true);

      // Check if square (0, 0) is attacked by white (should be, by black rook)
      expect(
        CheckDetector.isSquareAttacked(mockBoard, 0, 0, 1),
        false, // White doesn't attack black's starting square initially
      );
    });

    test('should detect if square is attacked by knight', () {
      // Place a white knight
      final knight = Piece(
        game: mockGame,
        board: mockBoard,
        side: 1,
        x: 3,
        y: 3,
        type: PieceType.knight,
      );
      mockBoard.setPiece(3, 3, knight);

      // Check if square (5, 4) is attacked (L-shape move)
      expect(CheckDetector.isSquareAttacked(mockBoard, 5, 4, 1), true);
    });

    test('should detect if king is in check', () {
      // Create a board with white king and black rook attacking it
      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);

      final whiteKing = Piece(
        game: mockGame,
        board: board,
        side: 1,
        x: 4,
        y: 4,
        type: PieceType.king,
      );
      board.setPiece(4, 4, whiteKing);

      final blackRook = Piece(
        game: mockGame,
        board: board,
        side: 0,
        x: 4,
        y: 0,
        type: PieceType.rook,
      );
      board.setPiece(4, 0, blackRook);

      // White king should be in check
      expect(CheckDetector.isKingInCheck(board, 1), true);
      // Black king doesn't exist, so not in check
      expect(CheckDetector.isKingInCheck(board, 0), false);
    });

    test('should detect if king is not in check', () {
      // Create a board with white king and no attacking pieces
      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);

      final whiteKing = Piece(
        game: mockGame,
        board: board,
        side: 1,
        x: 4,
        y: 4,
        type: PieceType.king,
      );
      board.setPiece(4, 4, whiteKing);

      // White king should not be in check
      expect(CheckDetector.isKingInCheck(board, 1), false);
    });

    test('should find checks on board', () {
      // Create a board with white king and black rook attacking it
      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);

      final whiteKing = Piece(
        game: mockGame,
        board: board,
        side: 1,
        x: 4,
        y: 4,
        type: PieceType.king,
      );
      board.setPiece(4, 4, whiteKing);

      final blackRook = Piece(
        game: mockGame,
        board: board,
        side: 0,
        x: 4,
        y: 0,
        type: PieceType.rook,
      );
      board.setPiece(4, 0, blackRook);

      // Should find check for white
      expect(CheckDetector.findChecks(board, 1), true);
      expect(CheckDetector.findChecks(board, 0), false);
    });

    test('should return false if king is not found', () {
      // Create an empty board
      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);

      // No king on board, should return false
      expect(CheckDetector.isKingInCheck(board, 1), false);
      expect(CheckDetector.isKingInCheck(board, 0), false);
    });

    test('should check if move would leave king in check', () {
      // Create a board with white king and black rook
      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);

      final whiteKing = Piece(
        game: mockGame,
        board: board,
        side: 1,
        x: 4,
        y: 4,
        type: PieceType.king,
      );
      board.setPiece(4, 4, whiteKing);

      // Place rook on same file (x=4) so it can attack vertically
      final blackRook = Piece(
        game: mockGame,
        board: board,
        side: 0,
        x: 4,
        y: 0,
        type: PieceType.rook,
      );
      board.setPiece(4, 0, blackRook);

      // Moving the king to (4, 5) should leave it in check (rook attacks vertically)
      expect(
        CheckDetector.wouldMoveLeaveKingInCheck(board, whiteKing, 4, 5),
        true,
      );

      // Moving the king to (3, 3) should be safe (not attacked by rook)
      expect(
        CheckDetector.wouldMoveLeaveKingInCheck(board, whiteKing, 3, 3),
        false,
      );
    });

    test('should detect if move exposes king to check', () {
      // Create a board with white king, white piece blocking, and black rook
      final board = Board(game: mockGame, l: 0, t: 0, turn: 1);

      final whiteKing = Piece(
        game: mockGame,
        board: board,
        side: 1,
        x: 4,
        y: 4,
        type: PieceType.king,
      );
      board.setPiece(4, 4, whiteKing);

      final whitePiece = Piece(
        game: mockGame,
        board: board,
        side: 1,
        x: 4,
        y: 3,
        type: PieceType.pawn,
      );
      board.setPiece(4, 3, whitePiece);

      final blackRook = Piece(
        game: mockGame,
        board: board,
        side: 0,
        x: 4,
        y: 0,
        type: PieceType.rook,
      );
      board.setPiece(4, 0, blackRook);

      // King is NOT in check initially (pawn blocks the rook)
      expect(CheckDetector.isKingInCheck(board, 1), false);

      // Place a black piece diagonally so pawn can capture out of the file
      final blackPawn = Piece(
        game: mockGame,
        board: board,
        side: 0,
        x: 3,
        y: 2,
        type: PieceType.pawn,
      );
      board.setPiece(3, 2, blackPawn);

      // Moving the pawn away (capturing diagonally) should expose king to check
      expect(
        CheckDetector.wouldMoveLeaveKingInCheck(board, whitePiece, 3, 2),
        true,
      );
    });
  });
}
