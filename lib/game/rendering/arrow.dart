import 'package:chess_5d/game/logic/position.dart';

/// Represents an arrow on the board
///
/// Used to show time travel moves, check paths, etc.
class Arrow {
  Arrow({required this.from, required this.to, required this.type, this.color});

  /// Starting position of the arrow
  final Vec4 from;

  /// Ending position of the arrow
  final Vec4 to;

  /// Type of arrow
  final ArrowType type;

  /// Optional custom color for the arrow
  final ArrowColor? color;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Arrow &&
        other.from == from &&
        other.to == to &&
        other.type == type &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(from, to, type, color);
}

/// Types of arrows
enum ArrowType {
  /// Time travel arrow (move across timelines)
  timeTravel,

  /// Check arrow (showing attack path)
  check,

  /// Legal move arrow (showing possible move)
  legalMove,

  /// Last move arrow
  lastMove,
}

/// Colors for arrows
enum ArrowColor {
  /// Green arrow
  green,

  /// Yellow arrow
  yellow,

  /// Red arrow
  red,

  /// Blue arrow
  blue,

  /// Orange arrow
  orange,
}
