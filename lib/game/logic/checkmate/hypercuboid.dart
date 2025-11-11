import 'dart:math' as math;
import 'package:chess_5d/game/logic/checkmate/hypercuboid_interface.dart';
import 'package:chess_5d/game/logic/checkmate/move_combination.dart';
import 'package:chess_5d/game/logic/move.dart';
import 'package:chess_5d/game/logic/position.dart';

/// Timeline spacing constant
const int timelineSpacing = 1;

/// Hypercuboid search algorithm for checkmate detection
///
/// This implements the hypercuboid search algorithm by penteract,
/// which efficiently searches through all possible move combinations
/// across multiple timelines to detect checkmate.
class HypercuboidSearch {
  /// Search for a valid move combination (escape from checkmate)
  ///
  /// [game] - The game state
  ///
  /// Returns a sync generator that yields:
  /// - `false` if no valid combination found yet (still searching)
  /// - `MoveCombination` if a valid escape is found
  /// - `null` if no escape exists (checkmate)
  static Iterable<dynamic> search(dynamic game) sync* {
    final result = _buildHypercuboids(game);
    final wholeHC = result[0] as Map<int, Map<int, _AxisLocation>>;
    final hcs = result[1] as List<Map<int, Map<int, _AxisLocation>>>;

    final newL = HypercuboidInterface.getNewL(game);
    final sgn = newL > 0 ? 1 : -1;

    while (hcs.isNotEmpty) {
      final hc = hcs.removeLast();
      final point = _takePoint(hc);

      if (point != null) {
        final problem = _findProblem(game, point, wholeHC);
        if (problem != null) {
          // Invalid point - remove slice and continue
          hcs.addAll(_removeSlice(hc, problem));
          yield false;
        } else {
          // Valid point - convert to move combination
          final moves = _toAction(game, point, sgn);
          if (moves != null && moves.isNotEmpty) {
            yield MoveCombination(moves);
          } else {
            // No moves in this combination (all passes)
            yield false;
          }
          hcs.addAll(_removePoint(hc, point));
        }
      } else {
        // No point found in this hypercuboid - remove it
        // (already removed by removeLast)
      }
    }

    // No valid combination found - checkmate
    yield null;
  }

