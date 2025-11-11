import 'package:chess_5d/game/logic/move.dart';
import 'package:chess_5d/game/logic/position.dart';

/// Represents a combination of moves across multiple timelines
///
/// A move combination is a set of moves, one per timeline,
/// that together represent a complete turn action in 5D chess.
class MoveCombination {
  MoveCombination(this.moves);

  /// List of moves in this combination
  final List<Move> moves;

  /// Convert to a list of move data for serialization
  List<Map<String, dynamic>> toSerializable() {
    return moves.map((move) => move.serialize()).toList();
  }

  @override
  String toString() {
    return 'MoveCombination(${moves.length} moves)';
  }
}

/// Represents a location on a timeline axis in the hypercuboid
///
/// Each location can be:
/// - physical: A move on the same board
/// - leave: Leaving a board (starting a branch)
/// - arrive: Arriving at a board (completing a branch)
/// - pass: No move (null move)
enum AxisLocationType { physical, leave, arrive, pass }

/// Represents a location on a timeline axis
class AxisLocation {
  AxisLocation({
    required this.type,
    this.move,
    this.board,
    this.source,
    this.lt,
    this.idx,
  });

  /// Type of location
  final AxisLocationType type;

  /// Move (for physical and arrive types)
  final Move? move;

  /// Board state (for physical, leave, and arrive types)
  final dynamic board; // Board (forward reference)

  /// Source position (for leave type)
  final Vec4? source;

  /// Timeline and turn (for pass type)
  final List<int>? lt; // [l, t]

  /// Index reference (for arrive type, references the leave)
  final int? idx;
}
