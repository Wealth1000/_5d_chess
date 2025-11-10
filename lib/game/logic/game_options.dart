import 'package:chess_5d/game/logic/move.dart';

/// Time control settings for the game
class TimeControl {

  TimeControl({
    required this.start,
    this.incr,
    this.incrScale,
    this.grace,
    this.graceScale,
  });

  /// Create a time control with no time limit
  factory TimeControl.unlimited() {
    return TimeControl(
      start: [0, 0], // 0 means unlimited
    );
  }

  /// Create a time control with equal time for both players
  factory TimeControl.equal(int timeMs, {int? incrementMs}) {
    return TimeControl(
      start: [timeMs, timeMs],
      incr: incrementMs,
      incrScale: incrementMs != null ? incrementMs ~/ 2 : null,
    );
  }

  /// Deserialize from JSON
  factory TimeControl.fromJson(Map<String, dynamic> json) {
    return TimeControl(
      start: List<int>.from(json['start'] ?? [0, 0]),
      incr: json['incr'] as int?,
      incrScale: json['incrScale'] as int?,
      grace: json['grace'] as int?,
      graceScale: json['graceScale'] as int?,
    );
  }
  /// Starting time for each player in milliseconds: [black, white]
  final List<int> start;

  /// Increment per move in milliseconds
  final int? incr;

  /// Scaling increment for new timelines
  final int? incrScale;

  /// Grace period in milliseconds
  final int? grace;

  /// Scaling grace for new timelines
  final int? graceScale;

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'incr': incr,
      'incrScale': incrScale,
      'grace': grace,
      'graceScale': graceScale,
    };
  }
}

/// Player information
class PlayerInfo {

  PlayerInfo({required this.name, required this.side});

  /// Deserialize from JSON
  factory PlayerInfo.fromJson(Map<String, dynamic> json) {
    return PlayerInfo(name: json['name'] as String, side: json['side'] as int);
  }
  /// Player name
  final String name;

  /// Player side: 0 = black, 1 = white
  final int side;

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {'name': name, 'side': side};
  }
}

/// Game configuration options
class GameOptions {

  GameOptions({
    required this.time,
    required this.players,
    required this.variant,
    this.public = false,
    this.finished = false,
    this.winner,
    this.winCause,
    this.winReason,
    this.moves,
    this.runningClocks = false,
    this.runningClockGraceTime,
    this.runningClockTime,
  });

  /// Create default game options
  factory GameOptions.defaultOptions({
    String variant = 'Standard',
    TimeControl? timeControl,
  }) {
    return GameOptions(
      time: timeControl ?? TimeControl.unlimited(),
      players: [
        PlayerInfo(name: 'Black', side: 0),
        PlayerInfo(name: 'White', side: 1),
      ],
      variant: variant,
    );
  }

  /// Deserialize from JSON
  factory GameOptions.fromJson(Map<String, dynamic> json) {
    return GameOptions(
      time: TimeControl.fromJson(json['time'] as Map<String, dynamic>),
      players: (json['players'] as List)
          .map((p) => PlayerInfo.fromJson(p as Map<String, dynamic>))
          .toList(),
      variant: json['variant'] as String,
      public: json['public'] as bool? ?? false,
      finished: json['finished'] as bool? ?? false,
      winner: json['winner'] as int?,
      winCause: json['winCause'] as int?,
      winReason: json['winReason'] as String?,
      runningClocks: json['runningClocks'] as bool? ?? false,
      runningClockGraceTime: json['runningClockGraceTime'] as int?,
      runningClockTime: json['runningClockTime'] as int?,
    );
  }
  /// Time control settings
  final TimeControl time;

  /// Player information: [black, white]
  final List<PlayerInfo> players;

  /// Variant name (e.g., 'Standard', 'NoBishops', etc.)
  final String variant;

  /// Whether this is a public game
  final bool public;

  /// Whether the game is finished
  bool finished;

  /// Winner side: 0 = black, 1 = white, null = draw/no winner
  int? winner;

  /// Cause side (who caused the win): 0 = black, 1 = white, null = no cause
  int? winCause;

  /// Reason for game end: 'checkmate', 'stalemate', 'resign', 'timeout', 'draw'
  String? winReason;

  /// Move history for replay: List of moves per turn
  List<List<Move>>? moves;

  /// Whether clocks are running
  bool runningClocks;

  /// Grace time for running clocks
  int? runningClockGraceTime;

  /// Time for running clocks
  int? runningClockTime;

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'time': time.toJson(),
      'players': players.map((p) => p.toJson()).toList(),
      'variant': variant,
      'public': public,
      'finished': finished,
      'winner': winner,
      'winCause': winCause,
      'winReason': winReason,
      'moves': moves
          ?.map((turnMoves) => turnMoves.map((m) => m.serialize()).toList())
          .toList(),
      'runningClocks': runningClocks,
      'runningClockGraceTime': runningClockGraceTime,
      'runningClockTime': runningClockTime,
    };
  }
}