  /// Build hypercuboids from game state
  ///
  /// [game] - The game state
  ///
  /// Returns a tuple: [wholeHC, hcs]
  /// - wholeHC: The complete hypercuboid (all possible moves)
  /// - hcs: List of hypercuboids to search
  static List<dynamic> _buildHypercuboids(dynamic game) {
    final nonBranches = <int, List<_AxisLocation>>{};
    final arrivals = <_AxisLocation>[
      _AxisLocation(type: _LocationType.pass),
    ];

    // Build non-branches for each playable timeline
    for (final l in HypercuboidInterface.getPlayableTimelines(game)) {
      nonBranches[l] = [
        _AxisLocation(
          type: _LocationType.pass,
          lt: [l, HypercuboidInterface.getEndT(game, l)],
        ),
      ];

      String? lastLeave;
      int? lastLeaveIdx;

      for (final moveData in HypercuboidInterface.movesFrom(game, l)) {
        final start = (moveData['start'] as List).map((e) => e as int).toList();
        final end = (moveData['end'] as List).map((e) => e as int).toList();
        final newBoards = moveData['newBoards'] as Map<int, dynamic>;

        // Check if this is a physical move (same board)
        final startL = start[0];
        final startT = start[1];
        final endL = end[0];
        final endT = end[1];
        if (startL == endL && startT == endT) {
          nonBranches[l]!.add(
            _AxisLocation(
              type: _LocationType.physical,
              move: moveData,
              board: newBoards[start[0]],
            ),
          );
          continue;
        }

        // This is a time travel move - create leave/arrive
        final startKey = '$startL,$startT';
        if (startKey != lastLeave) {
          nonBranches[l]!.add(
            _AxisLocation(
              type: _LocationType.leave,
              source: start,
              board: newBoards[startL],
            ),
          );
          lastLeaveIdx = nonBranches[l]!.length - 1;
          lastLeave = startKey;
        }

        // Find the other board (not the source)
        final otherBoardKey = newBoards.keys.firstWhere(
          (key) => key != startL,
          orElse: () => startL,
        );

        final arrive = _AxisLocation(
          type: _LocationType.arrive,
          move: moveData,
          board: newBoards[otherBoardKey],
          idx: lastLeaveIdx,
        );
        arrivals.add(arrive);

        // If the target timeline is playable, add arrive to its non-branches
        if (nonBranches.containsKey(endL) &&
            HypercuboidInterface.getEndT(game, endL) == endT) {
          nonBranches[endL]!.add(arrive);
        }
      }
    }

    // Count max branches
    int maxBranches = 0;
    for (final l in nonBranches.keys) {
      for (final loc in nonBranches[l]!) {
        if (loc.type == _LocationType.leave) {
          maxBranches += 1;
          break;
        }
      }
    }

    // Build axes (timeline axes with locations)
    final axes = <int, Map<int, _AxisLocation>>{};
    for (final l in nonBranches.keys) {
      axes[l] = {};
      for (int i = 0; i < nonBranches[l]!.length; i++) {
        axes[l]![i] = nonBranches[l]![i];
      }
    }

    final newL = HypercuboidInterface.getNewL(game);
    final hcs = <Map<int, Map<int, _AxisLocation>>>[];

    // Build new arrivals map (excluding the first pass)
    final newArrs = <int, _AxisLocation>{};
    for (int i = 1; i < arrivals.length; i++) {
      newArrs[i] = arrivals[i];
    }

    // Split into maxBranches+1 hypercuboids
    for (int numActive = maxBranches; numActive >= 0; numActive--) {
      var l = newL;
      final axesCopy = <int, Map<int, _AxisLocation>>{};
      for (final key in axes.keys) {
        axesCopy[key] = Map<int, _AxisLocation>.from(axes[key]!);
      }

      for (int i = 0; i < maxBranches; i++) {
        if (i >= numActive) {
          axesCopy[l] = {0: arrivals[0]}; // Only pass
        } else {
          axesCopy[l] = Map<int, _AxisLocation>.from(newArrs);
        }
        l += newL > 0 ? 1 : -1;
      }

      hcs.add(axesCopy);
    }

    // Add final hypercuboid with all arrivals
    var l = newL;
    final finalAxes = <int, Map<int, _AxisLocation>>{};
    for (final key in axes.keys) {
      finalAxes[key] = Map<int, _AxisLocation>.from(axes[key]!);
    }
    for (int i = 0; i < maxBranches; i++) {
      finalAxes[l] = <int, _AxisLocation>{};
      for (int j = 0; j < arrivals.length; j++) {
        finalAxes[l]![j] = arrivals[j];
      }
      l += newL > 0 ? timelineSpacing : -timelineSpacing;
    }

    return [axes, hcs];
  }

  /// Take a point from the hypercuboid
  ///
  /// A point is a valid combination of locations, one per timeline.
  ///
  /// [hc] - The hypercuboid
  ///
  /// Returns a point (map of timeline to [index, location]), or null if no point exists.
  static Map<int, List<dynamic>>? _takePoint(
    Map<int, Map<int, _AxisLocation>> hc,
  ) {
    final sameboard = <int, List<dynamic>>{};
    final graph = <int, Map<int, List<dynamic>>>{};
    final mustInclude = <int>[];

    // Find sameboard locations (physical moves or passes)
    for (final l in hc.keys) {
      graph[l] = {};
      bool foundSameboard = false;

      for (final ix in hc[l]!.keys) {
        final loc = hc[l]![ix]!;
        if (loc.type == _LocationType.physical ||
            loc.type == _LocationType.pass) {
          sameboard[l] = [ix, loc];
          foundSameboard = true;
          break;
        }
      }

      if (!foundSameboard) {
        mustInclude.add(l);
      }
    }

    // Build graph for arrive locations
    for (final l in hc.keys) {
      for (final ix in hc[l]!.keys) {
        final loc = hc[l]![ix]!;
        if (loc.type == _LocationType.arrive && loc.move != null) {
          final move = loc.move as Map<String, dynamic>;
          final start = (move['start'] as List).map((e) => e as int).toList();
          final srcL = start[0];
          final idx = loc.idx;

          if (idx != null && hc[srcL] != null && hc[srcL]!.containsKey(idx)) {
            if (!graph[l]!.containsKey(srcL)) {
              graph[l]![srcL] = [ix, loc];
              if (!graph[srcL]!.containsKey(l)) {
                graph[srcL]![l] = [idx, hc[srcL]![idx]];
              }
            }
          }
        }
      }
    }

    // Find matching (simplified - for now, just return sameboard if no mustInclude)
    if (mustInclude.isEmpty) {
      return sameboard;
    }

    // For mustInclude timelines, try to find a matching
    // This is a simplified implementation - full implementation would use
    // a proper bipartite matching algorithm
    final matching = _findMatching(graph, mustInclude);
    if (matching == null) {
      return null;
    }

    // Combine sameboard and matching
    final point = Map<int, List<dynamic>>.from(sameboard);
    point.addAll(matching);
    return point;
  }

