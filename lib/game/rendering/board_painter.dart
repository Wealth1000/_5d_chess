import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:chess_5d/game/logic/board.dart';
import 'package:chess_5d/game/logic/position.dart';
import 'package:chess_5d/game/rendering/highlight.dart';
import 'package:chess_5d/game/rendering/arrow.dart';

/// Custom painter for drawing chess boards
///
/// Handles drawing the board squares, pieces, highlights, and arrows.
class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.board,
    this.selectedSquare,
    this.legalMoves = const [],
    this.highlights = const [],
    this.arrows = const [],
    this.lightSquareColor = const Color(0xFFF0D9B5),
    this.darkSquareColor = const Color(0xFFB58863),
    Color? selectedSquareColor,
    Color? legalMoveColor,
    Color? checkColor,
    Color? lastMoveColor,
    Color? hoverColor,
    this.coordinatesVisible = true,
    this.flipBoard = false,
  }) : selectedSquareColor = selectedSquareColor ?? const Color(0xFF7FC8FF),
       legalMoveColor = legalMoveColor ?? const Color(0x807FC8FF),
       checkColor = checkColor ?? const Color(0x80FF0000),
       lastMoveColor = lastMoveColor ?? const Color(0x4DFFD700),
       hoverColor = hoverColor ?? const Color(0x4D00FF00);

  /// The board to draw
  final Board board;

  /// Selected square (if any)
  final Vec4? selectedSquare;

  /// List of legal move destinations
  final List<Vec4> legalMoves;

  /// List of highlights to draw
  final List<Highlight> highlights;

  /// List of arrows to draw
  final List<Arrow> arrows;

  /// Color for light squares
  final Color lightSquareColor;

  /// Color for dark squares
  final Color darkSquareColor;

  /// Color for selected square
  final Color selectedSquareColor;

  /// Color for legal move indicators
  final Color legalMoveColor;

  /// Color for check indicators
  final Color checkColor;

  /// Color for last move indicators
  final Color lastMoveColor;

  /// Color for hover indicators
  final Color hoverColor;

  /// Whether to show coordinates
  final bool coordinatesVisible;

  /// Whether to flip the board (black's perspective)
  final bool flipBoard;

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate square size
    final squareSize = size.width / 8;

    // Draw board squares
    _drawBoard(canvas, size, squareSize);

    // Draw highlights
    _drawHighlights(canvas, size, squareSize);

    // Draw last move indicator
    _drawLastMove(canvas, size, squareSize);

    // Draw arrows
    _drawArrows(canvas, size, squareSize);

    // Pieces are rendered as SVG widgets in BoardWidget, not on Canvas

    // Draw coordinates
    if (coordinatesVisible) {
      _drawCoordinates(canvas, size, squareSize);
    }
  }

  /// Draw the chess board squares
  void _drawBoard(Canvas canvas, Size size, double squareSize) {
    for (int x = 0; x < 8; x++) {
      for (int y = 0; y < 8; y++) {
        final displayX = flipBoard ? 7 - x : x;
        final displayY = flipBoard ? 7 - y : y;

        final isLight = (displayX + displayY) % 2 == 0;
        final color = isLight ? lightSquareColor : darkSquareColor;

        final rect = Rect.fromLTWH(
          x * squareSize,
          y * squareSize,
          squareSize,
          squareSize,
        );

        final paint = Paint()..color = color;
        canvas.drawRect(rect, paint);
      }
    }
  }

  /// Draw highlights on squares
  void _drawHighlights(Canvas canvas, Size size, double squareSize) {
    for (final highlight in highlights) {
      if (highlight.position.l != board.l || highlight.position.t != board.t) {
        continue; // Skip highlights not on this board
      }

      final x = flipBoard ? 7 - highlight.position.x : highlight.position.x;
      final y = flipBoard ? 7 - highlight.position.y : highlight.position.y;

      final rect = Rect.fromLTWH(
        x * squareSize,
        y * squareSize,
        squareSize,
        squareSize,
      );

      Color color;
      switch (highlight.type) {
        case HighlightType.selected:
          color = selectedSquareColor;
          break;
        case HighlightType.legalMove:
          color = legalMoveColor;
          break;
        case HighlightType.check:
          color = checkColor;
          break;
        case HighlightType.lastMove:
          color = lastMoveColor;
          break;
        case HighlightType.hovered:
          color = hoverColor;
          break;
      }

      // Apply custom color if provided
      if (highlight.color != null) {
        switch (highlight.color!) {
          case HighlightColor.green:
            color = const Color(0x8000FF00);
            break;
          case HighlightColor.yellow:
            color = const Color(0x80FFFF00);
            break;
          case HighlightColor.red:
            color = const Color(0x80FF0000);
            break;
          case HighlightColor.blue:
            color = const Color(0x800000FF);
            break;
          case HighlightColor.orange:
            color = const Color(0x80FFA500);
            break;
        }
      }

      final paint = Paint()..color = color;
      canvas.drawRect(rect, paint);
    }

    // Draw selected square if not in highlights
    if (selectedSquare != null &&
        selectedSquare!.l == board.l &&
        selectedSquare!.t == board.t) {
      final x = flipBoard ? 7 - selectedSquare!.x : selectedSquare!.x;
      final y = flipBoard ? 7 - selectedSquare!.y : selectedSquare!.y;

      final rect = Rect.fromLTWH(
        x * squareSize,
        y * squareSize,
        squareSize,
        squareSize,
      );

      final paint = Paint()..color = selectedSquareColor;
      canvas.drawRect(rect, paint);
    }

    // Draw legal move highlights (same style as selected square, only for pawns)
    // Show moves on current board or next turn (since moves target next turn)
    for (final move in legalMoves) {
      if (move.l != board.l || (move.t != board.t && move.t != board.t + 1)) {
        continue;
      }

      final x = flipBoard ? 7 - move.x : move.x;
      final y = flipBoard ? 7 - move.y : move.y;

      final rect = Rect.fromLTWH(
        x * squareSize,
        y * squareSize,
        squareSize,
        squareSize,
      );

      // Use the same highlight style as selected square
      final paint = Paint()..color = selectedSquareColor;
      canvas.drawRect(rect, paint);
    }
  }

  /// Draw last move indicator
  void _drawLastMove(Canvas canvas, Size size, double squareSize) {
    // This would be drawn if we track last move
    // For now, it's handled in highlights
  }

  /// Draw arrows on the board
  void _drawArrows(Canvas canvas, Size size, double squareSize) {
    for (final arrow in arrows) {
      if (arrow.from.l != board.l ||
          arrow.from.t != board.t ||
          arrow.to.l != board.l ||
          arrow.to.t != board.t) {
        continue; // Skip arrows not on this board
      }

      final fromX = flipBoard ? 7 - arrow.from.x : arrow.from.x;
      final fromY = flipBoard ? 7 - arrow.from.y : arrow.from.y;
      final toX = flipBoard ? 7 - arrow.to.x : arrow.to.x;
      final toY = flipBoard ? 7 - arrow.to.y : arrow.to.y;

      final from = Offset(
        fromX * squareSize + squareSize / 2,
        fromY * squareSize + squareSize / 2,
      );
      final to = Offset(
        toX * squareSize + squareSize / 2,
        toY * squareSize + squareSize / 2,
      );

      Color color;
      switch (arrow.type) {
        case ArrowType.timeTravel:
          color = const Color(0xFF00FF00);
          break;
        case ArrowType.check:
          color = const Color(0xFFFF0000);
          break;
        case ArrowType.legalMove:
          color = const Color(0xFF0000FF);
          break;
        case ArrowType.lastMove:
          color = const Color(0xFFFFA500);
          break;
      }

      // Apply custom color if provided
      if (arrow.color != null) {
        switch (arrow.color!) {
          case ArrowColor.green:
            color = const Color(0xFF00FF00);
            break;
          case ArrowColor.yellow:
            color = const Color(0xFFFFFF00);
            break;
          case ArrowColor.red:
            color = const Color(0xFFFF0000);
            break;
          case ArrowColor.blue:
            color = const Color(0xFF0000FF);
            break;
          case ArrowColor.orange:
            color = const Color(0xFFFFA500);
            break;
        }
      }

      _drawArrow(canvas, from, to, color, squareSize * 0.1);
    }
  }

  /// Draw an arrow from one point to another
  void _drawArrow(
    Canvas canvas,
    Offset from,
    Offset to,
    Color color,
    double arrowWidth,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = arrowWidth;

    // Draw line
    canvas.drawLine(from, to, paint);

    // Draw arrowhead
    final angle = (to - from).direction;
    final arrowLength = arrowWidth * 2;
    const arrowAngle = 0.5;

    final arrowPoint1 =
        to +
        Offset.fromDirection(angle + pi - arrowAngle, arrowLength) *
            (arrowWidth / arrowLength);
    final arrowPoint2 =
        to +
        Offset.fromDirection(angle + pi + arrowAngle, arrowLength) *
            (arrowWidth / arrowLength);

    final path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
      ..close();

    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, arrowPaint);
  }

  /// Draw coordinates on the board
  void _drawCoordinates(Canvas canvas, Size size, double squareSize) {
    final textColor = flipBoard ? lightSquareColor : darkSquareColor;
    final textStyle = TextStyle(
      color: textColor,
      fontSize: squareSize * 0.15,
      fontWeight: FontWeight.bold,
    );

    // Draw file labels (a-h)
    for (int x = 0; x < 8; x++) {
      final file = String.fromCharCode(
        'a'.codeUnitAt(0) + (flipBoard ? 7 - x : x),
      );
      final textPainter = TextPainter(
        text: TextSpan(text: file, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final offset = Offset(
        x * squareSize + (squareSize - textPainter.width) / 2,
        size.height - textPainter.height - 2,
      );
      textPainter.paint(canvas, offset);
    }

    // Draw rank labels (1-8)
    for (int y = 0; y < 8; y++) {
      final rank = (flipBoard ? y + 1 : 8 - y).toString();
      final textPainter = TextPainter(
        text: TextSpan(text: rank, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final offset = Offset(
        2,
        y * squareSize + (squareSize - textPainter.height) / 2,
      );
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) {
    return oldDelegate.board != board ||
        oldDelegate.selectedSquare != selectedSquare ||
        oldDelegate.legalMoves != legalMoves ||
        oldDelegate.highlights != highlights ||
        oldDelegate.arrows != arrows ||
        oldDelegate.flipBoard != flipBoard ||
        oldDelegate.coordinatesVisible != coordinatesVisible;
  }
}

const double pi = math.pi;
