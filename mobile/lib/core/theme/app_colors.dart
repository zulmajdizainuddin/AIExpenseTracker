import 'package:flutter/material.dart';

/// Brand + chart color roles, kept separate from the Material [ColorScheme]
/// (which drives buttons/surfaces) because charts need a fixed, ordered
/// palette that stays stable regardless of theme tonal generation.
class AppColors {
  AppColors._();

  static const Color brand = Color(0xFF6366F1);
  static const Color brandDeep = Color(0xFF4338CA);

  /// Fixed-order categorical palette for charts/category identity. Order is
  /// the color-vision-deficiency-safety mechanism — always assign by index,
  /// never re-sort by value, so a category keeps its color across renders.
  static const List<Color> categorical = [
    Color(0xFF2A78D6), // blue
    Color(0xFF1BAF7A), // aqua
    Color(0xFFEDA100), // yellow
    Color(0xFF008300), // green
    Color(0xFF6366F1), // violet (brand)
    Color(0xFFE34948), // red
    Color(0xFFE87BA4), // magenta
    Color(0xFFEB6834), // orange
  ];

  static const List<Color> categoricalDark = [
    Color(0xFF3987E5),
    Color(0xFF199E70),
    Color(0xFFC98500),
    Color(0xFF008300),
    Color(0xFF9085E9),
    Color(0xFFE66767),
    Color(0xFFD55181),
    Color(0xFFD95926),
  ];

  static Color categoricalAt(int index, {bool dark = false}) {
    final palette = dark ? categoricalDark : categorical;
    return palette[index % palette.length];
  }

  // Status colors — reserved for good/warning/serious/critical states only,
  // never reused as a chart series color.
  static const Color statusGood = Color(0xFF0CA30C);
  static const Color statusWarning = Color(0xFFFAB219);
  static const Color statusCritical = Color(0xFFD03B3B);
}

class AppGradients {
  AppGradients._();

  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

  static const LinearGradient brandDeep = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4338CA), Color(0xFF6366F1)],
  );

  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0CA30C), Color(0xFF1BAF7A)],
  );

  static const LinearGradient warning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEB6834), Color(0xFFD03B3B)],
  );
}
