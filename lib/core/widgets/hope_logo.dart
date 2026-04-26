import 'package:flutter/material.dart';

class HopeLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool adaptToTheme;

  const HopeLogo({
    super.key,
    this.size = 48,
    this.showText = true,
    this.adaptToTheme = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final containerColor = adaptToTheme
        ? (isDark
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.primaryContainer)
        : const Color(0xFF6C63FF).withAlpha(30);
    final iconColor = adaptToTheme
        ? primaryColor
        : const Color(0xFF6C63FF);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(size * 0.25),
          ),
          child: Icon(
            Icons.favorite,
            size: size * 0.5,
            color: iconColor,
          ),
        ),
        if (showText) ...[
          SizedBox(width: size * 0.25),
          Text(
            'HopeOS',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              fontSize: size * 0.45,
            ),
          ),
        ],
      ],
    );
  }
}