  /// Find a matching in the graph that includes all mustInclude nodes
  ///
  /// This is a simplified implementation. A full implementation would use
  /// a proper bipartite matching algorithm with augmenting paths.
  static Map<int, List<dynamic>>? _findMatching(
    Map<int, Map<int, List<dynamic>>> graph,
    List<int> mustInclude,
  ) {
    // Simplified: for each mustInclude node, try to find a connection
    final matching = <int, List<dynamic>>{};
    final used = <int>{};

    for (final node in mustInclude) {
      if (matching.containsKey(node)) continue;

      // Find an available neighbor
      final neighbors = graph[node];
      if (neighbors == null || neighbors.isEmpty) {
        return null; // No matching possible
      }

      bool found = false;
      for (final neighbor in neighbors.keys) {
        if (!used.contains(neighbor)) {
          matching[node] = neighbors[neighbor]!;
          matching[neighbor] = graph[neighbor]![node]!;
          used.add(neighbor);
          found = true;
          break;
        }
      }

      if (!found) {
        return null; // No matching possible
      }
    }

    return matching;
  }

  /// Find a problem with a point (why it's invalid)
  ///
  /// [game] - The game state
  /// [point] - The point to check
  /// [hc] - The hypercuboid
  ///
  /// Returns a slice (map of timeline to list of indices to remove), or null if valid.
  static Map<int, List<int>>? _findProblem(
    dynamic game,
    Map<int, List<dynamic>> point,
    Map<int, Map<int, _AxisLocation>> hc,
  ) {
    // Check jump order consistency
    final jumpOrderProblem = _jumpOrderConsistent(game, point, hc);
    if (jumpOrderProblem != null) {
      return jumpOrderProblem;
    }

    // Check present consistency
    final presentProblem = _testPresent(game, point, hc);
    if (presentProblem != null) {
      return presentProblem;
    }

    // Check for checks
    final checkProblem = _findChecks(game, point, hc);
    if (checkProblem != null) {
      return checkProblem;
    }

    return null; // No problem found - point is valid
  }

  /// Check jump order consistency
  ///
  /// Ensures that branches are created in the correct order and
  /// that no branch jumps to a pass.
  static Map<int, List<int>>? _jumpOrderConsistent(
    dynamic game,
    Map<int, List<dynamic>> point,
    Map<int, Map<int, _AxisLocation>> hc,
  ) {
    final newL = HypercuboidInterface.getNewL(game);
    final sgn = newL > 0 ? 1 : -1;
    final jumpMap = <String, int>{};

    // Check all arrive locations
    for (var l = newL; point.containsKey(l); l += timelineSpacing * sgn) {
      final pointData = point[l];
      if (pointData == null || pointData.length < 2) continue;

      final loc = pointData[1] as _AxisLocation;
      if (loc.type != _LocationType.arrive) continue;

      final move = loc.move as Map<String, dynamic>?;
      if (move == null) continue;

      final end = (move['end'] as List).map((e) => e as int).toList();
      final cloned = [end[0], end[1]]; // [l, t]

      // Check if this branch jumps to a pass
      if (point.containsKey(cloned[0])) {
        final targetData = point[cloned[0]];
        if (targetData != null && targetData.length >= 2) {
          final targetLoc = targetData[1] as _AxisLocation;
          if (targetLoc.type == _LocationType.pass &&
              targetLoc.lt != null &&
              targetLoc.lt![1] == cloned[1]) {
            // Branch jumps to a pass - invalid
            return {
              cloned[0]: [point[cloned[0]]![0] as int],
              l: _getArriveIndicesForLocation(hc[l]!, cloned),
            };
          }
        }
      }

      final start = (move['start'] as List).map((e) => e as int).toList();
      final source = [start[0], start[1]];
      final sourceStr = '$source';

      if (jumpMap.containsKey(sourceStr)) {
        // Earlier branch jumped to this source - invalid order
        final prevBranch = jumpMap[sourceStr]!;
        return {
          l: _getArriveIndicesForSource(hc[l]!, source),
          prevBranch: _getArriveIndicesForEnd(hc[prevBranch]!, source),
        };
      }

      jumpMap['$cloned'] = l;
    }

    return null;
  }

