import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:chess_5d/game/logic/variants/piece_set.dart';

void main() {
  group('PieceInfo', () {
    test('should create PieceInfo with correct properties', () {
      final pieceInfo = PieceInfo(type: PieceType.pawn, x: 4, y: 5);

      expect(pieceInfo.type, PieceType.pawn);
      expect(pieceInfo.x, 4);
      expect(pieceInfo.y, 5);
    });
  });

  group('PieceSet', () {
    test('should create standard piece set', () {
      final pieceSet = PieceSet.standard();

      expect(pieceSet.availablePieces, isNotEmpty);
      expect(pieceSet.startingPiecesBlack, isNotEmpty);
      expect(pieceSet.startingPiecesWhite, isNotEmpty);
    });

    test('should have all standard pieces in available pieces', () {
      final pieceSet = PieceSet.standard();

      expect(pieceSet.availablePieces, contains(PieceType.pawn));
      expect(pieceSet.availablePieces, contains(PieceType.rook));
      expect(pieceSet.availablePieces, contains(PieceType.knight));
      expect(pieceSet.availablePieces, contains(PieceType.bishop));
      expect(pieceSet.availablePieces, contains(PieceType.queen));
      expect(pieceSet.availablePieces, contains(PieceType.king));
    });

    test('should check if piece type is available', () {
      final pieceSet = PieceSet.standard();

      expect(pieceSet.hasPiece(PieceType.pawn), true);
      expect(pieceSet.hasPiece(PieceType.rook), true);
      expect(pieceSet.hasPiece(PieceType.knight), true);
      expect(pieceSet.hasPiece(PieceType.bishop), true);
      expect(pieceSet.hasPiece(PieceType.queen), true);
      expect(pieceSet.hasPiece(PieceType.king), true);
      expect(pieceSet.hasPiece('invalid'), false);
    });

    test('should get starting pieces for black side', () {
      final pieceSet = PieceSet.standard();
      final blackPieces = pieceSet.getStartingPieces(0);

      expect(blackPieces, isNotEmpty);
      expect(blackPieces.length, 16); // 8 back rank + 8 pawns

      // Check that black pieces are in correct positions
      final king = blackPieces.firstWhere((p) => p.type == PieceType.king);
      expect(king.x, 4);
      expect(king.y, 0);

      final queen = blackPieces.firstWhere((p) => p.type == PieceType.queen);
      expect(queen.x, 3);
      expect(queen.y, 0);

      // Check pawns
      final pawns = blackPieces.where((p) => p.type == PieceType.pawn);
      expect(pawns.length, 8);
      for (final pawn in pawns) {
        expect(pawn.y, 1); // All pawns on rank 1
      }
    });

    test('should get starting pieces for white side', () {
      final pieceSet = PieceSet.standard();
      final whitePieces = pieceSet.getStartingPieces(1);

      expect(whitePieces, isNotEmpty);
      expect(whitePieces.length, 16); // 8 back rank + 8 pawns

      // Check that white pieces are in correct positions
      final king = whitePieces.firstWhere((p) => p.type == PieceType.king);
      expect(king.x, 4);
      expect(king.y, 7);

      final queen = whitePieces.firstWhere((p) => p.type == PieceType.queen);
      expect(queen.x, 3);
      expect(queen.y, 7);

      // Check pawns
      final pawns = whitePieces.where((p) => p.type == PieceType.pawn);
      expect(pawns.length, 8);
      for (final pawn in pawns) {
        expect(pawn.y, 6); // All pawns on rank 6
      }
    });

    test('should have correct number of each piece type for black', () {
      final pieceSet = PieceSet.standard();
      final blackPieces = pieceSet.getStartingPieces(0);

      expect(blackPieces.where((p) => p.type == PieceType.pawn).length, 8);
      expect(blackPieces.where((p) => p.type == PieceType.rook).length, 2);
      expect(blackPieces.where((p) => p.type == PieceType.knight).length, 2);
      expect(blackPieces.where((p) => p.type == PieceType.bishop).length, 2);
      expect(blackPieces.where((p) => p.type == PieceType.queen).length, 1);
      expect(blackPieces.where((p) => p.type == PieceType.king).length, 1);
    });

    test('should have correct number of each piece type for white', () {
      final pieceSet = PieceSet.standard();
      final whitePieces = pieceSet.getStartingPieces(1);

      expect(whitePieces.where((p) => p.type == PieceType.pawn).length, 8);
      expect(whitePieces.where((p) => p.type == PieceType.rook).length, 2);
      expect(whitePieces.where((p) => p.type == PieceType.knight).length, 2);
      expect(whitePieces.where((p) => p.type == PieceType.bishop).length, 2);
      expect(whitePieces.where((p) => p.type == PieceType.queen).length, 1);
      expect(whitePieces.where((p) => p.type == PieceType.king).length, 1);
    });
  });
}
