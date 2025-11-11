import 'package:chess_5d/game/logic/board.dart';
import 'package:chess_5d/game/logic/pieces/piece_factory.dart';
import 'package:chess_5d/game/logic/variants/piece_set.dart';
import 'package:chess_5d/game/logic/variants/variant.dart';

/// Standard 5D Chess variant
///
/// This is the standard variant with all pieces (pawn, rook, knight, bishop, queen, king)
/// in their traditional starting positions.
class StandardVariant extends Variant {
  StandardVariant();

  @override
  String get name => 'Standard';

  @override
  PieceSet getPieceSet() {
    return PieceSet.standard();
  }

  @override
  Board createInitialBoard(dynamic game, int l, int t, int turn) {
    final board = Board(game: game, l: l, t: t, turn: turn);

    // Set up castling rights (all castling available initially)
    board.castleAvailable = 0;
    board.castleAvailable |= CastlingRights.blackKingside;
    board.castleAvailable |= CastlingRights.blackQueenside;
    board.castleAvailable |= CastlingRights.whiteKingside;
    board.castleAvailable |= CastlingRights.whiteQueenside;

    // Get piece set and place pieces
    final pieceSet = getPieceSet();

    // Place black pieces (side 0)
    for (final pieceInfo in pieceSet.getStartingPieces(0)) {
      final piece = PieceFactory.createPiece(
        game: game,
        board: board,
        type: pieceInfo.type,
        side: 0,
        x: pieceInfo.x,
        y: pieceInfo.y,
      );
      board.setPiece(pieceInfo.x, pieceInfo.y, piece);
    }

    // Place white pieces (side 1)
    for (final pieceInfo in pieceSet.getStartingPieces(1)) {
      final piece = PieceFactory.createPiece(
        game: game,
        board: board,
        type: pieceInfo.type,
        side: 1,
        x: pieceInfo.x,
        y: pieceInfo.y,
      );
      board.setPiece(pieceInfo.x, pieceInfo.y, piece);
    }

    return board;
  }
}