  /// Test present consistency
  ///
  /// Ensures that the present advances correctly after the moves.
  static Map<int, List<int>>? _testPresent(
    dynamic game,
    Map<int, List<dynamic>> point,
    Map<int, Map<int, _AxisLocation>> hc,
  ) {
    final newL = HypercuboidInterface.getNewL(game);
    final sgn = newL > 0 ? 1 : -1;
    final minL = HypercuboidInterface.getOpL(game);
    final maxL =
        sgn *
        math.max(
          sgn * (newL - sgn * timelineSpacing),
          point.keys
              .where((k) {
                final data = point[k];
                if (data == null || data.length < 2) return false;
                final loc = data[1] as _AxisLocation;
                return loc.type != _LocationType.pass;
              })
              .map((l) => l * sgn)
              .fold<int>(-999999, math.max),
        );

    final activeMinL = minL < 0 ? -minL : minL;
    final activeMaxL = maxL < 0 ? -maxL : maxL;
    final active = math.min(activeMinL, activeMaxL) + timelineSpacing;
    int minT = 999999;
    int? minTl;

    final startL = (sgn * math.max(sgn * minL, -active)).toInt();
    final endL = math.min(sgn * maxL, active).toInt();

    for (var l = startL; sgn * l <= endL; l += sgn * timelineSpacing) {
      int t;
      if (sgn * l >= sgn * newL) {
        final data = point[l];
        if (data == null || data.length < 2) {
          t = 999999;
        } else {
          final loc = data[1] as _AxisLocation;
          final lt = _getLTFromLoc(loc);
          t = lt == null ? 999999 : lt[1];
        }
      } else {
        t = HypercuboidInterface.getEndT(game, l.toInt());
      }

      if (point.containsKey(l)) {
        final data = point[l];
        if (data != null && data.length >= 2) {
          final loc = data[1] as _AxisLocation;
          if (loc.type != _LocationType.pass) {
            t += 1;
          }
        }
      }

      if (t < minT) {
        minT = t;
        minTl = l.toInt();
      }
    }

    if (minTl != null && point.containsKey(minTl)) {
      final data = point[minTl];
      if (data != null && data.length >= 2) {
        final loc = data[1] as _AxisLocation;
        if (loc.type == _LocationType.pass) {
          // Present doesn't advance - invalid
          final result = <int, List<int>>{
            minTl: [point[minTl]![0] as int],
          };

          if (minTl * sgn < -newL * sgn) {
            final nonPassL = -minTl - sgn * timelineSpacing;
            if (hc.containsKey(nonPassL)) {
              result[nonPassL] = hc[nonPassL]!.keys.where((ix) {
                final loc = hc[nonPassL]![ix]!;
                return loc.type != _LocationType.pass;
              }).toList();
            }
          }

          // Remove points that don't move present
          final minLAbs = minL < 0 ? -minL : minL;
          for (
            var l = newL;
            sgn * l <= minLAbs + timelineSpacing;
            l += sgn * timelineSpacing
          ) {
            if (!hc.containsKey(l)) break;
            if (!result.containsKey(l)) {
              result[l] = [];
            }
            result[l] = hc[l]!.keys.where((ix) {
              final loc = hc[l]![ix]!;
              return _doesNotMoveT(loc, minT);
            }).toList();
          }

          return result;
        }
      }
    }

    return null; // Present advances correctly
  }

