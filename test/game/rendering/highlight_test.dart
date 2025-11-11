import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/logic/position.dart';
import 'package:chess_5d/game/rendering/highlight.dart';

void main() {
  group('Highlight', () {
    test('should create highlight with position and type', () {
      final position = Vec4(4, 4, 0, 0);
      final highlight = Highlight(
        position: position,
        type: HighlightType.selected,
      );

      expect(highlight.position, position);
      expect(highlight.type, HighlightType.selected);
      expect(highlight.color, isNull);
    });

    test('should create highlight with custom color', () {
      final position = Vec4(4, 4, 0, 0);
      final highlight = Highlight(
        position: position,
        type: HighlightType.legalMove,
        color: HighlightColor.green,
      );

      expect(highlight.position, position);
      expect(highlight.type, HighlightType.legalMove);
      expect(highlight.color, HighlightColor.green);
    });

    test('should support equality comparison', () {
      final position1 = Vec4(4, 4, 0, 0);
      final position2 = Vec4(4, 4, 0, 0);
      final position3 = Vec4(5, 5, 0, 0);

      final highlight1 = Highlight(
        position: position1,
        type: HighlightType.selected,
      );
      final highlight2 = Highlight(
        position: position2,
        type: HighlightType.selected,
      );
      final highlight3 = Highlight(
        position: position3,
        type: HighlightType.selected,
      );
      final highlight4 = Highlight(
        position: position1,
        type: HighlightType.legalMove,
      );

      expect(highlight1 == highlight2, true);
      expect(highlight1 == highlight3, false);
      expect(highlight1 == highlight4, false);
    });

    test('should support all highlight types', () {
      final position = Vec4(4, 4, 0, 0);
      final types = [
        HighlightType.selected,
        HighlightType.legalMove,
        HighlightType.check,
        HighlightType.lastMove,
        HighlightType.hovered,
      ];

      for (final type in types) {
        final highlight = Highlight(position: position, type: type);
        expect(highlight.type, type);
      }
    });

    test('should support all highlight colors', () {
      final position = Vec4(4, 4, 0, 0);
      final colors = [
        HighlightColor.green,
        HighlightColor.yellow,
        HighlightColor.red,
        HighlightColor.blue,
        HighlightColor.orange,
      ];

      for (final color in colors) {
        final highlight = Highlight(
          position: position,
          type: HighlightType.selected,
          color: color,
        );
        expect(highlight.color, color);
      }
    });
  });
}
