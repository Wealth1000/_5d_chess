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
      if (board != null) {
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
          height: boardSize + (showPresentIndicator ? 40 : 0),
          child: Stack(
            children: [
              // Board list
              ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: boards.length,
                itemBuilder: (context, index) {
                  final board = boards[index];
                  final isSelected =
                      selectedTurn != null && board.t == selectedTurn;
                  final isPresent = board.t == presentTurn;

                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue
                            : isPresent
                            ? Colors.green
                            : Colors.transparent,
                        width: isSelected || isPresent ? 2 : 0,
                      ),
                      borderRadius: BorderRadius.circular(8),
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
                  );
                },
              ),

              // Present indicator
              if (showPresentIndicator)
                Positioned(
                  left: _getPresentPosition(boards, presentTurn, boardSize),
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: Colors.green,
                    child: const Center(
                      child: Text(
                        'Present',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Get the horizontal position of the present indicator
  double _getPresentPosition(
    List<Board> boards,
    int presentTurn,
    double boardSize,
  ) {
    for (int i = 0; i < boards.length; i++) {
      if (boards[i].t == presentTurn) {
        return (i * (boardSize + 16)) + (boardSize / 2) - 1;
      }
    }
    return 0;
  }
}
