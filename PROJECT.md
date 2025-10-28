# PROJECT STRUCTURE

## Directory Layout

lib/
│
├── main.dart
│
├── core/
│ ├── constants.dart
│ ├── utils.dart
│ └── theme.dart
│
├── game/
│ ├── logic/
│ │ ├── board_state.dart
│ │ ├── piece.dart
│ │ ├── timeline.dart
│ │ ├── move_validator.dart
│ │ └── ai/
│ │ └── ai_engine.dart
│ │
│ ├── rendering/
│ │ ├── board_painter.dart
│ │ ├── piece_widget.dart
│ │ ├── timeline_view.dart
│ │ └── game_scene.dart
│ │
│ ├── state/
│ │ ├── game_state.dart
│ │ └── game_provider.dart
│ │
│ └── flame_bridge/
│ └── adapters.dart
│
└── ui/
├── screens/
│ ├── home_screen.dart
│ ├── game_screen.dart
│ └── settings_screen.dart
│
└── widgets/
├── app_button.dart
└── board_preview.dart


---

## Folder Breakdown

### `core/`
- **constants.dart** — shared constants (dimensions, colors, timing).  
- **utils.dart** — helper math/conversion functions.  
- **theme.dart** — Flutter `ThemeData` config.

### `game/`

#### `logic/`
Pure Dart logic — no Flutter imports.
- **board_state.dart** — board data + operations.  
- **piece.dart** — movement rules + metadata.  
- **timeline.dart** — handles timeboards and their connections.  
- **move_validator.dart** — validates moves.  
- **ai/** — placeholder for later AI opponents or hints.

#### `rendering/`
Handles visuals.
- **board_painter.dart** — draws the board, pieces, and arrows.  
- **piece_widget.dart** — gesture + visual handling for pieces.  
- **timeline_view.dart** — represents a timeline visually.  
- **game_scene.dart** — container for all active timelines.

#### `state/`
Game state management.
- **game_state.dart** — defines overall game state (turns, history, etc).  
- **game_provider.dart** — updates + bridges logic to UI.

#### `flame_bridge/`
Empty for now — used later for adapting logic to **Flame Engine** components.

---

### `ui/`
Flutter UI only.
- **screens/** — Home, Game, and Settings pages.  
- **widgets/** — Reusable components (buttons, board previews).

---

### `main.dart`
Entry point — sets up providers and runs `MaterialApp`.

---

Minimal, clear, functional.
