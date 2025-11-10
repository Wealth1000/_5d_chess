/// Position system for 5D Chess
///
/// Vec4 represents a position in 4D space:
/// - x, y: Spatial coordinates (0-7 for standard board)
/// - l: Timeline index (negative for black side, positive for white side, 0 is main timeline)
/// - t: Turn number within that timeline
library;

class Vec4 {

  const Vec4(this.x, this.y, this.l, this.t);

  /// Create a Vec4 from another Vec4 (copy constructor)
  Vec4.fromVec4(Vec4 other) : this(other.x, other.y, other.l, other.t);

  /// Create from JSON
  factory Vec4.fromJson(Map<String, dynamic> json) => Vec4(
    json['x'] as int,
    json['y'] as int,
    json['l'] as int,
    json['t'] as int,
  );
  final int x;
  final int y;
  final int l;
  final int t;

  /// Add another Vec4 to this one
  Vec4 add(Vec4 other) {
    return Vec4(x + other.x, y + other.y, l + other.l, t + other.t);
  }

  /// Subtract another Vec4 from this one
  Vec4 sub(Vec4 other) {
    return Vec4(x - other.x, y - other.y, l - other.l, t - other.t);
  }

  /// Check if this Vec4 equals another
  bool equals(Vec4 other) {
    return x == other.x && y == other.y && l == other.l && t == other.t;
  }

  /// Check if this position is valid (within board bounds for spatial coordinates)
  /// Note: l and t can be any int (no bounds checking for timeline/turn)
  bool isValid() {
    return x >= 0 && x < 8 && y >= 0 && y < 8;
  }

  /// Check if this is a valid spatial position (2D coordinates only)
  bool isValid2D() {
    return x >= 0 && x < 8 && y >= 0 && y < 8;
  }

  /// Get a Vec4 with only spatial coordinates (x, y)
  Vec4 get spatial => Vec4(x, y, 0, 0);

  /// Get a Vec4 with only timeline coordinates (l, t)
  Vec4 get temporal => Vec4(0, 0, l, t);

  @override
  String toString() => 'Vec4($x, $y, $l, $t)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vec4 && equals(other);
  }

  @override
  int get hashCode => Object.hash(x, y, l, t);

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'l': l, 't': t};
}
