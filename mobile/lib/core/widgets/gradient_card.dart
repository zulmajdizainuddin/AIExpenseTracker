import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// A rounded card with a gradient fill and a soft tinted shadow, used for
/// hero/stat surfaces that should stand out from the plain surface cards.
class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.gradient,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  final LinearGradient gradient;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: IconTheme(
          data: const IconThemeData(color: Colors.white),
          child: child,
        ),
      ),
    );
  }
}
