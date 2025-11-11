import 'package:flutter/material.dart';
import 'package:chess_5d/game/logic/player.dart';

/// Widget for displaying player time remaining
///
/// Shows the time remaining for a player in a formatted way.
class TimeDisplay extends StatelessWidget {
  const TimeDisplay({super.key, required this.player, required this.isActive});

  /// The player whose time to display
  final Player player;

  /// Whether this player's clock is currently running
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final timeRemaining = player.timeRemaining;
    final timeString = _formatTime(timeRemaining);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive
              ? Theme.of(context).colorScheme.secondary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 16,
            color: isActive
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Text(
            timeString,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isActive
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Format time in milliseconds to MM:SS format
  String _formatTime(int milliseconds) {
    if (milliseconds <= 0) {
      return '00:00';
    }

    final totalSeconds = milliseconds ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
