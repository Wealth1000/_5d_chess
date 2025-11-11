import 'package:flutter/material.dart';
import 'package:chess_5d/core/utils.dart';
import 'package:chess_5d/game/state/game_provider.dart';
import 'package:chess_5d/game/rendering/game_scene.dart';
import 'package:chess_5d/game/logic/piece.dart';
import 'package:chess_5d/game/logic/position.dart';
import 'package:chess_5d/core/theme_provider.dart';
import 'package:chess_5d/ui/widgets/promotion_dialog.dart';
import 'package:chess_5d/ui/widgets/time_display.dart';

/// Main game playing screen
///
/// This screen displays the game board and handles user interaction.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.gameProvider, this.themeProvider});

  /// Game state provider
  final GameProvider gameProvider;

  /// Theme provider (optional, for theme access)
  final ThemeProvider? themeProvider;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Piece? _selectedPiece;
  List<Vec4> _legalMoves = [];

  @override
  void initState() {
    super.initState();
    widget.gameProvider.addListener(_onGameStateChanged);
    _updateState();
  }

  @override
  void dispose() {
    widget.gameProvider.removeListener(_onGameStateChanged);
    super.dispose();
  }

  void _onGameStateChanged() {
    setState(() {
      _updateState();
    });
  }

  void _updateState() {
    _selectedPiece = widget.gameProvider.selectedPiece;
    _legalMoves = widget.gameProvider.legalMoves;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('5D Chess'),
        actions: [
          // Undo button
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: widget.gameProvider.currentTurnMoves.isNotEmpty
                ? () {
                    widget.gameProvider.undoMove();
                  }
                : null,
            tooltip: 'Undo Move',
          ),

          // Submit button
          ElevatedButton(
            onPressed: widget.gameProvider.canSubmit
                ? () {
                    widget.gameProvider.submitMoves();
                  }
                : null,
            child: const Text('Submit'),
          ),

          // Menu button
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showGameMenu(context);
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.gameProvider,
        builder: (context, child) {
          return Row(
            children: [
              // Game scene (left side)
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Game status bar
                    _buildGameStatusBar(),

                    // Game scene
                    Expanded(
                      child: GameScene(
                        game: widget.gameProvider.game,
                        selectedPiece: _selectedPiece,
                        legalMoves: _legalMoves,
                        onPieceSelected: (piece) {
                          widget.gameProvider.handlePieceSelection(piece);
                        },
                        onMoveMade: (piece, targetPos) {
                          // Promotion is handled in onSquareTapped
                          widget.gameProvider.makeMove(piece, targetPos, null);
                        },
                        onSquareTapped: (position) async {
                          // Check if we need to handle promotion before making the move
                          if (_selectedPiece != null) {
                            final isLegalMove = _legalMoves.any(
                              (move) =>
                                  move.x == position.x &&
                                  move.y == position.y &&
                                  move.l == position.l &&
                                  move.t == position.t,
                            );

                            if (isLegalMove) {
                              final requiresPromotion = widget.gameProvider
                                  .requiresPromotion(_selectedPiece!, position);
                              if (requiresPromotion) {
                                // Show promotion dialog
                                final promotionType =
                                    await _showPromotionDialog(
                                      context,
                                      _selectedPiece!.side,
                                    );
                                if (promotionType != null && mounted) {
                                  widget.gameProvider.makeMove(
                                    _selectedPiece!,
                                    position,
                                    promotionType,
                                  );
                                }
                              } else {
                                // Make move without promotion
                                widget.gameProvider.makeMove(
                                  _selectedPiece!,
                                  position,
                                  null,
                                );
                              }
                            } else {
                              // Not a legal move, try to select/deselect
                              final piece = widget.gameProvider.game.getPiece(
                                position,
                              );
                              if (piece != null &&
                                  piece.side == widget.gameProvider.turn) {
                                widget.gameProvider.selectPiece(piece);
                              } else {
                                widget.gameProvider.deselectPiece();
                              }
                            }
                          } else {
                            // No piece selected, try to select a piece
                            final piece = widget.gameProvider.game.getPiece(
                              position,
                            );
                            if (piece != null &&
                                piece.side == widget.gameProvider.turn) {
                              widget.gameProvider.selectPiece(piece);
                            }
                          }
                        },
                        boardSize: Responsive.getMaxContentWidth(context) * 0.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Move history panel (right side)
              Container(
                width: 200,
                color: Theme.of(context).colorScheme.surface,
                child: _buildMoveHistoryPanel(),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build game status bar
  Widget _buildGameStatusBar() {
    final game = widget.gameProvider.game;
    final hasRunningClocks = game.options.runningClocks;

    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main status row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Current turn
              Text(
                'Turn: ${widget.gameProvider.turn == 1 ? "White" : "Black"}',
                style: Theme.of(context).textTheme.titleMedium,
              ),

              // Game status
              if (widget.gameProvider.isFinished)
                Text(
                  'Game Finished',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.red),
                )
              else if (widget.gameProvider.canSubmit)
                Text(
                  'Ready to Submit',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.green),
                ),

              // Timeline count
              Text(
                'Timelines: ${game.timelineCount[0] + game.timelineCount[1]}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),

          // Time displays (if running clocks)
          if (hasRunningClocks) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Black player time
                TimeDisplay(
                  player: game.players[0],
                  isActive: widget.gameProvider.turn == 0,
                ),
                // White player time
                TimeDisplay(
                  player: game.players[1],
                  isActive: widget.gameProvider.turn == 1,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Show promotion dialog
  Future<int?> _showPromotionDialog(BuildContext context, int side) async {
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PromotionDialog(
          side: side,
          onSelected: (promotionType) {
            Navigator.pop(context, promotionType);
          },
        );
      },
    );
  }

  /// Build move history panel
  Widget _buildMoveHistoryPanel() {
    final moves = widget.gameProvider.currentTurnMoves;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Current Turn Moves',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),

        // Move list
        Expanded(
          child: moves.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No moves yet',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: moves.length,
                  itemBuilder: (context, index) {
                    final move = moves[index];
                    return _buildMoveListItem(move, index);
                  },
                ),
        ),
      ],
    );
  }

  /// Build a single move list item
  Widget _buildMoveListItem(dynamic move, int index) {
    if (move.nullMove) {
      return ListTile(
        dense: true,
        title: Text(
          '${index + 1}. Null move (Timeline ${move.l})',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    final piece = move.sourcePiece;
    if (piece == null) {
      return const SizedBox.shrink();
    }

    final from = move.from;
    final to = move.to;
    if (from == null || to == null) {
      return const SizedBox.shrink();
    }

    // Format move notation (simplified)
    final pieceSymbol = _getPieceSymbol(piece.type);
    final fromSquare = _formatSquare(from.x, from.y);
    final toSquare = _formatSquare(to.x, to.y);
    final promotion = move.promote != null
        ? '=${_getPromotionSymbol(move.promote!)}'
        : '';
    final timeline = move.isInterDimensionalMove && to.l != from.l
        ? ' (L${to.l})'
        : '';
    final turn = move.isInterDimensionalMove && to.t != from.t
        ? ' (T${to.t})'
        : '';

    return ListTile(
      dense: true,
      title: Text(
        '${index + 1}. $pieceSymbol$fromSquare-$toSquare$promotion$timeline$turn',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  /// Get piece symbol for move notation
  String _getPieceSymbol(String pieceType) {
    switch (pieceType) {
      case 'pawn':
        return '';
      case 'rook':
        return 'R';
      case 'knight':
        return 'N';
      case 'bishop':
        return 'B';
      case 'queen':
        return 'Q';
      case 'king':
        return 'K';
      default:
        return '';
    }
  }

  /// Get promotion symbol
  String _getPromotionSymbol(int promotion) {
    switch (promotion) {
      case 1:
        return 'Q';
      case 2:
        return 'N';
      case 3:
        return 'R';
      case 4:
        return 'B';
      default:
        return 'Q';
    }
  }

  /// Format square coordinates (e.g., (0,0) -> "a1")
  String _formatSquare(int x, int y) {
    final file = String.fromCharCode('a'.codeUnitAt(0) + x);
    final rank = (8 - y).toString();
    return '$file$rank';
  }

  /// Show game menu
  void _showGameMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.save),
                title: const Text('Save Game'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement save game functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Save game not yet implemented'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Exit Game'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
