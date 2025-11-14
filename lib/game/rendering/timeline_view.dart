import 'package:flutter/material.dart';
import 'package:chess_5d/game/logic/timeline.dart';
import 'package:chess_5d/game/logic/board.dart';
import 'package:chess_5d/game/logic/position.dart';
import 'package:chess_5d/game/rendering/board_widget.dart';
import 'package:chess_5d/game/rendering/highlight.dart';
import 'package:chess_5d/game/rendering/arrow.dart';

/// Widget for displaying a timeline with its boards
///
/// Shows a horizontal scrollable list of boards in a timeline,
/// with indicators for the present turn and active boards.
class TimelineView extends StatelessWidget {
  const TimelineView({
    super.key,
    required this.timeline,
    required this.presentTurn,
    this.selectedTurn,
    this.selectedSquare,
    this.legalMoves = const [],
    this.highlights = const [],
    this.arrows = const [],
    this.onBoardSelected,
    this.onSquareTapped,
    this.boardSize = 300.0,
    this.showPresentIndicator = true,
    this.showTurnNumbers = true,
  });

  /// The timeline to display
  final Timeline timeline;

  /// The present turn (minimum turn across all active timelines)
  final int presentTurn;

  /// Currently selected turn (for highlighting)
  final int? selectedTurn;

  /// Selected square (if any)
  final Vec4? selectedSquare;

  /// List of legal move destinations
  final List<Vec4> legalMoves;

  /// List of highlights to draw
  final List<Highlight> highlights;

  /// List of arrows to draw
  final List<Arrow> arrows;

  /// Callback when a board (turn) is selected
  final void Function(int turn)? onBoardSelected;

  /// Callback when a square is tapped
  /// Can be async to handle promotion dialogs
  final Future<void> Function(Vec4)? onSquareTapped;

  /// Size of each board
  final double boardSize;

  /// Whether to show the present indicator
  final bool showPresentIndicator;

  /// Whether to show turn numbers
  final bool showTurnNumbers;

  @override
  Widget build(BuildContext context) {
    if (!timeline.isActive) {
      return const SizedBox.shrink();
    }

    // Ensure timeline has boards
    if (timeline.boards.isEmpty) {
      return const SizedBox.shrink();
    }

    final boards = <Board>[];
    for (int t = timeline.start; t <= timeline.end; t++) {
      final board = timeline.getBoard(t);
      // Only show boards from turn 0 onwards, and only active boards
      if (board != null && t >= 0 && board.active && !board.deleted) {
        boards.add(board);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline header
        if (showTurnNumbers)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Timeline ${timeline.l} (${timeline.start} - ${timeline.end})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),

        // Scrollable board list
        SizedBox(
          height: boardSize + (showTurnNumbers ? 40 : 0) + 16,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: boards.length,
            itemBuilder: (context, index) {
              final board = boards[index];
              final isSelected =
                  selectedTurn != null && board.t == selectedTurn;
              final isPresent = board.t == presentTurn;

              // Determine turn-based border color
              // White outline for white's turn, black outline for black's turn
              final currentTurn = board.turn;
              Color borderColor = currentTurn == 1
                  ? Colors.white
                  : Colors.black;

              if (isPresent) {
                borderColor = Colors.green;
              }

              if (isSelected) {
                borderColor = Theme.of(context).colorScheme.primary;
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                      if (isSelected)
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.surface,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor, width: 3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Turn label
                          if (showTurnNumbers)
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                'Turn ${board.t}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isPresent
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isPresent ? Colors.green : null,
                                ),
                              ),
                            ),

                          // Board widget
                          GestureDetector(
                            onTap: () => onBoardSelected?.call(board.t),
                            child: BoardWidget(
                              board: board,
                              selectedSquare: selectedSquare,
                              legalMoves: legalMoves,
                              highlights: highlights,
                              arrows: arrows,
                              onSquareTapped: onSquareTapped,
                              size: boardSize,
                              coordinatesVisible: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
