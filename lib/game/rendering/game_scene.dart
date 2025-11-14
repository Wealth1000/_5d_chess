import 'package:flutter/material.dart';
import 'package:chess_5d/game/logic/game.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:chess_5d/game/logic/position.dart';
import 'package:chess_5d/game/rendering/timeline_view.dart';
import 'package:chess_5d/game/rendering/highlight.dart';
import 'package:chess_5d/game/rendering/arrow.dart';

/// Main game rendering container
///
/// This widget displays the entire game state with all timelines,
/// handles piece selection, move making, and timeline navigation.
class GameScene extends StatefulWidget {
  const GameScene({
    super.key,
    required this.game,
    this.onPieceSelected,
    this.onMoveMade,
    this.onSquareTapped,
    this.selectedPiece,
    this.legalMoves = const [],
    this.boardSize = 300.0,
    this.showAllTimelines = true,
    this.flipBoard = false,
  });

  /// The game state to display
  final Game game;

  /// Callback when a piece is selected (null to deselect)
  final void Function(Piece?)? onPieceSelected;

  /// Callback when a move is made
  final void Function(Piece, Vec4)? onMoveMade;

  /// Callback when a square is tapped
  /// Can be async to handle promotion dialogs
  final Future<void> Function(Vec4)? onSquareTapped;

  /// Currently selected piece
  final Piece? selectedPiece;

  /// List of legal moves for the selected piece
  final List<Vec4> legalMoves;

  /// Size of each board
  final double boardSize;

  /// Whether to show all timelines or just active ones
  final bool showAllTimelines;

  /// Whether to flip the board
  final bool flipBoard;

  @override
  State<GameScene> createState() => _GameSceneState();
}

class _GameSceneState extends State<GameScene> {
  Vec4? _selectedSquare;
  int? _selectedTurn;

  @override
  void initState() {
    super.initState();
    _updateSelection();
  }

  @override
  void didUpdateWidget(GameScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPiece != widget.selectedPiece) {
      _updateSelection();
    }
  }

  void _updateSelection() {
    if (widget.selectedPiece != null) {
      final piece = widget.selectedPiece!;
      _selectedSquare = Vec4(piece.x, piece.y, piece.board!.l, piece.board!.t);
      _selectedTurn = piece.board!.t;
    } else {
      _selectedSquare = null;
      _selectedTurn = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use game.present directly (it's already calculated)
    final presentTurn = widget.game.present;

    // Get all timelines
    final timelines = <dynamic>[];
    for (final timelineDirection in widget.game.timelines) {
      for (final timeline in timelineDirection) {
        if (widget.showAllTimelines || timeline.isActive) {
          timelines.add(timeline);
        }
      }
    }

    // Build highlights from game state
    final highlights = _buildHighlights();

    // Build arrows from game state
    final arrows = _buildArrows();

    // If no timelines, show empty state
    if (timelines.isEmpty) {
      return Center(
        child: Text(
          'No timelines available',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Timeline views
          ...timelines.map((timeline) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TimelineView(
                timeline: timeline,
                presentTurn: presentTurn,
                selectedTurn: _selectedTurn,
                selectedSquare: _selectedSquare,
                legalMoves: widget.legalMoves,
                highlights: highlights,
                arrows: arrows,
                onBoardSelected: (turn) {
                  setState(() {
                    _selectedTurn = turn;
                  });
                },
                onSquareTapped: _handleSquareTap,
                boardSize: widget.boardSize,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Build highlights from game state
  List<Highlight> _buildHighlights() {
    final highlights = <Highlight>[];

    // Add selected square highlight
    if (_selectedSquare != null) {
      highlights.add(
        Highlight(position: _selectedSquare!, type: HighlightType.selected),
      );
    }

    // Add legal move highlights
    for (final move in widget.legalMoves) {
      highlights.add(Highlight(position: move, type: HighlightType.legalMove));
    }

    // Add check highlights from game state
    // displayedChecks is a List<List<Vec4>> where each inner list contains
    // the king position and attacking pieces
    for (final checkList in widget.game.displayedChecks) {
      if (checkList.isNotEmpty) {
        // First element is the king position
        final kingPos = checkList[0];
        highlights.add(Highlight(position: kingPos, type: HighlightType.check));
      }
    }

    return highlights;
  }

  /// Build arrows from game state
  List<Arrow> _buildArrows() {
    final arrows = <Arrow>[];

    // Add arrows for time travel moves if needed
    // This would be populated from game state or move history

    return arrows;
  }

  /// Build game info widget
  Widget _buildGameInfo(int presentTurn) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Turn: ${widget.game.turn == 1 ? "White" : "Black"}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            'Present: $presentTurn',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            'Timelines: ${widget.game.timelineCount[0] + widget.game.timelineCount[1]}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }

  /// Handle square tap
  Future<void> _handleSquareTap(Vec4 position) async {
    // Call onSquareTapped - it will handle promotion if needed
    await widget.onSquareTapped?.call(position);
  }
}
