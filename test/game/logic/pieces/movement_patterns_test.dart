import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:chess_5d/game/logic/board.dart';
import 'package:chess_5d/game/logic/pieces/movement_patterns.dart';

// Mock Game class for testing
class MockGame {
  // Minimal mock implementation
}

void main() {
  group('MovementPatterns', () {
    late MockGame mockGame;
    late Board mockBoard;

    setUp(() {
      mockGame = MockGame();
      mockBoard = Board(game: mockGame, l: 0, t: 0, turn: 1);
    });

    group('Rook moves', () {
      test('should generate horizontal and vertical moves', () {
        final rook = Piece(
          game: mockGame,
          board: mockBoard,
          side: 1,
          x: 3,
          y: 3,
          type: PieceType.rook,
        );
        mockBoard.setPiece(3, 3, rook);

        final moves = MovementPatterns.getRookMoves(rook, mockBoard, null);
        expect(moves.length, greaterThan(10)); // Should have many moves

        // Check horizontal moves
        expect(moves.any((m) => m.x == 4 && m.y == 3), true);
        expect(moves.any((m) => m.x == 2 && m.y == 3), true);
        expect(moves.any((m) => m.x == 0 && m.y == 3), true);
        expect(moves.any((m) => m.x == 7 && m.y == 3), true);

        // Check vertical moves
        expect(moves.any((m) => m.x == 3 && m.y == 4), true);
        expect(moves.any((m) => m.x == 3 && m.y == 2), true);
        expect(moves.any((m) => m.x == 3 && m.y == 0), true);
        expect(moves.any((m) => m.x == 3 && m.y == 7), true);
      });

      test('should stop at friendly pieces', () {
        final rook = Piece(
          game: mockGame,
          board: mockBoard,
          side: 1,
          x: 3,
          y: 3,
          type: PieceType.rook,
        );
        mockBoard.setPiece(3, 3, rook);

        // Place a friendly piece to the right
        final friendlyPiece = Piece(
          game: mockGame,
          board: mockBoard,
          side: 1,
          x: 5,
          y: 3,
          type: PieceType.pawn,
        );
        mockBoard.setPiece(5, 3, friendlyPiece);

        final moves = MovementPatterns.getRookMoves(rook, mockBoard, null);
        // Should not be able to move past the friendly piece
        expect(moves.any((m) => m.x == 6 && m.y == 3), false);
        expect(moves.any((m) => m.x == 7 && m.y == 3), false);
        // But can move up to the piece
        expect(moves.any((m) => m.x == 4 && m.y == 3), true);
      });

      test('should capture enemy pieces', () {
        final rook = Piece(
          game: mockGame,
          board: mockBoard,
          side: 1,
          x: 3,
          y: 3,
          type: PieceType.rook,
        );
        mockBoard.setPiece(3, 3, rook);

        // Place an enemy piece to the right
        final enemyPiece = Piece(
          game: mockGame,
          board: mockBoard,
          side: 0,
          x: 5,
          y: 3,
          type: PieceType.pawn,
        );
        mockBoard.setPiece(5, 3, enemyPiece);

        final moves = MovementPatterns.getRookMoves(rook, mockBoard, null);
        // Should be able to capture the enemy piece
        expect(moves.any((m) => m.x == 5 && m.y == 3), true);
        // But not move past it
        expect(moves.any((m) => m.x == 6 && m.y == 3), false);
      });
    });

    group('Knight moves', () {
      test('should generate L-shaped moves', () {
        final knight = Piece(
          game: mockGame,
          board: mockBoard,
          side: 1,
          x: 3,
          y: 3,
          type: PieceType.knight,
        );
        mockBoard.setPiece(3, 3, knight);

        final moves = MovementPatterns.getKnightMoves(knight, mockBoard, null);
        expect(moves.length, 8); // Knight in center has 8 moves

        // Check some L-shaped moves
        expect(moves.any((m) => m.x == 5 && m.y == 4), true);
        expect(moves.any((m) => m.x == 5 && m.y == 2), true);
        expect(moves.any((m) => m.x == 1 && m.y == 4), true);
        expect(moves.any((m) => m.x == 1 && m.y == 2), true);
      });

      test('should not move to squares with friendly pieces', () {
        final knight = Piece(
          game: mockGame,
          board: mockBoard,
          side: 1,
          x: 3,
          y: 3,
          type: PieceType.knight,
        );
        mockBoard.setPiece(3, 3, knight);

        // Place a friendly piece on one of the knight's moves
        final friendlyPiece = Piece(
          game: mockGame,
          board: mockBoard,
          side: 1,
          x: 5,
          y: 4,
          type: PieceType.pawn,
        );
        mockBoard.setPiece(5, 4, friendlyPiece);

        final moves = MovementPatterns.getKnightMoves(knight, mockBoard, null);
        // Should not be able to move to friendly piece square
        expect(moves.any((m) => m.x == 5 && m.y == 4), false);
        expect(moves.length, 7); // One less move
      });

      test('should capture enemy pieces', () {
        final knight = Piece(
          game: mockGame,
          board: mockBoard,
          side: 1,
          x: 3,
          y: 3,
          type: PieceType.knight,
        );
        mockBoard.setPiece(3, 3, knight);

        // Place an enemy piece on one of the knight's moves
        final enemyPiece = Piece(
          game: mockGame,
          board: mockBoard,
          side: 0,
          x: 5,
          y: 4,
          type: PieceType.pawn,
        );
        mockBoard.setPiece(5, 4, enemyPiece);

        final moves = MovementPatterns.getKnightMoves(knight, mockBoard, null);
        // Should be able to capture the enemy piece
        expect(moves.any((m) => m.x == 5 && m.y == 4), true);
      });
    });

    group('Bishop moves', () {
      test('should generate diagonal moves', () {
        final bishop = Piece(
          game: mockGame,
          board: mockBoard,
          side: 1,
          x: 3,
          y: 3,
          type: PieceType.bishop,
        );
        mockBoard.setPiece(3, 3, bishop);

        final moves = MovementPatterns.getBishopMoves(bishop, mockBoard, null);
        expect(moves.length, greaterThan(10)); // Should have many moves

        // Check diagonal moves
        expect(moves.any((m) => m.x == 4 && m.y == 4), true); // Up-right
        expect(moves.any((m) => m.x == 2 && m.y == 2), true); // Down-left
        expect(moves.any((m) => m.x == 4 && m.y == 2), true); // Down-right
        expect(moves.any((m) => m.x == 2 && m.y == 4), true); // Up-left
      });

      test('should stop at blocking pieces', () {
        final bishop = Piece(
          game: mockGame,
          board: mockBoard,
          side: 1,
          x: 3,
          y: 3,
          type: PieceType.bishop,
        );
        mockBoard.setPiece(3, 3, bishop);

        // Place a piece diagonally
        final blockingPiece = Piece(
          game: mockGame,
          board: mockBoard,
          side: 0,
          x: 5,
          y: 5,
          type: PieceType.pawn,
        );
        mockBoard.setPiece(5, 5, blockingPiece);

        final moves = MovementPatterns.getBishopMoves(bishop, mockBoard, null);
        // Can capture the enemy piece
        expect(moves.any((m) => m.x == 5 && m.y == 5), true);
        // But not move past it
        expect(moves.any((m) => m.x == 6 && m.y == 6), false);
      });
    });

    group('Queen moves', () {
      test('should generate moves in all directions', () {
        final queen = Piece(
          game: mockGame,
          board: mockBoard,
          side: 1,
          x: 3,
          y: 3,
          type: PieceType.queen,
        );
        mockBoard.setPiece(3, 3, queen);

        final moves = MovementPatterns.getQueenMoves(queen, mockBoard, null);
        expect(moves.length, greaterThan(20)); // Queen has many moves

        // Should have horizontal, vertical, and diagonal moves
        expect(moves.any((m) => m.x == 4 && m.y == 3), true); // Horizontal
        expect(moves.any((m) => m.x == 3 && m.y == 4), true); // Vertical
        expect(moves.any((m) => m.x == 4 && m.y == 4), true); // Diagonal
      });
    });

    group('King moves', () {
      test('should generate one-square moves in all directions', () {
        final king = Piece(
          game: mockGame,
          board: mockBoard,
          side: 1,
          x: 3,
          y: 3,
          type: PieceType.king,
        );
        mockBoard.setPiece(3, 3, king);

        final moves = MovementPatterns.getKingMoves(king, mockBoard, null);
        expect(moves.length, 8); // King in center has 8 moves

        // Check all 8 directions
        expect(moves.any((m) => m.x == 4 && m.y == 3), true); // Right
        expect(moves.any((m) => m.x == 2 && m.y == 3), true); // Left
        expect(moves.any((m) => m.x == 3 && m.y == 4), true); // Up
        expect(moves.any((m) => m.x == 3 && m.y == 2), true); // Down
        expect(moves.any((m) => m.x == 4 && m.y == 4), true); // Up-right
        expect(moves.any((m) => m.x == 2 && m.y == 4), true); // Up-left
        expect(moves.any((m) => m.x == 4 && m.y == 2), true); // Down-right
        expect(moves.any((m) => m.x == 2 && m.y == 2), true); // Down-left
      });
    });

    group('Pawn moves', () {
      test('should generate forward moves for white pawn', () {
        final pawn = Piece(
          game: mockGame,
          board: mockBoard,
          side: 1, // White
          x: 3,
          y: 6, // Starting rank for white
          type: PieceType.pawn,
        );
        mockBoard.setPiece(3, 6, pawn);

        final moves = MovementPatterns.getPawnMoves(pawn, mockBoard, null);
        // Should be able to move one or two squares forward
        expect(moves.any((m) => m.x == 3 && m.y == 5), true); // One square
        expect(moves.any((m) => m.x == 3 && m.y == 4), true); // Two squares
      });

      test('should generate forward moves for black pawn', () {
        final pawn = Piece(
          game: mockGame,
          board: mockBoard,
          side: 0, // Black
          x: 3,
          y: 1, // Starting rank for black
          type: PieceType.pawn,
        );
        mockBoard.setPiece(3, 1, pawn);

        final moves = MovementPatterns.getPawnMoves(pawn, mockBoard, null);
        // Should be able to move one or two squares forward (down for black)
        expect(moves.any((m) => m.x == 3 && m.y == 2), true); // One square
        expect(moves.any((m) => m.x == 3 && m.y == 3), true); // Two squares
      });

      test('should generate capture moves diagonally', () {
        final pawn = Piece(
          game: mockGame,
          board: mockBoard,
          side: 1, // White
          x: 3,
          y: 6,
          type: PieceType.pawn,
        );
        mockBoard.setPiece(3, 6, pawn);

        // Place an enemy piece diagonally to the right
        final enemyPiece1 = Piece(
          game: mockGame,
          board: mockBoard,
          side: 0,
          x: 4,
          y: 5,
          type: PieceType.pawn,
        );
        mockBoard.setPiece(4, 5, enemyPiece1);

        final moves = MovementPatterns.getPawnMoves(pawn, mockBoard, null);
        // Should be able to capture diagonally to the right
        expect(moves.any((m) => m.x == 4 && m.y == 5), true);

        // Place an enemy piece diagonally to the left
        final enemyPiece2 = Piece(
          game: mockGame,
          board: mockBoard,
          side: 0,
          x: 2,
          y: 5,
          type: PieceType.pawn,
        );
        mockBoard.setPiece(2, 5, enemyPiece2);

        final moves2 = MovementPatterns.getPawnMoves(pawn, mockBoard, null);
        // Should be able to capture diagonally to the left
        expect(moves2.any((m) => m.x == 2 && m.y == 5), true);
      });

      test('should not move forward if blocked', () {
        final pawn = Piece(
          game: mockGame,
          board: mockBoard,
          side: 1, // White
          x: 3,
          y: 6,
          type: PieceType.pawn,
        );
        mockBoard.setPiece(3, 6, pawn);

        // Place a piece in front
        final blockingPiece = Piece(
          game: mockGame,
          board: mockBoard,
          side: 0,
          x: 3,
          y: 5,
          type: PieceType.pawn,
        );
        mockBoard.setPiece(3, 5, blockingPiece);

        final moves = MovementPatterns.getPawnMoves(pawn, mockBoard, null);
        // Should not be able to move forward
        expect(moves.any((m) => m.x == 3 && m.y == 5), false);
        expect(moves.any((m) => m.x == 3 && m.y == 4), false);
      });
    });
  });
}
