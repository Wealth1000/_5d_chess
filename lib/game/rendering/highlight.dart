import 'package:chess_5d/game/logic/position.dart';

/// Represents a highlight on a square
///
/// Used to highlight squares for selection, legal moves, checks, etc.
class Highlight {
  Highlight({required this.position, required this.type, this.color});

  /// The position of the highlighted square
  final Vec4 position;

  /// The type of highlight
  final HighlightType type;

  /// Optional custom color for the highlight
  final HighlightColor? color;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Highlight &&
        other.position == position &&
        other.type == type &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(position, type, color);
}

/// Types of highlights
enum HighlightType {
  /// Selected square (where piece is selected)
  selected,

  /// Legal move destination
  legalMove,

  /// Check indicator (king is in check)
  check,

  /// Last move indicator
  lastMove,

  /// Hovered square
  hovered,
}

/// Colors for highlights
enum HighlightColor {
  /// Green highlight (for legal moves)
  green,

  /// Yellow highlight (for selection)
  yellow,

  /// Red highlight (for check)
  red,

  /// Blue highlight (for hover)
  blue,

  /// Orange highlight (for last move)
  orange,
}
