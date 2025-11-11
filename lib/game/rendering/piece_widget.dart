import 'package:flutter/material.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:chess_5d/game/logic/position.dart';
import 'package:chess_5d/game/rendering/piece_renderer.dart';

/// Widget for displaying a chess piece with drag support
///
/// This widget represents a single piece on the board and handles
/// drag and drop interactions.
class PieceWidget extends StatefulWidget {
  const PieceWidget({
    super.key,
    required this.piece,
    required this.position,
    required this.size,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.isDragging = false,
    this.isSelected = false,
  });

  /// The piece to display
  final Piece piece;

  /// The position of the piece
  final Vec4 position;

  /// Size of the piece widget
  final double size;

  /// Callback when drag starts
  final void Function(Vec4)? onDragStart;

  /// Callback when drag updates
  final void Function(Vec4, Offset)? onDragUpdate;

  /// Callback when drag ends
  final void Function(Vec4, Vec4?)? onDragEnd;

  /// Whether this piece is currently being dragged
  final bool isDragging;

  /// Whether this piece is selected
  final bool isSelected;

  @override
  State<PieceWidget> createState() => _PieceWidgetState();
}

class _PieceWidgetState extends State<PieceWidget> {
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final symbol = PieceRenderer.getPieceSymbol(widget.piece);
    final color = PieceRenderer.getPieceColor(widget.piece);

    return Positioned(
      left: widget.position.x * widget.size,
      top: widget.position.y * widget.size,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
            _dragOffset = details.localPosition;
          });
          widget.onDragStart?.call(widget.position);
        },
        onPanUpdate: (details) {
          setState(() {
            _dragOffset = details.localPosition;
          });
          widget.onDragUpdate?.call(widget.position, details.globalPosition);
        },
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
            _dragOffset = Offset.zero;
          });
          // Calculate drop position from global position
          final dropPosition = _getDropPosition(
            details.velocity.pixelsPerSecond,
          );
          widget.onDragEnd?.call(widget.position, dropPosition);
        },
        child: Transform.translate(
          offset: _isDragging ? _dragOffset : Offset.zero,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? Colors.blue.withOpacity(0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                symbol,
                style: TextStyle(
                  color: color,
                  fontSize: widget.size * 0.7,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Get drop position from drag end velocity
  Vec4? _getDropPosition(Offset velocity) {
    // This would need to be calculated based on the drop location
    // For now, return null to indicate invalid drop
    return null;
  }
}

/// Simplified piece widget for use in board painter
///
/// This is a simpler version that doesn't handle drag and drop,
/// used when pieces are painted directly on the canvas.
class SimplePieceWidget extends StatelessWidget {
  const SimplePieceWidget({super.key, required this.piece, required this.size});

  final Piece piece;
  final double size;

  @override
  Widget build(BuildContext context) {
    final symbol = PieceRenderer.getPieceSymbol(piece);
    final color = PieceRenderer.getPieceColor(piece);

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          symbol,
          style: TextStyle(
            color: color,
            fontSize: size * 0.7,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
