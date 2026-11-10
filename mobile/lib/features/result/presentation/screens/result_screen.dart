import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../scan/domain/entities/classification_result.dart';
import '../../../scan/domain/entities/scan_image.dart';
import '../../../scan/presentation/viewmodels/scan_view_model.dart';
import '../../domain/waste_sorting_guide.dart';

/// Future-ready result UI. Real inference must explicitly provide isMock=false.
/// In the current W4 build, only the mock repository is wired up.
class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scan = ref.watch(scanViewModelProvider);
    final image = scan.image;
    final result = scan.result;

    void scanAgain() {
      ref.read(scanViewModelProvider.notifier).clear();
      context.go(AppRoutes.scan);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil'),
        leading: IconButton(
          tooltip: 'Kembali ke Scan',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.scan),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: image == null || result == null
              ? _NoResult(onScan: () => context.go(AppRoutes.scan))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                  children: [
                    if (result.isMock) ...[
                      const _DemoBanner(),
                      const SizedBox(height: 18),
                      _PhotoPreview(image: image, isMock: true),
                      const SizedBox(height: 16),
                      _DemoPreview(result: result),
                    ] else ...[
                      _PhotoPreview(image: image, isMock: false),
                      const SizedBox(height: 16),
                      _ClassificationDetails(result: result, isMock: false),
                    ],
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      key: const ValueKey('scanAgainButton'),
                      onPressed: scanAgain,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Scan Lagi'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => context.go(AppRoutes.home),
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Kembali ke Beranda'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('mockDisclaimer'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warmSand,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.science_outlined, color: AppColors.darkText),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Foto ini belum dianalisis AI',
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Mode demo W4. Belum ada prediksi atau confidence '
                  'untuk foto yang kamu pilih. Model TFLite dipasang di W5.',
                  style: TextStyle(color: AppColors.darkText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.image, required this.isMock});

  final ScanImage image;
  final bool isMock;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDAE9DD)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.image_outlined, color: AppColors.deepGreen),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Foto yang kamu pilih',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: AppColors.softMint,
              width: double.infinity,
              height: 230,
              child: Image.memory(
                image.bytes,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Text('Preview gambar tidak tersedia')),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            image.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
          if (isMock) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 17,
                  color: AppColors.secondaryText,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Tidak ada label yang ditentukan untuk foto ini.',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DemoPreview extends StatelessWidget {
  const _DemoPreview({required this.result});

  final ClassificationResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('demoCard'),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDAE9DD)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: const ValueKey('demoExpansion'),
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
          leading: const Icon(
            Icons.design_services_outlined,
            color: AppColors.deepGreen,
          ),
          title: const Text(
            'Lihat contoh desain kartu hasil',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: const Text(
            'Data dummy untuk mengecek UI — tidak terkait foto di atas.',
          ),
          children: [_ClassificationDetails(result: result, isMock: true)],
        ),
      ),
    );
  }
}

class _ClassificationDetails extends StatelessWidget {
  const _ClassificationDetails({required this.result, required this.isMock});

  final ClassificationResult result;
  final bool isMock;

  @override
  Widget build(BuildContext context) {
    final guide = WasteSortingGuide.fromLabel(result.label);
    final confidence = (result.confidence * 100).toStringAsFixed(0);
    final color = _colorFor(guide.label);
    final headline = isMock ? 'Contoh kategori: ${guide.name}' : guide.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFDAE9DD)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isMock ? 'CONTOH HASIL — DATA DEMO' : 'HASIL KLASIFIKASI',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  letterSpacing: 0.6,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.softMint,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(_iconFor(guide.label), color: color, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      headline,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isMock
                          ? 'Confidence contoh (bukan AI)'
                          : 'Confidence model',
                      style: const TextStyle(color: AppColors.secondaryText),
                    ),
                  ),
                  Text(
                    '$confidence%',
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              LinearProgressIndicator(
                value: result.confidence,
                backgroundColor: AppColors.softMint,
                color: color,
                minHeight: 10,
                borderRadius: BorderRadius.circular(8),
              ),
              if (isMock) ...[
                const SizedBox(height: 10),
                const Text(
                  'Contoh tetap. Mengganti foto tidak mengubah label atau angka.',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _GuideCard(guide: guide, isMock: isMock),
        if (result.confidence < 0.70) ...[
          const SizedBox(height: 14),
          _LowConfidenceNote(isMock: isMock),
        ],
      ],
    );
  }

  static Color _colorFor(String label) => switch (label) {
    'glass' => const Color(0xFF237F98),
    'paper' => const Color(0xFF3569A2),
    'metal' => const Color(0xFF596B74),
    'trash' => const Color(0xFF866434),
    _ => AppColors.deepGreen,
  };

  static IconData _iconFor(String label) => switch (label) {
    'cardboard' => Icons.inventory_2_outlined,
    'glass' => Icons.wine_bar_outlined,
    'metal' => Icons.hardware_outlined,
    'paper' => Icons.description_outlined,
    'plastic' => Icons.local_drink_outlined,
    'trash' => Icons.delete_outline_rounded,
    _ => Icons.help_outline,
  };
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.guide, required this.isMock});

  final WasteSortingGuide guide;
  final bool isMock;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.softMint,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.recycling_rounded, color: AppColors.deepGreen),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  isMock ? 'Contoh panduan pemilahan' : 'Panduan pemilahan',
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            guide.summary,
            style: const TextStyle(color: AppColors.darkText),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < guide.steps.length; index++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppColors.deepGreen,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    guide.steps[index],
                    style: const TextStyle(color: AppColors.darkText),
                  ),
                ),
              ],
            ),
            if (index < guide.steps.length - 1) const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
          const Text(
            'Pastikan bahan secara langsung dan ikuti aturan pemilahan setempat.',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _LowConfidenceNote extends StatelessWidget {
  const _LowConfidenceNote({required this.isMock});

  final bool isMock;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warmSand,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.darkText),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              isMock
                  ? 'Simulasi confidence rendah: tampilan ini hanya contoh UI.'
                  : 'Keyakinan model rendah. Coba foto ulang dengan cahaya yang '
                        'baik dan objek utama terlihat jelas. Batas 70% masih '
                        'heuristik dan belum dikalibrasi.',
              style: const TextStyle(color: AppColors.darkText),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResult extends StatelessWidget {
  const _NoResult({required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.analytics_outlined,
              size: 64,
              color: AppColors.deepGreen,
            ),
            const SizedBox(height: 18),
            Text(
              'Belum ada hasil analisis',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Pilih gambar dari kamera atau galeri untuk mencoba alur demo.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onScan, child: const Text('Buka Scan')),
          ],
        ),
      ),
    );
  }
}
