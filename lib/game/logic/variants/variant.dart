import 'package:chess_5d/game/logic/board.dart';
import 'package:chess_5d/game/logic/pieces/piece_factory.dart';
import 'package:chess_5d/game/logic/variants/piece_set.dart';

/// Abstract base class for game variants
///
/// Variants define different game rules and piece configurations.
/// Each variant provides:
/// - A name
/// - A piece set (available pieces)
/// - Initial board setup
/// - Optional custom piece factory
abstract class Variant {
  /// Get the variant name
  String get name;

  /// Get the piece set for this variant
  PieceSet getPieceSet();

  /// Create the initial board for this variant
  ///
  /// [game] - The game this board belongs to
  /// [l] - Timeline index
  /// [t] - Turn number
  /// [turn] - Current turn side (0 = black, 1 = white)
  ///
  /// Returns a Board with pieces in their starting positions.
  Board createInitialBoard(dynamic game, int l, int t, int turn);

  /// Get a custom piece factory for this variant (optional)
  ///
  /// Returns null to use the default PieceFactory.
  PieceFactory? getPieceFactory() => null;
}