  /// Find checks in the point
  ///
  /// Checks if applying the moves in the point results in a check.
  static Map<int, List<int>>? _findChecks(
    dynamic game,
    Map<int, List<dynamic>> point,
    Map<int, Map<int, _AxisLocation>> hc,
  ) {
    final newL = HypercuboidInterface.getNewL(game);
    final sgn = newL > 0 ? 1 : -1;
    final moves = _toActionData(game, point, sgn);

    final check = HypercuboidInterface.withMoves(
      game,
      moves,
      (g) => HypercuboidInterface.getCheckPath(g),
    );

    if (check != null) {
      final result = <int, List<int>>{};
      for (final checkPos in check) {
        final pos = (checkPos[0] as List).map((e) => e as int).toList();
        final l = pos[0];

        if (!HypercuboidInterface.posExists(game, pos)) {
          // Position is on a newly created board
          if (!result.containsKey(l)) {
            result[l] = [];
          }

          final piece = checkPos[1] as String;
          for (final ix in hc[l]!.keys) {
            final loc = hc[l]![ix]!;
            if (loc.type != _LocationType.pass && loc.board != null) {
              final board = loc.board as List<List<String>>;
              final x = pos[2];
              final y = pos[3];
              if (x >= 0 &&
                  y >= 0 &&
                  x < board.length &&
                  y < board[0].length &&
                  board[y][x] == piece) {
                result[l]!.add(ix);
              }
            }
          }
        }
      }
      return result.isEmpty ? null : result;
    }

    return null; // No check
  }

  /// Convert a point to action (list of moves)
  ///
  /// [game] - The game state
  /// [point] - The point
  /// [sgn] - Sign for sorting (1 for white, -1 for black)
  ///
  /// Returns a list of moves, or null if no moves.
  static List<Move>? _toAction(
    dynamic game,
    Map<int, List<dynamic>> point,
    int sgn,
  ) {
    final moveDataList = _toActionData(game, point, sgn);
    if (moveDataList.isEmpty) {
      return null;
    }

    final moves = <Move>[];
    for (final moveData in moveDataList) {
      final start = (moveData['start'] as List).map((e) => e as int).toList();
      final end = (moveData['end'] as List).map((e) => e as int).toList();

      try {
        final piece = game.getPiece(
          Vec4(start[2], start[3], start[0], start[1]),
        );
        if (piece == null) continue;

        final targetPos = Vec4(end[2], end[3], end[0], end[1]);
        final move = game.instantiateMove(piece, targetPos, null, false);
        moves.add(move);
      } catch (e) {
        // Skip invalid moves
        continue;
      }
    }

    return moves.isEmpty ? null : moves;
  }

  /// Convert a point to action data (list of move data maps)
  ///
  /// [game] - The game state
  /// [point] - The point
  /// [sgn] - Sign for sorting
  ///
  /// Returns a list of move data maps.
  static List<Map<String, dynamic>> _toActionData(
    dynamic game,
    Map<int, List<dynamic>> point,
    int sgn,
  ) {
    final ls = point.keys.toList()
      ..sort((a, b) => (a * sgn).compareTo(b * sgn));
    final result = <Map<String, dynamic>>[];

    for (final l in ls) {
      final pointData = point[l];
      if (pointData == null || pointData.length < 2) continue;

      final loc = pointData[1] as _AxisLocation;
      if (loc.type == _LocationType.physical ||
          loc.type == _LocationType.arrive) {
        if (loc.move != null) {
          result.add(loc.move as Map<String, dynamic>);
        }
      }
    }

    return result;
  }

  /// Remove a slice from the hypercuboid
  ///
  /// [hc] - The hypercuboid
  /// [slice] - The slice to remove (map of timeline to list of indices)
  ///
  /// Returns a list of new hypercuboids with the slice removed.
  static List<Map<int, Map<int, _AxisLocation>>> _removeSlice(
    Map<int, Map<int, _AxisLocation>> hc,
    Map<int, List<int>> slice,
  ) {
    final res = <Map<int, Map<int, _AxisLocation>>>[];
    final altSlice = <int, Map<int, _AxisLocation>>{};

    for (final l in hc.keys) {
      if (slice.containsKey(l)) {
        final altSliceL = <int, _AxisLocation>{};
        for (final n in slice[l]!) {
          if (hc[l]!.containsKey(n)) {
            altSliceL[n] = hc[l]![n]!;
          }
        }

        final x = <int, Map<int, _AxisLocation>>{};
        for (final key in hc.keys) {
          x[key] = Map<int, _AxisLocation>.from(altSlice[key] ?? hc[key]!);
        }
        x[l] = <int, _AxisLocation>{};

        for (final n in hc[l]!.keys) {
          if (!altSliceL.containsKey(n)) {
            x[l]![n] = hc[l]![n]!;
          }
        }

        res.add(x);
        altSlice[l] = altSliceL;
      } else {
        altSlice[l] = Map<int, _AxisLocation>.from(hc[l]!);
      }
    }

    return res;
  }

