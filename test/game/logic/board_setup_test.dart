import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/logic/board.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:chess_5d/game/logic/board_setup.dart';

// Mock Game class for testing
class MockGame {
  // Minimal mock implementation
}

void main() {
  group('BoardSetup', () {
    late MockGame mockGame;

    setUp(() {
      mockGame = MockGame();
    });

    test('should create initial board with all pieces', () {
      final board = BoardSetup.createInitialBoard(mockGame, 0, 0, 1);

      // Check that all pieces are placed
      // Black pieces on rank 0 and 1
      expect(board.getPiece(0, 0)?.type, PieceType.rook);
      expect(board.getPiece(1, 0)?.type, PieceType.knight);
      expect(board.getPiece(2, 0)?.type, PieceType.bishop);
      expect(board.getPiece(3, 0)?.type, PieceType.queen);
      expect(board.getPiece(4, 0)?.type, PieceType.king);
      expect(board.getPiece(5, 0)?.type, PieceType.bishop);
      expect(board.getPiece(6, 0)?.type, PieceType.knight);
      expect(board.getPiece(7, 0)?.type, PieceType.rook);

      // Black pawns on rank 1
      for (int x = 0; x < 8; x++) {
        expect(board.getPiece(x, 1)?.type, PieceType.pawn);
        expect(board.getPiece(x, 1)?.side, PieceSide.black);
      }

      // White pieces on rank 6 and 7
      expect(board.getPiece(0, 7)?.type, PieceType.rook);
      expect(board.getPiece(1, 7)?.type, PieceType.knight);
      expect(board.getPiece(2, 7)?.type, PieceType.bishop);
      expect(board.getPiece(3, 7)?.type, PieceType.queen);
      expect(board.getPiece(4, 7)?.type, PieceType.king);
      expect(board.getPiece(5, 7)?.type, PieceType.bishop);
      expect(board.getPiece(6, 7)?.type, PieceType.knight);
      expect(board.getPiece(7, 7)?.type, PieceType.rook);

      // White pawns on rank 6
      for (int x = 0; x < 8; x++) {
        expect(board.getPiece(x, 6)?.type, PieceType.pawn);
        expect(board.getPiece(x, 6)?.side, PieceSide.white);
      }
    });

    test('should set correct piece sides', () {
      final board = BoardSetup.createInitialBoard(mockGame, 0, 0, 1);

      // Black pieces
      expect(board.getPiece(0, 0)?.side, PieceSide.black);
      expect(board.getPiece(4, 0)?.side, PieceSide.black);
      expect(board.getPiece(0, 1)?.side, PieceSide.black);

      // White pieces
      expect(board.getPiece(0, 7)?.side, PieceSide.white);
      expect(board.getPiece(4, 7)?.side, PieceSide.white);
      expect(board.getPiece(0, 6)?.side, PieceSide.white);
    });

    test('should set castling rights', () {
      final board = BoardSetup.createInitialBoard(mockGame, 0, 0, 1);

      // All castling should be available initially
      expect(
        CastlingRights.canBlackCastleKingside(board.castleAvailable),
        true,
      );
      expect(
        CastlingRights.canBlackCastleQueenside(board.castleAvailable),
        true,
      );
      expect(
        CastlingRights.canWhiteCastleKingside(board.castleAvailable),
        true,
      );
      expect(
        CastlingRights.canWhiteCastleQueenside(board.castleAvailable),
        true,
      );
    });

    test('should create empty board', () {
      final board = BoardSetup.createEmptyBoard(mockGame, 0, 0, 1);

      // Board should be empty
      for (int x = 0; x < 8; x++) {
        for (int y = 0; y < 8; y++) {
          expect(board.getPiece(x, y), null);
        }
      }

      // But should have correct properties
      expect(board.l, 0);
      expect(board.t, 0);
      expect(board.turn, 1);
    });

    test('should have pieces with correct positions', () {
      final board = BoardSetup.createInitialBoard(mockGame, 0, 0, 1);

      // Check that pieces have correct positions
      final whiteKing = board.getPiece(4, 7);
      expect(whiteKing, isNotNull);
      expect(whiteKing!.x, 4);
      expect(whiteKing.y, 7);
      expect(whiteKing.type, PieceType.king);
      expect(whiteKing.side, PieceSide.white);

      final blackKing = board.getPiece(4, 0);
      expect(blackKing, isNotNull);
      expect(blackKing!.x, 4);
      expect(blackKing.y, 0);
      expect(blackKing.type, PieceType.king);
      expect(blackKing.side, PieceSide.black);
    });

    test('should have pieces that have not moved', () {
      final board = BoardSetup.createInitialBoard(mockGame, 0, 0, 1);

      // All pieces should have hasMoved = false initially
      for (int x = 0; x < 8; x++) {
        for (int y = 0; y < 8; y++) {
          final piece = board.getPiece(x, y);
          if (piece != null) {
            expect(piece.hasMoved, false);
          }
        }
      }
    });

    test('should have empty squares in the middle', () {
      final board = BoardSetup.createInitialBoard(mockGame, 0, 0, 1);

      // Ranks 2-5 should be empty
      for (int x = 0; x < 8; x++) {
        for (int y = 2; y < 6; y++) {
          expect(board.getPiece(x, y), null);
        }
      }
    });
  });
}
