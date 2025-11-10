import 'package:chess_5d/game/logic/board.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:chess_5d/game/logic/pieces/piece_factory.dart';

/// Sets up the initial board state
///
/// This class provides methods to create boards with pieces in their
/// standard starting positions.
class BoardSetup {
  /// Create an initial board with pieces in standard starting positions
  ///
  /// [game] - The game this board belongs to
  /// [l] - Timeline index
  /// [t] - Turn number (usually 0 for initial board)
  /// [turn] - Current turn side (0 = black, 1 = white)
  ///
  /// Returns a Board with pieces in standard chess starting positions.
  static Board createInitialBoard(dynamic game, int l, int t, int turn) {
    final board = Board(game: game, l: l, t: t, turn: turn);

    // Set up castling rights (all castling available initially)
    board.castleAvailable = 0;
    board.castleAvailable |= CastlingRights.blackKingside;
    board.castleAvailable |= CastlingRights.blackQueenside;
    board.castleAvailable |= CastlingRights.whiteKingside;
    board.castleAvailable |= CastlingRights.whiteQueenside;

    // Place black pieces (rank 0 and 1)
    _placePiece(board, game, PieceType.rook, PieceSide.black, 0, 0);
    _placePiece(board, game, PieceType.knight, PieceSide.black, 1, 0);
    _placePiece(board, game, PieceType.bishop, PieceSide.black, 2, 0);
    _placePiece(board, game, PieceType.queen, PieceSide.black, 3, 0);
    _placePiece(board, game, PieceType.king, PieceSide.black, 4, 0);
    _placePiece(board, game, PieceType.bishop, PieceSide.black, 5, 0);
    _placePiece(board, game, PieceType.knight, PieceSide.black, 6, 0);
    _placePiece(board, game, PieceType.rook, PieceSide.black, 7, 0);

    // Place black pawns (rank 1)
    for (int x = 0; x < 8; x++) {
      _placePiece(board, game, PieceType.pawn, PieceSide.black, x, 1);
    }

    // Place white pieces (rank 6 and 7)
    _placePiece(board, game, PieceType.rook, PieceSide.white, 0, 7);
    _placePiece(board, game, PieceType.knight, PieceSide.white, 1, 7);
    _placePiece(board, game, PieceType.bishop, PieceSide.white, 2, 7);
    _placePiece(board, game, PieceType.queen, PieceSide.white, 3, 7);
    _placePiece(board, game, PieceType.king, PieceSide.white, 4, 7);
    _placePiece(board, game, PieceType.bishop, PieceSide.white, 5, 7);
    _placePiece(board, game, PieceType.knight, PieceSide.white, 6, 7);
    _placePiece(board, game, PieceType.rook, PieceSide.white, 7, 7);

    // Place white pawns (rank 6)
    for (int x = 0; x < 8; x++) {
      _placePiece(board, game, PieceType.pawn, PieceSide.white, x, 6);
    }

    return board;
  }

  /// Place a piece on the board
  ///
  /// Helper method to create and place a piece.
  static void _placePiece(
    Board board,
    dynamic game,
    String type,
    int side,
    int x,
    int y,
  ) {
    final piece = PieceFactory.createPiece(
      game: game,
      board: board,
      type: type,
      side: side,
      x: x,
      y: y,
    );
    board.setPiece(x, y, piece);
  }

  /// Set up pieces on an existing board
  ///
  /// [board] - The board to set up
  /// [game] - The game this board belongs to
  static void setupStandardChessBoard(Board board, dynamic game) {
    // Clear any existing pieces
    for (int x = 0; x < 8; x++) {
      for (int y = 0; y < 8; y++) {
        board.setPiece(x, y, null);
      }
    }

    // Set up castling rights (all castling available initially)
    board.castleAvailable = 0;
    board.castleAvailable |= CastlingRights.blackKingside;
    board.castleAvailable |= CastlingRights.blackQueenside;
    board.castleAvailable |= CastlingRights.whiteKingside;
    board.castleAvailable |= CastlingRights.whiteQueenside;

    // Place black pieces (rank 0 and 1)
    _placePiece(board, game, PieceType.rook, PieceSide.black, 0, 0);
    _placePiece(board, game, PieceType.knight, PieceSide.black, 1, 0);
    _placePiece(board, game, PieceType.bishop, PieceSide.black, 2, 0);
    _placePiece(board, game, PieceType.queen, PieceSide.black, 3, 0);
    _placePiece(board, game, PieceType.king, PieceSide.black, 4, 0);
    _placePiece(board, game, PieceType.bishop, PieceSide.black, 5, 0);
    _placePiece(board, game, PieceType.knight, PieceSide.black, 6, 0);
    _placePiece(board, game, PieceType.rook, PieceSide.black, 7, 0);

    // Place black pawns (rank 1)
    for (int x = 0; x < 8; x++) {
      _placePiece(board, game, PieceType.pawn, PieceSide.black, x, 1);
    }

    // Place white pieces (rank 6 and 7)
    _placePiece(board, game, PieceType.rook, PieceSide.white, 0, 7);
    _placePiece(board, game, PieceType.knight, PieceSide.white, 1, 7);
    _placePiece(board, game, PieceType.bishop, PieceSide.white, 2, 7);
    _placePiece(board, game, PieceType.queen, PieceSide.white, 3, 7);
    _placePiece(board, game, PieceType.king, PieceSide.white, 4, 7);
    _placePiece(board, game, PieceType.bishop, PieceSide.white, 5, 7);
    _placePiece(board, game, PieceType.knight, PieceSide.white, 6, 7);
    _placePiece(board, game, PieceType.rook, PieceSide.white, 7, 7);

    // Place white pawns (rank 6)
    for (int x = 0; x < 8; x++) {
      _placePiece(board, game, PieceType.pawn, PieceSide.white, x, 6);
    }
  }

  /// Create an empty board (for testing or custom setups)
  ///
  /// [game] - The game this board belongs to
  /// [l] - Timeline index
  /// [t] - Turn number
  /// [turn] - Current turn side
  ///
  /// Returns an empty Board with no pieces.
  static Board createEmptyBoard(dynamic game, int l, int t, int turn) {
    return Board(game: game, l: l, t: t, turn: turn);
  }
}
