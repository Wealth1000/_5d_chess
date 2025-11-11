import 'package:flutter/material.dart';
import 'package:chess_5d/game/logic/piece.dart';

/// Utility class for rendering chess pieces
///
/// Provides methods to get piece symbols, colors, and rendering properties.
class PieceRenderer {
  /// Unicode chess symbols for pieces
  static const Map<String, Map<int, String>> pieceSymbols = {
    PieceType.king: {PieceSide.black: '♚', PieceSide.white: '♔'},
    PieceType.queen: {PieceSide.black: '♛', PieceSide.white: '♕'},
    PieceType.rook: {PieceSide.black: '♜', PieceSide.white: '♖'},
    PieceType.bishop: {PieceSide.black: '♝', PieceSide.white: '♗'},
    PieceType.knight: {PieceSide.black: '♞', PieceSide.white: '♘'},
    PieceType.pawn: {PieceSide.black: '♟', PieceSide.white: '♙'},
  };

  /// Get the Unicode symbol for a piece
  static String getPieceSymbol(Piece piece) {
    return pieceSymbols[piece.type]?[piece.side] ?? '?';
  }

  /// Get the color for a piece
  static Color getPieceColor(Piece piece) {
    return piece.side == PieceSide.white
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF000000);
  }

  /// Get the background color for a piece (for contrast)
  static Color getPieceBackgroundColor(Piece piece) {
    return piece.side == PieceSide.white
        ? Colors.transparent
        : Colors.transparent;
  }

  /// Paint a piece on a canvas
  ///
  /// [canvas] - The canvas to paint on
  /// [piece] - The piece to paint
  /// [rect] - The rectangle to paint within
  /// [scale] - Scale factor for the piece
  static void paintPiece(Canvas canvas, Piece piece, Rect rect, double scale) {
    final symbol = getPieceSymbol(piece);
    final color = getPieceColor(piece);

    // Create text style
    final textStyle = TextStyle(
      color: color,
      fontSize: rect.height * 0.7 * scale,
      fontWeight: FontWeight.bold,
      fontFamily: 'Arial', // Fallback font
    );

    // Create text painter
    final textPainter = TextPainter(
      text: TextSpan(text: symbol, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Layout and paint
    textPainter.layout();
    final offset = Offset(
      rect.center.dx - textPainter.width / 2,
      rect.center.dy - textPainter.height / 2,
    );
    textPainter.paint(canvas, offset);
  }

  /// Get piece name for display
  static String getPieceName(Piece piece) {
    return '${piece.type} (${piece.side == PieceSide.white ? 'white' : 'black'})';
  }
}
