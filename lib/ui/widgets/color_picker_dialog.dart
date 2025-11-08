import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chess_5d/core/utils.dart';
import 'package:chess_5d/core/constants.dart';

class ColorPickerDialog extends StatefulWidget {

  const ColorPickerDialog({
    super.key,
    required this.initialColor,
    required this.title,
  });
  final Color initialColor;
  final String title;

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  // Predefined color palette
  final List<Color> _colorPalette = [
    // Purples
    const Color(0xFF673AB7),
    const Color(0xFF9C27B0),
    const Color(0xFFE91E63),
    const Color(0xFF3F51B5),
    // Blues
    const Color(0xFF2196F3),
    const Color(0xFF03A9F4),
    const Color(0xFF00BCD4),
    // Greens
    const Color(0xFF4CAF50),
    const Color(0xFF8BC34A),
    const Color(0xFFCDDC39),
    // Yellows/Oranges
    const Color(0xFFFFEB3B),
    const Color(0xFFFFC107),
    const Color(0xFFFF9800),
    // Reds
    const Color(0xFFF44336),
    const Color(0xFFE91E63),
    // Grays
    const Color(0xFF9E9E9E),
    const Color(0xFF607D8B),
    // Light colors (for primary/surface)
    const Color(0xFFFFF5F5),
    const Color(0xFFF5F5F5),
    const Color(0xFFE3F2FD),
    const Color(0xFFF3E5F5),
    const Color(0xFFE8F5E9),
    const Color(0xFFFFF9C4),
    const Color(0xFFFFEBEE),
  ];

  @override
  Widget build(BuildContext context) {
    final spacing = Responsive.getSpacing(context);
    final bodySize = ResponsiveFontSize.getBodySize(
      Responsive.getScreenWidth(context),
    );
    final maxWidth = Responsive.getMaxContentWidth(context) * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsets.all(spacing * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: GoogleFonts.inter(
                fontSize: bodySize + 4,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(height: spacing * 2),
            // Selected color preview
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _selectedColor,
                border: Border.all(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing * 2),
            // Color palette grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _colorPalette.length,
              itemBuilder: (context, index) {
                final color = _colorPalette[index];
                final isSelected = _selectedColor.value == color.value;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.grey.withValues(alpha: 0.3),
                        width: isSelected ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondary.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: _getContrastColor(color),
                            size: 20,
                          )
                        : null,
                  ),
                );
              },
            ),
            SizedBox(height: spacing * 2),
            // Custom color picker using sliders
            Text(
              'Custom Color',
              style: GoogleFonts.inter(
                fontSize: bodySize,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: spacing),
            _buildColorSlider(
              'Red',
              _selectedColor.red.toDouble(),
              (value) => setState(() {
                _selectedColor = Color.fromRGBO(
                  value.toInt(),
                  _selectedColor.green,
                  _selectedColor.blue,
                  1.0,
                );
              }),
              Colors.red,
              context,
              bodySize,
              spacing,
            ),
            SizedBox(height: spacing),
            _buildColorSlider(
              'Green',
              _selectedColor.green.toDouble(),
              (value) => setState(() {
                _selectedColor = Color.fromRGBO(
                  _selectedColor.red,
                  value.toInt(),
                  _selectedColor.blue,
                  1.0,
                );
              }),
              Colors.green,
              context,
              bodySize,
              spacing,
            ),
            SizedBox(height: spacing),
            _buildColorSlider(
              'Blue',
              _selectedColor.blue.toDouble(),
              (value) => setState(() {
                _selectedColor = Color.fromRGBO(
                  _selectedColor.red,
                  _selectedColor.green,
                  value.toInt(),
                  1.0,
                );
              }),
              Colors.blue,
              context,
              bodySize,
              spacing,
            ),
            SizedBox(height: spacing * 2),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selectedColor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                  child: Text('Apply', style: GoogleFonts.inter()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
    Color color,
    BuildContext context,
    double bodySize,
    double spacing,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: bodySize - 2,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 255,
            divisions: 255,
            activeColor: color,
            inactiveColor: color.withValues(alpha: 0.3),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            value.toInt().toString(),
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: bodySize - 2,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Color _getContrastColor(Color color) {
    // Calculate relative luminance
    final luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
