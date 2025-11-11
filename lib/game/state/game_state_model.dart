import 'package:chess_5d/game/logic/game.dart';
import 'package:chess_5d/game/logic/game_options.dart';
import 'package:chess_5d/game/logic/move.dart';

/// Serializable game state model
///
/// This class provides serialization and deserialization of game state
/// for saving and loading games.
class GameStateModel {
  GameStateModel({
    required this.options,
    required this.localPlayer,
    required this.turn,
    required this.present,
    required this.finished,
    required this.moves,
    required this.currentTurnMoves,
  });

  /// Game options
  final GameOptions options;

  /// Local player flags
  final List<bool> localPlayer;

  /// Current turn (0 = black, 1 = white)
  final int turn;

  /// Present turn (minimum end turn across all active timelines)
  final int present;

  /// Whether the game is finished
  final bool finished;

  /// List of all moves made in the game (serialized)
  /// Note: Game class doesn't store full move history, so this is empty
  /// Move history would need to be tracked separately if needed
  final List<Map<String, dynamic>> moves;

  /// List of moves made in the current turn
  final List<Map<String, dynamic>> currentTurnMoves;

  /// Serialize game state to JSON
  Map<String, dynamic> toJson() {
    return {
      'options': options.toJson(),
      'localPlayer': localPlayer,
      'turn': turn,
      'present': present,
      'finished': finished,
      'moves': moves,
      'currentTurnMoves': currentTurnMoves,
    };
  }

  /// Deserialize game state from JSON
  ///
  /// Note: This creates a GameStateModel but does not reconstruct
  /// the full Game object. Use GameStateModel.toGame() to create
  /// a playable Game instance.
  factory GameStateModel.fromJson(Map<String, dynamic> json) {
    return GameStateModel(
      options: GameOptions.fromJson(json['options'] as Map<String, dynamic>),
      localPlayer: List<bool>.from(json['localPlayer'] as List),
      turn: json['turn'] as int,
      present: json['present'] as int,
      finished: json['finished'] as bool,
      moves: List<Map<String, dynamic>>.from(json['moves'] as List<dynamic>),
      currentTurnMoves: List<Map<String, dynamic>>.from(
        json['currentTurnMoves'] as List<dynamic>,
      ),
    );
  }

  /// Create a GameStateModel from a Game instance
  ///
  /// [game] - The game instance to serialize
  factory GameStateModel.fromGame(Game game) {
    return GameStateModel(
      options: game.options,
      localPlayer: game.localPlayer,
      turn: game.turn,
      present: game.present,
      finished: game.finished,
      moves: [], // Game class doesn't store full move history
      currentTurnMoves: game.currentTurnMoves
          .map((move) => move.serialize())
          .toList(),
    );
  }

  /// Create a Game instance from this model
  ///
  /// Note: This reconstructs the game state by replaying all moves.
  /// The game will be in the same state as when it was saved.
  ///
  /// Currently, full move history is not stored in the Game class,
  /// so this method only reconstructs the current turn moves.
  Game toGame() {
    // Create a new game with the same options
    final game = Game(options: options, localPlayer: localPlayer);

    // Apply current turn moves
    for (final moveData in currentTurnMoves) {
      try {
        final move = Move.fromSerialized(game, moveData);
        game.applyMove(move, true); // fastForward = true
      } catch (e) {
        // Skip invalid moves - Move.fromSerialized may throw UnimplementedError
        continue;
      }
    }

    // Set turn and present
    game.turn = turn;
    game.present = present;
    game.finished = finished;

    return game;
  }

  /// Save game state to a file
  ///
  /// This is a placeholder - actual file saving will be implemented
  /// in the UI layer using path_provider or similar.
  Future<void> saveToFile(String filePath) async {
    // TODO: Implement file saving
    throw UnimplementedError('File saving not yet implemented');
  }

  /// Load game state from a file
  ///
  /// This is a placeholder - actual file loading will be implemented
  /// in the UI layer using path_provider or similar.
  static Future<GameStateModel> loadFromFile(String filePath) async {
    // TODO: Implement file loading
    throw UnimplementedError('File loading not yet implemented');
  }
}
