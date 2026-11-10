import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../widgets/home_illustration.dart';

/// Landing page for Pilahin. Camera/ML and local history are intentionally
/// not advertised as completed until the later integration milestones.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LogoMark(),
            SizedBox(width: 10),
            Text('Pilahin', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Riwayat Scan',
            onPressed: () => context.go(AppRoutes.history),
            icon: const Icon(Icons.history_rounded),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.softMint,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: AppColors.deepGreen,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'AI Waste Sorting',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.deepGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Scan sampahmu,\npilah lebih cerdas.',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              const Text(
                'Kenali jenis sampah dari foto, lalu pelajari cara '
                'memilahnya. Klasifikasi offline akan tersedia '
                'setelah model diintegrasikan.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 20),
              const HomeIllustration(),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.scan),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Mulai Scan'),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.menu_book_outlined,
                      title: 'Panduan Pilah',
                      onTap: () => context.go(AppRoutes.guide),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.history_rounded,
                      title: 'Riwayat Scan',
                      onTap: () => context.go(AppRoutes.history),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Text(
                '6 kategori yang dikenali',
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 10),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _CategoryChip('Karton'),
                  _CategoryChip('Kaca'),
                  _CategoryChip('Logam'),
                  _CategoryChip('Kertas'),
                  _CategoryChip('Plastik'),
                  _CategoryChip('Sampah lain'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.softMint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.recycling_rounded, color: AppColors.deepGreen, size: 26),
          Positioned(
            right: 3,
            top: 2,
            child: Icon(
              Icons.eco_rounded,
              color: AppColors.leafGreen,
              size: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFDDE9DF)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.deepGreen, size: 29),
                const SizedBox(height: 10),
                Text(
                  title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(name),
      labelStyle: const TextStyle(
        color: AppColors.deepGreen,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide.none,
      backgroundColor: AppColors.softMint,
      visualDensity: VisualDensity.compact,
    );
  }
}
