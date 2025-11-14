import 'package:flutter/material.dart';
import 'package:chess_5d/game/state/game_provider.dart';
import 'package:chess_5d/core/theme_provider.dart';

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
            // Main content area (full screen) with checkered background
            SizedBox.expand(
              child: CustomPaint(painter: _CheckeredBackgroundPainter()),
            ),

            // View mode buttons on top (at the top)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _ViewModeButtons(),
              ),
            ),

            // Bottom action buttons on top (at the bottom)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _BottomActions(),
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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ActionButton(
            label: 'Undo Move',
            color: Colors.black,
            onTap: () {
              // TODO: Implement undo move logic
            },
          ),
          const SizedBox(width: 16),
          _ActionButton(
            label: 'Submit Moves',
            color: Colors.black,
            onTap: () {
              // TODO: Implement submit moves logic
            },
          ),
        ],
      ),
    );
  }
}

/// Checkered background painter
class _CheckeredBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const lightGrey = Color(0xFFE0E0E0);
    const lighterGrey = Color(0xFFF0F0F0);
    const squareSize = 40.0;

    final paint1 = Paint()..color = lightGrey;
    final paint2 = Paint()..color = lighterGrey;

    for (double y = 0; y < size.height; y += squareSize) {
      for (double x = 0; x < size.width; x += squareSize) {
        final rect = Rect.fromLTWH(x, y, squareSize, squareSize);
        final isLight =
            ((x / squareSize).floor() + (y / squareSize).floor()) % 2 == 0;
        canvas.drawRect(rect, isLight ? paint1 : paint2);
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
