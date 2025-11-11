import 'package:flutter_test/flutter_test.dart';
import 'package:chess_5d/game/logic/variants/variant_factory.dart';
import 'package:chess_5d/game/logic/variants/standard_variant.dart';

void main() {
  group('VariantFactory', () {
    test('should create standard variant', () {
      final variant = VariantFactory.createVariant('Standard');

      expect(variant, isA<StandardVariant>());
      expect(variant.name, 'Standard');
    });

    test('should create standard variant case-insensitively', () {
      final variant1 = VariantFactory.createVariant('standard');
      final variant2 = VariantFactory.createVariant('STANDARD');
      final variant3 = VariantFactory.createVariant('Standard');

      expect(variant1.name, 'Standard');
      expect(variant2.name, 'Standard');
      expect(variant3.name, 'Standard');
    });

    test('should throw ArgumentError for unknown variant', () {
      expect(
        () => VariantFactory.createVariant('UnknownVariant'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should get available variants', () {
      final variants = VariantFactory.getAvailableVariants();

      expect(variants, isNotEmpty);
      expect(variants, contains('Standard'));
    });

    test('should get variant description for standard variant', () {
      final description = VariantFactory.getVariantDescription('Standard');

      expect(description, isNotNull);
      expect(description, contains('Standard'));
      expect(description, contains('5D Chess'));
    });

    test('should get variant description case-insensitively', () {
      final description1 = VariantFactory.getVariantDescription('standard');
      final description2 = VariantFactory.getVariantDescription('STANDARD');

      expect(description1, isNotNull);
      expect(description2, isNotNull);
      expect(description1, description2);
    });

    test('should return null for unknown variant description', () {
      final description = VariantFactory.getVariantDescription(
        'UnknownVariant',
      );

      expect(description, isNull);
    });
  });
}
