import 'package:flutter/widgets.dart';

/// Width breakpoints. Values follow Material's window-size-class guidance:
/// compact (phones), medium (small tablets / large phones landscape),
/// expanded (tablets, foldables, desktop).
class AppBreakpoints {
  AppBreakpoints._();

  static const double medium = 600;
  static const double expanded = 900;
}

enum ScreenSize { compact, medium, expanded }

extension ScreenSizeContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  ScreenSize get screenSize {
    final width = screenWidth;
    if (width >= AppBreakpoints.expanded) return ScreenSize.expanded;
    if (width >= AppBreakpoints.medium) return ScreenSize.medium;
    return ScreenSize.compact;
  }

  bool get isCompact => screenSize == ScreenSize.compact;
  bool get isExpanded => screenSize == ScreenSize.expanded;

  /// Number of grid columns appropriate for the current width.
  int get gridColumns => switch (screenSize) {
        ScreenSize.compact => 1,
        ScreenSize.medium => 2,
        ScreenSize.expanded => 3,
      };

  /// Horizontal content padding that grows slightly on wider screens so
  /// content doesn't stretch edge-to-edge on tablets.
  double get contentPadding => switch (screenSize) {
        ScreenSize.compact => 16,
        ScreenSize.medium => 24,
        ScreenSize.expanded => 32,
      };

  /// Caps content width on very wide screens (desktop/tablet landscape) so
  /// text and cards don't stretch uncomfortably wide.
  double get maxContentWidth => switch (screenSize) {
        ScreenSize.compact => double.infinity,
        ScreenSize.medium => 720,
        ScreenSize.expanded => 1080,
      };
}

/// Wraps [child] so its width is capped and centered on wide screens,
/// while still filling the available width on phones.
class ContentWidthLimiter extends StatelessWidget {
  const ContentWidthLimiter({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.maxContentWidth),
        child: child,
      ),
    );
  }
}
