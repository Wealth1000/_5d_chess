import 'package:flutter/material.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:chess_5d/game/rendering/piece_renderer.dart';
import 'package:chess_5d/core/utils.dart';
import 'package:chess_5d/core/constants.dart';

/// Dialog for selecting a piece to promote a pawn to
///
/// This dialog is shown when a pawn reaches the 8th rank (for white)
/// or 1st rank (for black).
class PromotionDialog extends StatelessWidget {
  const PromotionDialog({
    super.key,
    required this.side,
    required this.onSelected,
  });

  /// Side of the pawn being promoted (0 = black, 1 = white)
  final int side;

  /// Callback when a piece is selected
  /// Returns the promotion type integer (1=Queen, 2=Knight, 3=Rook, 4=Bishop)
  final void Function(int) onSelected;

  @override
  Widget build(BuildContext context) {
    final screenWidth = Responsive.getScreenWidth(context);
    final spacing = Responsive.getSpacing(context);
    final bodySize = ResponsiveFontSize.getBodySize(screenWidth);

    // Pieces available for promotion with their type codes
    // 1=Queen, 2=Knight, 3=Rook, 4=Bishop
    const promotionPieces = [
      (type: PieceType.queen, code: 1),
      (type: PieceType.knight, code: 2),
      (type: PieceType.rook, code: 3),
      (type: PieceType.bishop, code: 4),
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(spacing * 2),
        constraints: BoxConstraints(
          maxWidth: Responsive.getMaxContentWidth(context) * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Promote Pawn',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: spacing * 2),
            Text(
              'Choose a piece to promote to:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: spacing * 2),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: spacing,
              runSpacing: spacing,
              children: promotionPieces.map((piece) {
                // Create a simple piece-like object for display
                final symbol = _getPieceSymbol(side, piece.type);

                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    onSelected(piece.code);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        symbol,
                        style: TextStyle(
                          fontSize: 40,
                          color: side == PieceSide.white
                              ? const Color(0xFFFFFFFF)
                              : const Color(0xFF000000),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: spacing),
          ],
        ),
      ),
    );
  }

  /// Get piece symbol for a given side and type
  String _getPieceSymbol(int side, String type) {
    const symbols = {
      PieceType.queen: {PieceSide.black: '♛', PieceSide.white: '♕'},
      PieceType.rook: {PieceSide.black: '♜', PieceSide.white: '♖'},
      PieceType.bishop: {PieceSide.black: '♝', PieceSide.white: '♗'},
      PieceType.knight: {PieceSide.black: '♞', PieceSide.white: '♘'},
    };

    return symbols[type]?[side] ?? '?';
  }
}
