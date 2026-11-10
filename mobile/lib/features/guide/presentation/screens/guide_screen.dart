import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/waste_category_icon.dart';
import '../../../result/domain/waste_sorting_guide.dart';

/// General guidance available offline; does not depend on mock or real inference.
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => context.go(AppRoutes.home),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Panduan Pilah'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            key: const ValueKey('guideList'),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
            children: [
              Text(
                'Kenali 6 kategori sampah',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              const Text(
                'Panduan umum berdasarkan jenis material. Aturan daur ulang '
                'berbeda menurut fasilitas dan daerah; periksa ketentuan setempat.',
                style: TextStyle(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.softMint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.eco_outlined, color: AppColors.deepGreen),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Panduan ini bisa dibaca tanpa melakukan scan. '
                        'Kategori bahan harus dipastikan sebelum memilah.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              for (final label in WasteSortingGuide.labels) ...[
                _WasteGuideCard(
                  key: ValueKey('guideCategory_$label'),
                  guide: WasteSortingGuide.fromLabel(label),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WasteGuideCard extends StatelessWidget {
  const _WasteGuideCard({super.key, required this.guide});

  final WasteSortingGuide guide;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFDDE9DF)),
      ),
      child: ExpansionTile(
        leading: WasteCategoryIcon(label: guide.label, size: 48),
        title: Text(
          guide.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          guide.summary,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        children: [
          for (var i = 0; i < guide.steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.softMint,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: AppColors.deepGreen,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(guide.steps[i])),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
