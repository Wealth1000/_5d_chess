import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/logic/position.dart';
import 'package:chess_5d/game/rendering/arrow.dart';

void main() {
  group('Arrow', () {
    test('should create arrow with from and to positions', () {
      final from = Vec4(4, 4, 0, 0);
      final to = Vec4(4, 5, 0, 0);
      final arrow = Arrow(from: from, to: to, type: ArrowType.legalMove);

      expect(arrow.from, from);
      expect(arrow.to, to);
      expect(arrow.type, ArrowType.legalMove);
      expect(arrow.color, isNull);
    });

    test('should create arrow with custom color', () {
      final from = Vec4(4, 4, 0, 0);
      final to = Vec4(4, 5, 0, 1);
      final arrow = Arrow(
        from: from,
        to: to,
        type: ArrowType.timeTravel,
        color: ArrowColor.green,
      );

      expect(arrow.from, from);
      expect(arrow.to, to);
      expect(arrow.type, ArrowType.timeTravel);
      expect(arrow.color, ArrowColor.green);
    });

    test('should support equality comparison', () {
      final from1 = Vec4(4, 4, 0, 0);
      final to1 = Vec4(4, 5, 0, 0);
      final from2 = Vec4(4, 4, 0, 0);
      final to2 = Vec4(4, 5, 0, 0);
      final from3 = Vec4(5, 5, 0, 0);
      final to3 = Vec4(5, 6, 0, 0);

      final arrow1 = Arrow(from: from1, to: to1, type: ArrowType.legalMove);
      final arrow2 = Arrow(from: from2, to: to2, type: ArrowType.legalMove);
      final arrow3 = Arrow(from: from3, to: to3, type: ArrowType.legalMove);
      final arrow4 = Arrow(from: from1, to: to1, type: ArrowType.timeTravel);

      expect(arrow1 == arrow2, true);
      expect(arrow1 == arrow3, false);
      expect(arrow1 == arrow4, false);
    });

    test('should support all arrow types', () {
      final from = Vec4(4, 4, 0, 0);
      final to = Vec4(4, 5, 0, 0);
      final types = [
        ArrowType.timeTravel,
        ArrowType.check,
        ArrowType.legalMove,
        ArrowType.lastMove,
      ];

      for (final type in types) {
        final arrow = Arrow(from: from, to: to, type: type);
        expect(arrow.type, type);
      }
    });

    test('should support all arrow colors', () {
      final from = Vec4(4, 4, 0, 0);
      final to = Vec4(4, 5, 0, 1);
      final colors = [
        ArrowColor.green,
        ArrowColor.yellow,
        ArrowColor.red,
        ArrowColor.blue,
        ArrowColor.orange,
      ];

      for (final color in colors) {
        final arrow = Arrow(
          from: from,
          to: to,
          type: ArrowType.timeTravel,
          color: color,
        );
        expect(arrow.color, color);
      }
    });

    test('should handle time travel arrows across timelines', () {
      final from = Vec4(4, 4, 0, 0);
      final to = Vec4(4, 5, 1, 0); // Different timeline
      final arrow = Arrow(from: from, to: to, type: ArrowType.timeTravel);

      expect(arrow.from.l, 0);
      expect(arrow.to.l, 1);
      expect(arrow.type, ArrowType.timeTravel);
    });
  });
}
