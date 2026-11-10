import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Consistent icon-only category artwork; not a scan photograph.
class WasteCategoryIcon extends StatelessWidget {
  const WasteCategoryIcon({super.key, required this.label, this.size = 56});

  final String label;
  final double size;

  static IconData iconFor(String label) => switch (label) {
    'cardboard' => Icons.inventory_2_outlined,
    'glass' => Icons.local_drink_outlined,
    'metal' => Icons.build_outlined,
    'paper' => Icons.description_outlined,
    'plastic' => Icons.recycling_rounded,
    _ => Icons.delete_outline_rounded,
  };

  static Color colorFor(String label) => switch (label) {
    'cardboard' => const Color(0xFF92612D),
    'glass' => const Color(0xFF147F8D),
    'metal' => const Color(0xFF5C6874),
    'paper' => const Color(0xFF477CB6),
    'plastic' => AppColors.deepGreen,
    _ => const Color(0xFF936B3F),
  };

  @override
  Widget build(BuildContext context) {
    final color = colorFor(label);
    return Semantics(
      label: 'Ilustrasi kategori $label, bukan foto hasil scan',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(iconFor(label), color: color, size: size * 0.48),
      ),
    );
  }
}
