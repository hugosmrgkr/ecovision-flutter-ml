import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// A lightweight illustration built with Flutter widgets only.
/// No mockup image, web request, or extra assets are required.
class HomeIllustration extends StatelessWidget {
  const HomeIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 226,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF8EB), Color(0xFFD9F1DD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          const Positioned(
            left: -22,
            bottom: -42,
            child: _SoftCircle(diameter: 160, color: Color(0xFFC7EACB)),
          ),
          const Positioned(
            right: -30,
            top: -45,
            child: _SoftCircle(diameter: 160, color: Color(0xFFD0EFD4)),
          ),
          const Positioned(
            left: 12,
            bottom: 80,
            child: Icon(Icons.eco_rounded, color: Color(0xFF8CCF8F), size: 52),
          ),
          const Positioned(
            right: 13,
            bottom: 84,
            child: Icon(Icons.eco_rounded, color: Color(0xFF8CCF8F), size: 52),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(17, 15, 17, 17),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.eco_outlined,
                      color: AppColors.deepGreen,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Satu scan, langkah kecil untuk bumi',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Icon(
                  Icons.recycling_rounded,
                  size: 52,
                  color: AppColors.leafGreen,
                ),
                const Spacer(),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _WasteBin(
                        label: 'Kertas',
                        icon: Icons.description_outlined,
                        color: Color(0xFF5EACD7),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _WasteBin(
                        label: 'Plastik',
                        icon: Icons.local_drink_outlined,
                        color: Color(0xFFE5B73F),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _WasteBin(
                        label: 'Lainnya',
                        icon: Icons.recycling_rounded,
                        color: Color(0xFF15834E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  const _SoftCircle({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _WasteBin extends StatelessWidget {
  const _WasteBin({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F0B6E3A),
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        Container(
          height: 77,
          margin: const EdgeInsets.symmetric(horizontal: 7),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
              bottom: Radius.circular(15),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 29, color: Colors.white),
                const SizedBox(height: 5),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
