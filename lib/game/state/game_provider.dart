import 'package:flutter/foundation.dart';
import 'package:chess_5d/game/logic/game.dart';
import 'package:chess_5d/game/logic/game_options.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:chess_5d/game/logic/position.dart';
import 'package:chess_5d/game/logic/check_detector.dart';
import 'package:chess_5d/game/logic/move.dart';

/// Game state provider that bridges game logic to UI
///
/// This class manages the game state and provides methods for UI interaction.
/// It uses ChangeNotifier to notify listeners when the game state changes.
class GameProvider extends ChangeNotifier {
  GameProvider({required GameOptions options, required List<bool> localPlayer})
    : _game = Game(options: options, localPlayer: localPlayer),
      _selectedPiece = null,
      _legalMoves = [],
      _hoveredPiece = null,
      _ghostPiece = null {
    _updateLegalMoves();
  }

  /// The game instance
  Game get game => _game;
  Game _game;

  /// Currently selected piece
  Piece? get selectedPiece => _selectedPiece;
  Piece? _selectedPiece;

  /// Legal moves for the selected piece
  List<Vec4> get legalMoves => _legalMoves;
  List<Vec4> _legalMoves;

  /// Currently hovered piece (for drag preview)
  Piece? get hoveredPiece => _hoveredPiece;
  Piece? _hoveredPiece;

  /// Ghost piece (drag preview)
  Piece? get ghostPiece => _ghostPiece;
  Piece? _ghostPiece;

  /// Whether the game is finished
  bool get isFinished => _game.finished;

  /// Current turn (0 = black, 1 = white)
  int get turn => _game.turn;

  /// Whether moves can be submitted
  bool get canSubmit => _game.canSubmit;

  /// Current turn moves
  List<Move> get currentTurnMoves => _game.currentTurnMoves;

  /// Select a piece
  ///
  /// [piece] - The piece to select, or null to deselect
  void selectPiece(Piece? piece) {
    _selectedPiece = piece;
    _updateLegalMoves();
    notifyListeners();
  }

  /// Deselect the currently selected piece
  void deselectPiece() {
    _selectedPiece = null;
    _legalMoves = [];
    notifyListeners();
  }

  /// Set the hovered piece (for drag preview)
  ///
  /// [piece] - The piece being hovered, or null to clear
  void setHoveredPiece(Piece? piece) {
    _hoveredPiece = piece;
    notifyListeners();
  }

  /// Set the ghost piece (drag preview)
  ///
  /// [piece] - The ghost piece, or null to clear
  void setGhostPiece(Piece? piece) {
    _ghostPiece = piece;
    notifyListeners();
  }

  /// Make a move
  ///
  /// [piece] - The piece to move
  /// [targetPos] - Target position
  /// [promotion] - Promotion piece type (1=Queen, 2=Knight, 3=Rook, 4=Bishop, null=no promotion)
  ///
  /// Returns true if the move was successful
  bool makeMove(Piece piece, Vec4 targetPos, int? promotion) {
    if (_game.finished) {
      return false;
    }

    // Check if this is a legal move
    final isLegal = _legalMoves.any(
      (move) =>
          move.x == targetPos.x &&
          move.y == targetPos.y &&
          move.l == targetPos.l &&
          move.t == targetPos.t,
    );

    if (!isLegal) {
      return false;
    }

    // Make the move
    final success = _game.move(piece, targetPos, promotion);
    if (success) {
      // Deselect piece after move
      _selectedPiece = null;
      _updateLegalMoves();
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Undo the last move
  ///
  /// Returns true if a move was undone
  bool undoMove() {
    if (_game.currentTurnMoves.isEmpty) {
      return false;
    }

    // Remove the last move
    final lastMove = _game.currentTurnMoves.removeLast();
    lastMove.undo();

    // Update legal moves
    _updateLegalMoves();
    notifyListeners();
    return true;
  }

  /// Submit all moves for the current turn
  ///
  /// Returns true if moves were submitted successfully
  bool submitMoves() {
    if (!_game.canSubmit) {
      return false;
    }

    final result = _game.submit(fastForward: false);
    if (result['submitted'] == true) {
      _selectedPiece = null;
      _legalMoves = [];
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Start a new game
  ///
  /// [options] - Game options
  /// [localPlayer] - Local player flags
  void newGame(GameOptions options, List<bool> localPlayer) {
    _game = Game(options: options, localPlayer: localPlayer);
    _selectedPiece = null;
    _legalMoves = [];
    _hoveredPiece = null;
    _ghostPiece = null;
    _updateLegalMoves();
    notifyListeners();
  }

  /// Get legal moves for a piece
  ///
  /// [piece] - The piece to get moves for
  ///
  /// Returns a list of legal move positions
  List<Vec4> getLegalMovesForPiece(Piece piece) {
    if (piece.board == null) {
      return [];
    }

    // Get all possible moves for this piece
    final allMoves = piece.enumerateMoves();

    // Filter out illegal moves (moves that would leave king in check)
    final legalMoves = <Vec4>[];
    for (final move in allMoves) {
      try {
        // Use CheckDetector to check if move would leave king in check
        final wouldLeaveInCheck =
            CheckDetector.wouldMoveLeaveKingInCheckCrossTimeline(
              _game,
              piece.board!,
              piece,
              move,
            );

        if (!wouldLeaveInCheck) {
          legalMoves.add(move);
        }
      } catch (e) {
        // Invalid move, skip it
        continue;
      }
    }

    return legalMoves;
  }

  /// Update legal moves for the selected piece
  void _updateLegalMoves() {
    if (_selectedPiece == null) {
      _legalMoves = [];
      return;
    }

    _legalMoves = getLegalMovesForPiece(_selectedPiece!);
  }

  /// Handle square tap
  ///
  /// [position] - The position that was tapped
  void handleSquareTap(Vec4 position) {
    // If a piece is selected, try to make a move
    if (_selectedPiece != null) {
      // Check if this is a legal move
      final isLegalMove = _legalMoves.any(
        (move) =>
            move.x == position.x &&
            move.y == position.y &&
            move.l == position.l &&
            move.t == position.t,
      );

      if (isLegalMove) {
        // Make the move
        makeMove(_selectedPiece!, position, null);
      } else {
        // Check if there's a piece on this square
        final piece = _game.getPiece(position);
        if (piece != null && piece.side == _game.turn) {
          // Select the new piece
          selectPiece(piece);
        } else {
          // Deselect
          deselectPiece();
        }
      }
    } else {
      // No piece selected, check if there's a piece on this square
      final piece = _game.getPiece(position);
      if (piece != null && piece.side == _game.turn) {
        // Select the piece
        selectPiece(piece);
      }
    }
  }

  /// Handle piece selection
  ///
  /// [piece] - The piece to select, or null to deselect
  void handlePieceSelection(Piece? piece) {
    selectPiece(piece);
  }

  /// Check if a move requires promotion
  ///
  /// [piece] - The piece making the move
  /// [targetPos] - Target position
  ///
  /// Returns true if this is a pawn moving to the promotion rank
  bool requiresPromotion(Piece piece, Vec4 targetPos) {
    if (piece.type != PieceType.pawn) {
      return false;
    }

    // White pawns promote on rank 0 (y == 0)
    // Black pawns promote on rank 7 (y == 7)
    if (piece.side == PieceSide.white && targetPos.y == 0) {
      return true;
    }
    if (piece.side == PieceSide.black && targetPos.y == 7) {
      return true;
    }

    return false;
  }

  /// Dispose resources
  @override
  void dispose() {
    _game.destroy();
    super.dispose();
  }
}
