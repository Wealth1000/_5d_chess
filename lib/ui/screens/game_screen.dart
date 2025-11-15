import 'package:flutter/material.dart';
import 'package:chess_5d/game/state/game_provider.dart';
import 'package:chess_5d/core/theme_provider.dart';
import 'package:chess_5d/game/logic/board.dart';
import 'package:chess_5d/game/logic/board_setup.dart';
import 'package:chess_5d/game/logic/position.dart';
import 'package:chess_5d/game/rendering/board_widget.dart';

/// Mobile-friendly game screen matching the parallel view layout.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.gameProvider, this.themeProvider});

  final GameProvider gameProvider;
  final ThemeProvider? themeProvider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: const Text('5D Chess'),
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 18),
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.35),
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(6.0),
            minimumSize: const Size(40, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        actions: [
          // Info button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.info, size: 18, color: Color(0xFF2196F3)),
              onPressed: () {},
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.35),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(6.0),
                minimumSize: const Size(40, 40),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable content area with checkered background and boards
            _BlankBoardsView(gameProvider: gameProvider),

            // Fixed view mode buttons at the top
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _ViewModeButtons(),
              ),
            ),

            // Fixed bottom action buttons at the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _BottomActions(gameProvider: gameProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// View mode buttons (History View, Parallel View, Flip Persp.)
class _ViewModeButtons extends StatefulWidget {
  @override
  State<_ViewModeButtons> createState() => _ViewModeButtonsState();
}

class _ViewModeButtonsState extends State<_ViewModeButtons> {
  String _activeView = 'Parallel View';

  void _handleViewChange(String view) {
    setState(() {
      _activeView = view;
    });
    // TODO: Implement view change logic
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ViewButton(
            label: 'History View',
            isActive: _activeView == 'History View',
            onTap: () => _handleViewChange('History View'),
          ),
          const SizedBox(width: 8),
          _ViewButton(
            label: 'Parallel View',
            isActive: _activeView == 'Parallel View',
            onTap: () => _handleViewChange('Parallel View'),
          ),
          const SizedBox(width: 8),
          _ViewButton(
            label: 'Flip Persp.',
            isActive: _activeView == 'Flip Persp.',
            onTap: () => _handleViewChange('Flip Persp.'),
          ),
        ],
      ),
    );
  }
}

/// View mode button (History View, Parallel View, etc.)
class _ViewButton extends StatelessWidget {
  const _ViewButton({required this.label, this.isActive = false, this.onTap});

  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // All buttons use the same color
    const backgroundColor = Colors.black;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom action buttons
class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.gameProvider});

  final GameProvider gameProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _ActionButton(
              label: 'Undo Move',
              color: Colors.grey[800]!,
              onTap: () {
                gameProvider.undoMove();
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _ActionButton(
              label: 'Submit Moves',
              color: Colors.grey[800]!,
              onTap: () {
                gameProvider.submitMoves();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// View for displaying blank boards with scrollable and zoomable background
class _BlankBoardsView extends StatefulWidget {
  const _BlankBoardsView({required this.gameProvider});

  final GameProvider gameProvider;

  @override
  State<_BlankBoardsView> createState() => _BlankBoardsViewState();
}

class _BlankBoardsViewState extends State<_BlankBoardsView> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    // Listen to game provider changes
    widget.gameProvider.addListener(_onGameStateChanged);
  }

  @override
  void dispose() {
    widget.gameProvider.removeListener(_onGameStateChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onGameStateChanged() {
    setState(() {
      // Rebuild when game state changes
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the actual board from the game (main timeline, turn 0)
    final timeline = widget.gameProvider.game.getTimeline(0);
    final board = timeline.getBoard(0);

    if (board == null) {
      // Fallback: create initial board if not found
      final fallbackBoard = BoardSetup.createInitialBoard(
        widget.gameProvider.game,
        0,
        0,
        1,
      );
      return _buildBoardView(fallbackBoard);
    }

    return _buildBoardView(board);
  }

  Widget _buildBoardView(Board board) {
    // Get selected piece and legal moves from game provider
    final selectedPiece = widget.gameProvider.selectedPiece;
    final legalMoves = widget.gameProvider.legalMoves;
    final currentTurn = widget.gameProvider.turn; // 0 = black, 1 = white

    // Convert selected piece to Vec4 position if it exists
    Vec4? selectedSquare;
    if (selectedPiece != null && selectedPiece.board == board) {
      selectedSquare = Vec4(selectedPiece.x, selectedPiece.y, board.l, board.t);
    }

    // Filter legal moves to only show moves on this board (or next turn on same timeline)
    // In 5D chess, moves are to the next turn, so we show moves that will happen on this timeline
    final boardLegalMoves = legalMoves.where((move) {
      return move.l == board.l && (move.t == board.t || move.t == board.t + 1);
    }).toList();

    // Determine outline color based on current turn
    // White's turn (1) = white outline, Black's turn (0) = black outline
    final outlineColor = currentTurn == 1 ? Colors.white : Colors.black;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate content size for centered board
        final contentWidth = constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final contentHeight = constraints.maxHeight > 0
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height;

        return InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.5,
          maxScale: 4.0,
          panEnabled: true,
          scaleEnabled: true,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          child: SizedBox(
            width: contentWidth,
            height: contentHeight,
            child: Stack(
              children: [
                // Infinite checkered background that fills the zoomable area
                Positioned.fill(
                  child: CustomPaint(
                    painter: const _CheckeredBackgroundPainter(
                      squareSize: 40.0,
                    ),
                  ),
                ),
                // Single board with pieces, centered
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: outlineColor, width: 3.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: 300,
                      height: 300,
                      child: BoardWidget(
                        board: board,
                        selectedSquare: selectedSquare,
                        legalMoves: boardLegalMoves,
                        onSquareTapped: _handleSquareTap,
                        coordinatesVisible: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSquareTap(Vec4 position) async {
    widget.gameProvider.handleSquareTap(position);
  }
}

/// Infinite checkered background painter
///
/// Draws an endless checkered pattern by painting squares far beyond
/// the visible area, making it appear infinite even when zooming out.
class _CheckeredBackgroundPainter extends CustomPainter {
  const _CheckeredBackgroundPainter({this.squareSize = 40.0});

  final double squareSize;

  @override
  void paint(Canvas canvas, Size size) {
    // Very large padding so zoom out never shows the end
    const double padding = 5000.0;

    const lightGrey = Color(0xFFE0E0E0);
    const lighterGrey = Color(0xFFF0F0F0);

    final lightPaint = Paint()..color = lightGrey;
    final darkPaint = Paint()..color = lighterGrey;

    // Draw an extremely large region around the visible canvas
    final double left = -padding;
    final double top = -padding;
    final double right = size.width + padding;
    final double bottom = size.height + padding;

    for (double y = top; y < bottom; y += squareSize) {
      for (double x = left; x < right; x += squareSize) {
        final isDark =
            ((x / squareSize).floor() + (y / squareSize).floor()) % 2 == 0;
        canvas.drawRect(
          Rect.fromLTWH(x, y, squareSize, squareSize),
          isDark ? darkPaint : lightPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Action button (Undo, Submit)
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