  /// Remove a point from the hypercuboid
  ///
  /// [hc] - The hypercuboid
  /// [point] - The point to remove
  ///
  /// Returns a list of new hypercuboids with the point removed.
  static List<Map<int, Map<int, _AxisLocation>>> _removePoint(
    Map<int, Map<int, _AxisLocation>> hc,
    Map<int, List<dynamic>> point,
  ) {
    final res = <Map<int, Map<int, _AxisLocation>>>[];
    final pt = <int, Map<int, _AxisLocation>>{};

    for (final l in point.keys) {
      final x = <int, Map<int, _AxisLocation>>{};
      for (final key in hc.keys) {
        x[key] = Map<int, _AxisLocation>.from(pt[key] ?? hc[key]!);
      }
      x[l] = Map<int, _AxisLocation>.from(hc[l]!);
      final pointData = point[l];
      if (pointData != null && pointData.isNotEmpty) {
        final ix = pointData[0] as int;
        x[l]!.remove(ix);
      }
      res.add(x);
      pt[l] = <int, _AxisLocation>{
        if (point[l] != null && point[l]!.isNotEmpty)
          point[l]![0] as int: hc[l]![point[l]![0] as int]!,
      };
    }

    return res;
  }

  /// Get LT from location
  static List<int>? _getLTFromLoc(_AxisLocation loc) {
    switch (loc.type) {
      case _LocationType.physical:
      case _LocationType.arrive:
        if (loc.move != null) {
          final move = loc.move as Map<String, dynamic>;
          final end = move['end'] as List<int>;
          return [end[0], end[1]];
        }
        return null;
      case _LocationType.leave:
        if (loc.source != null) {
          return [loc.source![0], loc.source![1]];
        }
        return null;
      case _LocationType.pass:
        return loc.lt;
    }
  }

  /// Check if location doesn't move turn
  static bool _doesNotMoveT(_AxisLocation loc, int minT) {
    if (loc.type == _LocationType.pass) {
      return true;
    }
    final lt = _getLTFromLoc(loc);
    return lt != null && lt[1] >= minT;
  }

  /// Get arrive indices for a location
  static List<int> _getArriveIndicesForLocation(
    Map<int, _AxisLocation> row,
    List<int> location,
  ) {
    final result = <int>[];
    for (final ix in row.keys) {
      final loc = row[ix]!;
      if (loc.type == _LocationType.arrive && loc.move != null) {
        final move = loc.move as Map<String, dynamic>;
        final end = move['end'] as List<int>;
        if (end[0] == location[0] && end[1] == location[1]) {
          result.add(ix);
        }
      }
    }
    return result;
  }

  /// Get arrive indices for a source
  static List<int> _getArriveIndicesForSource(
    Map<int, _AxisLocation> row,
    List<int> source,
  ) {
    final result = <int>[];
    for (final ix in row.keys) {
      final loc = row[ix]!;
      if (loc.type == _LocationType.arrive && loc.move != null) {
        final move = loc.move as Map<String, dynamic>;
        final start = move['start'] as List<int>;
        if (start[0] == source[0] && start[1] == source[1]) {
          result.add(ix);
        }
      }
    }
    return result;
  }

  /// Get arrive indices for an end
  static List<int> _getArriveIndicesForEnd(
    Map<int, _AxisLocation> row,
    List<int> end,
  ) {
    final result = <int>[];
    for (final ix in row.keys) {
      final loc = row[ix]!;
      if (loc.type == _LocationType.arrive && loc.move != null) {
        final move = loc.move as Map<String, dynamic>;
        final moveEnd = move['end'] as List<int>;
        if (moveEnd[0] == end[0] && moveEnd[1] == end[1]) {
          result.add(ix);
        }
      }
    }
    return result;
  }
}

/// Internal location type (matches JavaScript reference)
enum _LocationType { physical, leave, arrive, pass }

/// Internal axis location (matches JavaScript reference structure)
class _AxisLocation {
  _AxisLocation({
    required this.type,
    this.move,
    this.board,
    this.source,
    this.lt,
    this.idx,
  });

  final _LocationType type;
  final dynamic move; // Map<String, dynamic>
  final dynamic board; // List<List<String>>
  final List<int>? source; // [l, t]
  final List<int>? lt; // [l, t]
  final int? idx;
}
