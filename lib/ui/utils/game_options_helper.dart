import 'package:chess_5d/game/logic/game_options.dart';
import 'package:chess_5d/game/logic/variants/variant_factory.dart';

/// Helper class to create GameOptions from UI selections
///
/// This class provides utilities to convert time control strings
/// and variant strings from the UI into GameOptions objects.
class GameOptionsHelper {
  /// Create TimeControl from a time control string
  ///
  /// [timeControlString] - Time control string from UI (e.g., "No Clock (recommended)")
  ///
  /// Returns a TimeControl object
  static TimeControl createTimeControl(String timeControlString) {
    switch (timeControlString) {
      case 'No Clock (recommended)':
        return TimeControl.unlimited();
      case 'Short Clock':
        return TimeControl.equal(
          300000, // 5 minutes in milliseconds
          incrementMs: 5000, // 5 second increment
        );
      case 'Medium Clock':
        return TimeControl.equal(
          600000, // 10 minutes in milliseconds
          incrementMs: 10000, // 10 second increment
        );
      case 'Long Clock':
        return TimeControl.equal(
          1800000, // 30 minutes in milliseconds
          incrementMs: 30000, // 30 second increment
        );
      default:
        // Default to no clock
        return TimeControl.unlimited();
    }
  }

  /// Create GameOptions from UI selections
  ///
  /// [variantString] - Variant string from UI (e.g., "Standard")
  /// [timeControlString] - Time control string from UI
  /// [gameMode] - Game mode string (e.g., "Local", "CPU", etc.)
  ///
  /// Returns a GameOptions object
  static GameOptions createGameOptions({
    required String variantString,
    required String timeControlString,
    required String gameMode,
  }) {
    // Normalize variant name to match VariantFactory expectations
    final variantName = _normalizeVariantName(variantString);

    // Create time control
    final timeControl = createTimeControl(timeControlString);

    // Determine if clocks are running (time > 0 and has increment)
    final runningClocks = hasRunningClocks(timeControl);

    // Create game options
    return GameOptions(
      variant: variantName,
      time: timeControl,
      players: [
        PlayerInfo(name: 'Black', side: 0),
        PlayerInfo(name: 'White', side: 1),
      ],
      runningClocks: runningClocks,
    );
  }

  /// Normalize variant name to match VariantFactory expectations
  ///
  /// [variantString] - Variant string from UI
  ///
  /// Returns normalized variant name
  static String _normalizeVariantName(String variantString) {
    switch (variantString) {
      case 'Standard':
        return 'standard';
      case 'Random':
        // Not implemented yet, fall back to standard
        return 'standard';
      case 'Simple - No Bishops':
        // Not implemented yet, fall back to standard
        return 'standard';
      case 'Simple - No Knights':
        // Not implemented yet, fall back to standard
        return 'standard';
      case 'Simple - No Rooks':
        // Not implemented yet, fall back to standard
        return 'standard';
      case 'Simple - No Queens':
        // Not implemented yet, fall back to standard
        return 'standard';
      case 'Simple - Knights vs. Bishops':
        // Not implemented yet, fall back to standard
        return 'standard';
      case 'Simple - Simple Set':
        // Not implemented yet, fall back to standard
        return 'standard';
      default:
        return 'standard';
    }
  }

  /// Get local player flags based on game mode
  ///
  /// [gameMode] - Game mode string
  ///
  /// Returns a list of bools: [blackIsLocal, whiteIsLocal]
  static List<bool> getLocalPlayerFlags(String gameMode) {
    switch (gameMode) {
      case 'Local':
        // Both players are local
        return [true, true];
      case 'CPU':
        // White is local, black is CPU (remote)
        return [false, true];
      case 'Public':
      case 'Custom':
      case 'Private':
        // Both players are remote (will be updated when connecting to server)
        // For now, treat as local for testing
        return [true, true];
      default:
        return [true, true];
    }
  }

  /// Check if time control has running clocks
  ///
  /// [timeControl] - TimeControl object
  ///
  /// Returns true if clocks are running
  static bool hasRunningClocks(TimeControl timeControl) {
    return timeControl.start[0] > 0 && timeControl.incr != null;
  }

  /// Validate that a variant exists
  ///
  /// [variantString] - Variant string from UI
  ///
  /// Returns true if the variant is valid
  static bool isValidVariant(String variantString) {
    final normalizedName = _normalizeVariantName(variantString);
    try {
      VariantFactory.createVariant(normalizedName);
      return true;
    } catch (e) {
      return false;
    }
  }
}
