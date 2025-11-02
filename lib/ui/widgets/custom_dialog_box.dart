import 'package:flutter/material.dart';

class CustomDialogBox extends StatelessWidget {
  const CustomDialogBox({
    super.key,
    required this.children,
    this.title,
    this.width = 400,
    this.height,
    this.padding = const EdgeInsets.all(24),
    this.backgroundColor,
    this.borderRadius = 12,
  });
  final List<Widget> children;
  final String? title;
  final double width;
  final double? height;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                  top: padding.top,
                  left: padding.left,
                  right: padding.right,
                  bottom: padding.bottom / 2,
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
                      left: padding.left,
                      right: padding.right,
                      bottom: padding.bottom,
                    )
                  : padding,
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
