import 'package:chess_5d/game/logic/piece.dart';

/// Information about a piece's starting position
class PieceInfo {
  PieceInfo({required this.type, required this.x, required this.y});

  /// Piece type (e.g., 'pawn', 'rook', 'king')
  final String type;

  /// X coordinate (0-7)
  final int x;

  /// Y coordinate (0-7)
  final int y;
}

/// Defines the available pieces for a variant
///
/// This class manages which pieces are available in a variant
/// and their starting positions.
class PieceSet {
  PieceSet({
    required this.availablePieces,
    required this.startingPiecesBlack,
    required this.startingPiecesWhite,
  });

  /// Create standard chess piece set
  factory PieceSet.standard() {
    return PieceSet(
      availablePieces: [
        PieceType.pawn,
        PieceType.rook,
        PieceType.knight,
        PieceType.bishop,
        PieceType.queen,
        PieceType.king,
      ],
      startingPiecesBlack: [
        // Back rank
        PieceInfo(type: PieceType.rook, x: 0, y: 0),
        PieceInfo(type: PieceType.knight, x: 1, y: 0),
        PieceInfo(type: PieceType.bishop, x: 2, y: 0),
        PieceInfo(type: PieceType.queen, x: 3, y: 0),
        PieceInfo(type: PieceType.king, x: 4, y: 0),
        PieceInfo(type: PieceType.bishop, x: 5, y: 0),
        PieceInfo(type: PieceType.knight, x: 6, y: 0),
        PieceInfo(type: PieceType.rook, x: 7, y: 0),
        // Pawn rank
        PieceInfo(type: PieceType.pawn, x: 0, y: 1),
        PieceInfo(type: PieceType.pawn, x: 1, y: 1),
        PieceInfo(type: PieceType.pawn, x: 2, y: 1),
        PieceInfo(type: PieceType.pawn, x: 3, y: 1),
        PieceInfo(type: PieceType.pawn, x: 4, y: 1),
        PieceInfo(type: PieceType.pawn, x: 5, y: 1),
        PieceInfo(type: PieceType.pawn, x: 6, y: 1),
        PieceInfo(type: PieceType.pawn, x: 7, y: 1),
      ],
      startingPiecesWhite: [
        // Pawn rank
        PieceInfo(type: PieceType.pawn, x: 0, y: 6),
        PieceInfo(type: PieceType.pawn, x: 1, y: 6),
        PieceInfo(type: PieceType.pawn, x: 2, y: 6),
        PieceInfo(type: PieceType.pawn, x: 3, y: 6),
        PieceInfo(type: PieceType.pawn, x: 4, y: 6),
        PieceInfo(type: PieceType.pawn, x: 5, y: 6),
        PieceInfo(type: PieceType.pawn, x: 6, y: 6),
        PieceInfo(type: PieceType.pawn, x: 7, y: 6),
        // Back rank
        PieceInfo(type: PieceType.rook, x: 0, y: 7),
        PieceInfo(type: PieceType.knight, x: 1, y: 7),
        PieceInfo(type: PieceType.bishop, x: 2, y: 7),
        PieceInfo(type: PieceType.queen, x: 3, y: 7),
        PieceInfo(type: PieceType.king, x: 4, y: 7),
        PieceInfo(type: PieceType.bishop, x: 5, y: 7),
        PieceInfo(type: PieceType.knight, x: 6, y: 7),
        PieceInfo(type: PieceType.rook, x: 7, y: 7),
      ],
    );
  }

  /// List of available piece types in this variant
  final List<String> availablePieces;

  /// Starting pieces for black (side 0)
  final List<PieceInfo> startingPiecesBlack;

  /// Starting pieces for white (side 1)
  final List<PieceInfo> startingPiecesWhite;

  /// Check if a piece type is available in this variant
  bool hasPiece(String type) {
    return availablePieces.contains(type);
  }

  /// Get starting pieces for a side
  ///
  /// [side] - Side: 0 = black, 1 = white
  List<PieceInfo> getStartingPieces(int side) {
    return side == 0 ? startingPiecesBlack : startingPiecesWhite;
  }
}
