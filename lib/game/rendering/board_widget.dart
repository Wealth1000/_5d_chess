import 'package:flutter/material.dart';
import 'package:chess_5d/game/logic/board.dart';
import 'package:chess_5d/game/logic/position.dart';
import 'package:chess_5d/game/rendering/board_painter.dart';
import 'package:chess_5d/game/rendering/highlight.dart';
import 'package:chess_5d/game/rendering/arrow.dart';

/// Widget for displaying a chess board
///
/// This widget wraps the BoardPainter and provides interaction capabilities.
class BoardWidget extends StatelessWidget {
  const BoardWidget({
    super.key,
    required this.board,
    this.selectedSquare,
    this.legalMoves = const [],
    this.highlights = const [],
    this.arrows = const [],
    this.onSquareTapped,
    this.onSquareLongPressed,
    this.lightSquareColor,
    this.darkSquareColor,
    this.coordinatesVisible = true,
    this.flipBoard = false,
    this.size,
  });

  /// The board to display
  final Board board;

  /// Selected square (if any)
  final Vec4? selectedSquare;

  /// List of legal move destinations
  final List<Vec4> legalMoves;

  /// List of highlights to draw
  final List<Highlight> highlights;

  /// List of arrows to draw
  final List<Arrow> arrows;

  /// Callback when a square is tapped
  /// Can be async to handle promotion dialogs
  final Future<void> Function(Vec4)? onSquareTapped;

  /// Callback when a square is long-pressed
  final Future<void> Function(Vec4)? onSquareLongPressed;

  /// Color for light squares
  final Color? lightSquareColor;

  /// Color for dark squares
  final Color? darkSquareColor;

  /// Whether to show coordinates
  final bool coordinatesVisible;

  /// Whether to flip the board
  final bool flipBoard;

  /// Fixed size for the board (if null, uses available space)
  final double? size;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = size ?? constraints.maxWidth;

        return GestureDetector(
          onTapDown: (details) async {
            if (onSquareTapped != null) {
              final square = _getSquareFromPosition(
                details.localPosition,
                boardSize,
              );
              if (square != null) {
                await onSquareTapped!(square);
              }
            }
          },
          onLongPressStart: (details) async {
            if (onSquareLongPressed != null) {
              final square = _getSquareFromPosition(
                details.localPosition,
                boardSize,
              );
              if (square != null) {
                await onSquareLongPressed!(square);
              }
            }
          },
          child: CustomPaint(
            size: Size(boardSize, boardSize),
            painter: BoardPainter(
              board: board,
              selectedSquare: selectedSquare,
              legalMoves: legalMoves,
              highlights: highlights,
              arrows: arrows,
              lightSquareColor: lightSquareColor ?? const Color(0xFFF0D9B5),
              darkSquareColor: darkSquareColor ?? const Color(0xFFB58863),
              coordinatesVisible: coordinatesVisible,
              flipBoard: flipBoard,
            ),
          ),
        );
      },
    );
  }

  /// Get the square coordinates from a tap position
  Vec4? _getSquareFromPosition(Offset position, double boardSize) {
    final squareSize = boardSize / 8;
    final x = (position.dx / squareSize).floor();
    final y = (position.dy / squareSize).floor();

    if (x < 0 || x >= 8 || y < 0 || y >= 8) {
      return null;
    }

    final displayX = flipBoard ? 7 - x : x;
    final displayY = flipBoard ? 7 - y : y;

    return Vec4(displayX, displayY, board.l, board.t);
  }
}
