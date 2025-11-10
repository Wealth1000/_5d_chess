/// Manages player state (time, clock)
///
/// Handles time controls and clock management for each player.
class Player {

  Player({required this.game, required this.side, required this.timeRemaining})
    : timeRunning = false,
      lastStartTime = null,
      lastTurnTime = 0,
      lastGrace = 0,
      lastIncr = 0;
  /// The game this player belongs to
  dynamic game; // Game class (forward reference)

  /// Side: 0 = black, 1 = white
  final int side;

  /// Time remaining in milliseconds
  int timeRemaining;

  /// Whether the clock is running
  bool timeRunning;

  /// Last start time (performance timestamp)
  double? lastStartTime;

  /// Time taken for last turn (milliseconds)
  int lastTurnTime;

  /// Last grace period (milliseconds)
  int lastGrace;

  /// Last time increment (milliseconds)
  int lastIncr;

  /// Update time remaining
  ///
  /// [time] - Time to subtract (milliseconds)
  /// [fromStop] - Whether this is from stopping the clock
  /// Returns the new time remaining
  int updateTime(int time, {bool fromStop = false}) {
    timeRemaining -= time;
    if (timeRemaining < 0) {
      timeRemaining = 0;
    }
    return timeRemaining;
  }

  /// Start the clock
  ///
  /// [skipGraceAmount] - Amount of grace to skip
  /// [skipAmount] - Amount of time to skip
  void startTime({int? skipGraceAmount, int? skipAmount}) {
    if (timeRunning) {
      return;
    }

    timeRunning = true;
    lastStartTime = DateTime.now().millisecondsSinceEpoch.toDouble();

    // Apply skip amounts if provided
    if (skipGraceAmount != null && skipGraceAmount > 0) {
      lastGrace = skipGraceAmount;
    }
    if (skipAmount != null && skipAmount > 0) {
      updateTime(skipAmount);
    }
  }

  /// Stop the clock
  ///
  /// [fromFlag] - Whether this is from flagging (timeout)
  /// Returns the time taken, or null if clock wasn't running
  int? stopTime({bool fromFlag = false}) {
    if (!timeRunning) {
      return null;
    }

    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    if (lastStartTime == null) {
      timeRunning = false;
      return null;
    }

    final elapsed = (now - lastStartTime!).toInt();
    lastTurnTime = elapsed;
    timeRunning = false;
    lastStartTime = null;

    // Update time remaining
    if (!fromFlag) {
      updateTime(elapsed);
    }

    return elapsed;
  }

  /// Start the clock with optional parameters
  ///
  /// [grace] - Grace period in milliseconds
  /// [increment] - Time increment in milliseconds
  void startClock({int? grace, int? increment}) {
    lastGrace = grace ?? 0;
    lastIncr = increment ?? 0;
    startTime();
  }

  /// Stop the clock
  void stopClock() {
    final elapsed = stopTime();
    if (elapsed != null && lastIncr > 0) {
      // Add increment
      timeRemaining += lastIncr;
    }
  }

  /// Flag the player (timeout)
  ///
  /// [fromStop] - Whether this is from stopping the clock
  void flag({bool fromStop = false}) {
    stopTime(fromFlag: true);
    timeRemaining = 0;
    // TODO: Notify game of timeout
  }

  /// Get the current time remaining (accounting for running clock)
  ///
  /// Returns the time remaining, accounting for elapsed time if clock is running
  int getCurrentTime() {
    if (!timeRunning || lastStartTime == null) {
      return timeRemaining;
    }

    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    final elapsed = (now - lastStartTime!).toInt();
    final current = timeRemaining - elapsed;

    return current > 0 ? current : 0;
  }

  /// Check if the player has run out of time
  bool hasTimedOut() {
    return getCurrentTime() <= 0 && timeRunning;
  }

  /// Format time as MM:SS or HH:MM:SS
  String formatTime() {
    final totalSeconds = getCurrentTime() ~/ 1000;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  String toString() =>
      'Player(side:$side, time:${formatTime()}, running:$timeRunning)';
}
