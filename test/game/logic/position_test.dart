import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/logic/position.dart';

void main() {
  group('Vec4', () {
    test('should create Vec4 with correct coordinates', () {
      const vec = Vec4(3, 4, 1, 2);
      expect(vec.x, 3);
      expect(vec.y, 4);
      expect(vec.l, 1);
      expect(vec.t, 2);
    });

    test('should create Vec4 from another Vec4', () {
      const original = Vec4(1, 2, 3, 4);
      final copy = Vec4.fromVec4(original);
      expect(copy.x, 1);
      expect(copy.y, 2);
      expect(copy.l, 3);
      expect(copy.t, 4);
    });

    test('should add two Vec4 correctly', () {
      const vec1 = Vec4(1, 2, 3, 4);
      const vec2 = Vec4(5, 6, 7, 8);
      final result = vec1.add(vec2);
      expect(result.x, 6);
      expect(result.y, 8);
      expect(result.l, 10);
      expect(result.t, 12);
    });

    test('should subtract two Vec4 correctly', () {
      const vec1 = Vec4(5, 6, 7, 8);
      const vec2 = Vec4(1, 2, 3, 4);
      final result = vec1.sub(vec2);
      expect(result.x, 4);
      expect(result.y, 4);
      expect(result.l, 4);
      expect(result.t, 4);
    });

    test('should check equality correctly', () {
      const vec1 = Vec4(1, 2, 3, 4);
      const vec2 = Vec4(1, 2, 3, 4);
      const vec3 = Vec4(1, 2, 3, 5);
      expect(vec1.equals(vec2), true);
      expect(vec1.equals(vec3), false);
    });

    test('should use equality operator correctly', () {
      const vec1 = Vec4(1, 2, 3, 4);
      const vec2 = Vec4(1, 2, 3, 4);
      const vec3 = Vec4(1, 2, 3, 5);
      expect(vec1 == vec2, true);
      expect(vec1 == vec3, false);
    });

    test('should have consistent hashCode', () {
      const vec1 = Vec4(1, 2, 3, 4);
      const vec2 = Vec4(1, 2, 3, 4);
      expect(vec1.hashCode, vec2.hashCode);
    });

    test('should validate coordinates correctly', () {
      const valid = Vec4(3, 4, 0, 0);
      const invalidX = Vec4(-1, 4, 0, 0);
      const invalidY = Vec4(3, 8, 0, 0);
      const invalidBoth = Vec4(-1, 8, 0, 0);
      const validBounds = Vec4(0, 0, 0, 0);
      const validBoundsMax = Vec4(7, 7, 0, 0);

      expect(valid.isValid(), true);
      expect(invalidX.isValid(), false);
      expect(invalidY.isValid(), false);
      expect(invalidBoth.isValid(), false);
      expect(validBounds.isValid(), true);
      expect(validBoundsMax.isValid(), true);
    });

    test('should validate 2D coordinates correctly', () {
      const valid = Vec4(3, 4, 100, 200);
      const invalidX = Vec4(-1, 4, 100, 200);
      const invalidY = Vec4(3, 8, 100, 200);

      expect(valid.isValid2D(), true);
      expect(invalidX.isValid2D(), false);
      expect(invalidY.isValid2D(), false);
    });

    test('should get spatial coordinates', () {
      const vec = Vec4(3, 4, 5, 6);
      final spatial = vec.spatial;
      expect(spatial.x, 3);
      expect(spatial.y, 4);
      expect(spatial.l, 0);
      expect(spatial.t, 0);
    });

    test('should get temporal coordinates', () {
      const vec = Vec4(3, 4, 5, 6);
      final temporal = vec.temporal;
      expect(temporal.x, 0);
      expect(temporal.y, 0);
      expect(temporal.l, 5);
      expect(temporal.t, 6);
    });

    test('should serialize to JSON correctly', () {
      const vec = Vec4(1, 2, 3, 4);
      final json = vec.toJson();
      expect(json['x'], 1);
      expect(json['y'], 2);
      expect(json['l'], 3);
      expect(json['t'], 4);
    });

    test('should deserialize from JSON correctly', () {
      final json = {'x': 1, 'y': 2, 'l': 3, 't': 4};
      final vec = Vec4.fromJson(json);
      expect(vec.x, 1);
      expect(vec.y, 2);
      expect(vec.l, 3);
      expect(vec.t, 4);
    });

    test('should convert to string correctly', () {
      const vec = Vec4(1, 2, 3, 4);
      expect(vec.toString(), 'Vec4(1, 2, 3, 4)');
    });

    test('should handle negative timeline coordinates', () {
      const vec = Vec4(3, 4, -1, 5);
      expect(vec.l, -1);
      expect(vec.isValid(), true); // Spatial coordinates are still valid
    });

    test('should handle large turn numbers', () {
      const vec = Vec4(3, 4, 0, 1000);
      expect(vec.t, 1000);
      expect(vec.isValid(), true);
    });
  });
}

