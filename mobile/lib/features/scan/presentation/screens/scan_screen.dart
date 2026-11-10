import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/scan_image.dart';
import '../viewmodels/scan_view_model.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(scanViewModelProvider.notifier).recoverLostImage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scan = ref.watch(scanViewModelProvider);
    final viewModel = ref.read(scanViewModelProvider.notifier);
    final busy =
        scan.status == ScanStatus.picking ||
        scan.status == ScanStatus.analyzing;
    final canAnalyze = scan.image != null && !busy;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Kembali',
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: const Text('Scan'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _Steps(activeIndex: scan.status == ScanStatus.analyzing ? 2 : 1),
              const SizedBox(height: 22),
              Text(
                'Pilih gambar untuk dianalisis',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Ambil foto satu objek sampah atau pilih dari galeri.',
                style: TextStyle(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 18),
              Container(
                height: 280,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFDCE9DF)),
                  color: AppColors.softMint,
                ),
                child: scan.image == null
                    ? const _EmptyPreview()
                    : Image.memory(
                        scan.image!.bytes,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                        errorBuilder: (context, error, stack) => const Center(
                          child: Text('Gagal menampilkan gambar'),
                        ),
                      ),
              ),
              if (scan.image != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        scan.image!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.secondaryText),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: busy ? null : viewModel.clear,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Hapus'),
                    ),
                  ],
                ),
              ],
              if (scan.errorMessage != null) ...[
                const SizedBox(height: 12),
                Semantics(
                  liveRegion: true,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded),
                        const SizedBox(width: 8),
                        Expanded(child: Text(scan.errorMessage!)),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              const Text(
                'Pilih sumber gambar',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: busy
                          ? null
                          : () => viewModel.pick(ScanImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Kamera'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: busy
                          ? null
                          : () => viewModel.pick(ScanImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Galeri'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: canAnalyze
                    ? () async {
                        final ready = await viewModel.analyze();
                        if (!context.mounted) return;
                        if (ready) context.go(AppRoutes.result);
                      }
                    : null,
                icon: busy && scan.status == ScanStatus.analyzing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome_outlined),
                label: Text(
                  scan.status == ScanStatus.analyzing
                      ? 'Memproses simulasi...'
                      : 'Analisis (Simulasi)',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'MODE DEMO: Hasilnya contoh tetap, bukan prediksi gambar oleh AI. '
                'Model TFLite asli diintegrasikan pada Week 5.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 62,
            color: AppColors.deepGreen,
          ),
          SizedBox(height: 12),
          Text('Belum ada gambar dipilih'),
        ],
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps({required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepBadge(number: '1', text: 'Pilih Gambar', active: activeIndex == 1),
        Expanded(child: Container(height: 1, color: Colors.black12)),
        _StepBadge(number: '2', text: 'Analisis', active: activeIndex == 2),
        Expanded(child: Container(height: 1, color: Colors.black12)),
        const _StepBadge(number: '3', text: 'Hasil'),
      ],
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({
    required this.number,
    required this.text,
    this.active = false,
  });

  final String number;
  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: active ? AppColors.deepGreen : Colors.black12,
          child: Text(
            number,
            style: TextStyle(color: active ? Colors.white : Colors.black54),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: active ? AppColors.deepGreen : AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}
