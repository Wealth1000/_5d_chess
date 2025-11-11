import 'package:chess_5d/game/logic/variants/standard_variant.dart';
import 'package:chess_5d/game/logic/variants/variant.dart';

/// Factory for creating variant instances
///
/// This factory creates variant instances based on variant names.
/// It provides a centralized way to create and manage variants.
class VariantFactory {
  /// Create a variant by name
  ///
  /// [name] - Variant name (e.g., 'Standard', 'NoBishops', etc.)
  ///
  /// Returns a Variant instance, or throws an ArgumentError if variant not found.
  static Variant createVariant(String name) {
    switch (name.toLowerCase()) {
      case 'standard':
        return StandardVariant();
      // TODO: Add more variants in future phases
      // case 'nobishops':
      //   return NoBishopsVariant();
      // case 'noknights':
      //   return NoKnightsVariant();
      default:
        throw ArgumentError('Unknown variant: $name');
    }
  }

  /// Get list of available variant names
  ///
  /// Returns a list of all available variant names.
  static List<String> getAvailableVariants() {
    return [
      'Standard',
      // TODO: Add more variants in future phases
      // 'NoBishops',
      // 'NoKnights',
      // 'NoRooks',
      // 'NoQueens',
      // 'KnightsVsBishops',
      // 'Random',
      // 'Simple',
    ];
  }

  /// Get description for a variant
  ///
  /// [name] - Variant name
  ///
  /// Returns a description of the variant, or null if variant not found.
  static String? getVariantDescription(String name) {
    switch (name.toLowerCase()) {
      case 'standard':
        return 'Standard 5D Chess with all pieces (pawn, rook, knight, bishop, queen, king)';
      // TODO: Add descriptions for more variants
      default:
        return null;
    }
  }
}
