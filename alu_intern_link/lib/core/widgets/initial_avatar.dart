import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A rounded, colored square showing the first letter of [name].
///
/// Used everywhere we'd normally show a startup/opportunity logo but don't
/// have one uploaded - the color is picked deterministically from the name
/// (same name always maps to the same color) so cards stay visually
/// distinct without us having to store a color per startup.
class InitialAvatar extends StatelessWidget {
  const InitialAvatar({super.key, required this.name, this.size = 48});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final letter = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    final color = AppTheme.avatarPalette[name.hashCode.abs() % AppTheme.avatarPalette.length];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: size * 0.42),
      ),
    );
  }
}
