import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/logic/board.dart';
import 'package:chess_5d/game/logic/game.dart';
import 'package:chess_5d/game/logic/game_options.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:chess_5d/game/logic/variants/standard_variant.dart';

void main() {
  group('StandardVariant', () {
    late Game game;
    late StandardVariant variant;

    setUp(() {
      final options = GameOptions.defaultOptions();
      game = Game(options: options, localPlayer: [true, true]);
      variant = StandardVariant();
    });

    test('should have correct name', () {
      expect(variant.name, 'Standard');
    });

    test('should return piece set', () {
      final pieceSet = variant.getPieceSet();

      expect(pieceSet, isNotNull);
      expect(pieceSet.availablePieces, isNotEmpty);
      expect(pieceSet.availablePieces, contains(PieceType.pawn));
      expect(pieceSet.availablePieces, contains(PieceType.rook));
      expect(pieceSet.availablePieces, contains(PieceType.knight));
      expect(pieceSet.availablePieces, contains(PieceType.bishop));
      expect(pieceSet.availablePieces, contains(PieceType.queen));
      expect(pieceSet.availablePieces, contains(PieceType.king));
    });

    test('should create initial board with correct pieces', () {
      final board = variant.createInitialBoard(game, 0, 0, 1);

      expect(board, isNotNull);
      expect(board.l, 0);
      expect(board.t, 0);
      expect(board.turn, 1);
    });

    test('should create board with all standard pieces', () {
      final board = variant.createInitialBoard(game, 0, 0, 1);

      // Count pieces
      int blackPieces = 0;
      int whitePieces = 0;

      for (int x = 0; x < 8; x++) {
        for (int y = 0; y < 8; y++) {
          final piece = board.getPiece(x, y);
          if (piece != null) {
            if (piece.side == 0) {
              blackPieces++;
            } else {
              whitePieces++;
            }
          }
        }
      }

      expect(blackPieces, 16);
      expect(whitePieces, 16);
    });

    test('should create board with pieces in correct positions', () {
      final board = variant.createInitialBoard(game, 0, 0, 1);

      // Check black king
      final blackKing = board.getPiece(4, 0);
      expect(blackKing, isNotNull);
      expect(blackKing!.type, PieceType.king);
      expect(blackKing.side, 0);

      // Check white king
      final whiteKing = board.getPiece(4, 7);
      expect(whiteKing, isNotNull);
      expect(whiteKing!.type, PieceType.king);
      expect(whiteKing.side, 1);

      // Check black queen
      final blackQueen = board.getPiece(3, 0);
      expect(blackQueen, isNotNull);
      expect(blackQueen!.type, PieceType.queen);
      expect(blackQueen.side, 0);

      // Check white queen
      final whiteQueen = board.getPiece(3, 7);
      expect(whiteQueen, isNotNull);
      expect(whiteQueen!.type, PieceType.queen);
      expect(whiteQueen.side, 1);

      // Check black pawns
      for (int x = 0; x < 8; x++) {
        final pawn = board.getPiece(x, 1);
        expect(pawn, isNotNull);
        expect(pawn!.type, PieceType.pawn);
        expect(pawn.side, 0);
      }

      // Check white pawns
      for (int x = 0; x < 8; x++) {
        final pawn = board.getPiece(x, 6);
        expect(pawn, isNotNull);
        expect(pawn!.type, PieceType.pawn);
        expect(pawn.side, 1);
      }
    });

    test('should create board with castling rights', () {
      final board = variant.createInitialBoard(game, 0, 0, 1);

      expect(board.castleAvailable, isNot(0));
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

    test('should create board with empty middle ranks', () {
      final board = variant.createInitialBoard(game, 0, 0, 1);

      // Middle ranks (2-5) should be empty
      for (int x = 0; x < 8; x++) {
        for (int y = 2; y < 6; y++) {
          expect(board.getPiece(x, y), isNull);
        }
      }
    });

    test('should return null for custom piece factory', () {
      expect(variant.getPieceFactory(), isNull);
    });
  });
}
