import 'dart:async';
import 'dart:isolate';
import 'package:chess_5d/game/logic/checkmate/hypercuboid.dart';
import 'package:chess_5d/game/logic/checkmate/move_combination.dart';
import 'package:chess_5d/game/logic/checkmate/simple_checkmate_detector.dart';
import 'package:chess_5d/game/logic/game.dart';
import 'package:chess_5d/game/logic/game_options.dart';

/// Checkmate worker for running checkmate detection in an isolate
///
/// This worker runs the expensive hypercuboid search algorithm in a background
/// isolate to avoid blocking the main thread.
class CheckmateWorker {
  /// Create a checkmate worker
  CheckmateWorker(this.sendPort);

  /// Send port for communicating with the main isolate
  final SendPort sendPort;

  /// Game instance (will be created from options)
  Game? _game;

  /// Search timeout handle
  Timer? _searchTimeout;

  /// Whether search is currently running
  bool _searching = false;

  /// Start mate search
  ///
  /// [options] - Game options to create game state
  /// [currentMoves] - Current turn moves (serialized)
  void startMateSearch(
    GameOptions options,
    List<Map<String, dynamic>>? currentMoves,
  ) {
    if (_searching) {
      stopMateSearch();
    }

    // Create game from options
    // Note: This is a simplified version - full implementation would need
    // to reconstruct the game state from options and current moves
    _game = Game(options: options, localPlayer: [true, true]);

    // Apply current moves if provided
    if (currentMoves != null && currentMoves.isNotEmpty) {
      // TODO: Apply current moves to game state
      // This requires deserializing moves and applying them
    }

    // Find checks
    if (_game != null) {
      _game!.findChecks();
    }

    // Start search
    _searching = true;
    _runSearch();
  }

  /// Stop mate search
  void stopMateSearch() {
    _searchTimeout?.cancel();
    _searchTimeout = null;
    _searching = false;
  }

  /// Run the search in chunks (to avoid blocking)
  void _runSearch() {
    if (!_searching || _game == null) {
      return;
    }

    // Use simple checkmate detector as fallback
    // This is more reliable than the hypercuboid algorithm
    try {
      // Check if player is in checkmate using simple detector
      final isCheckmate = SimpleCheckmateDetector.isCheckmate(_game);
      final isStalemate = SimpleCheckmateDetector.isStalemate(_game);

      if (isCheckmate || isStalemate) {
        // Checkmate or stalemate - no escape
        sendPort.send(false); // false = checkmate/stalemate
        stopMateSearch();
        return;
      } else {
        // Has legal moves - not checkmate
        sendPort.send(true); // true = has escape
        stopMateSearch();
        return;
      }
    } catch (e) {
      // Fallback to hypercuboid algorithm if simple detector fails
      // Run search for a short time slice (100ms equivalent)
      final stopTime = DateTime.now().add(const Duration(milliseconds: 100));
      final searchResults = HypercuboidSearch.search(_game);

      for (final result in searchResults) {
        if (DateTime.now().isAfter(stopTime)) {
          // Time slice expired - schedule next chunk
          _searchTimeout = Timer(Duration.zero, _runSearch);
          return;
        }

        if (result == null) {
          // Checkmate found - no escape
          sendPort.send(false); // false = checkmate
          stopMateSearch();
          return;
        } else if (result is MoveCombination) {
          // Valid escape found - not checkmate
          sendPort.send(true); // true = has escape
          stopMateSearch();
          return;
        }
        // false = still searching, continue
      }

      // Search completed - no valid escape found
      sendPort.send(false); // false = checkmate
      stopMateSearch();
    }
  }
}

/// Top-level function for isolate entry point
///
/// This function runs in the isolate and handles checkmate detection.
void checkmateWorkerMain(SendPort sendPort) {
  final worker = CheckmateWorker(sendPort);
  final receivePort = ReceivePort();

  receivePort.listen((message) {
    if (message is Map<String, dynamic>) {
      final action = message['action'] as String?;
      if (action == 'start') {
        final options = GameOptions.fromJson(
          message['options'] as Map<String, dynamic>,
        );
        final currentMoves =
            message['currentMoves'] as List<Map<String, dynamic>>?;
        worker.startMateSearch(options, currentMoves);
      } else if (action == 'stop') {
        worker.stopMateSearch();
      }
    }
  });

  sendPort.send(receivePort.sendPort);
}
