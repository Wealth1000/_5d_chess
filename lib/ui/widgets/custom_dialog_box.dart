import 'package:flutter/material.dart';

class CustomDialogBox extends StatelessWidget {
  const CustomDialogBox({
    super.key,
    required this.children,
    this.title,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.borderRadius = 16,
  });
  final List<Widget> children;
  final String? title;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final defaultPadding = padding ?? const EdgeInsets.all(24);
    final effectiveWidth = width ?? double.infinity;

    return Center(
      child: Container(
        width: effectiveWidth == double.infinity ? null : effectiveWidth,
        constraints: effectiveWidth == double.infinity
            ? const BoxConstraints()
            : null,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Padding(
                padding: EdgeInsets.only(
                  top: defaultPadding.top,
                  left: defaultPadding.left,
                  right: defaultPadding.right,
                  bottom: defaultPadding.bottom / 2,
                ),
                child: Text(
                  title!,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            Padding(
              padding: title != null
                  ? EdgeInsets.only(
                      left: defaultPadding.left,
                      right: defaultPadding.right,
                      bottom: defaultPadding.bottom,
                    )
                  : defaultPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
