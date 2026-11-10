import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/waste_category_icon.dart';
import '../../../result/domain/waste_sorting_guide.dart';
import '../../domain/entities/scan_history_entry.dart';
import '../providers/history_providers.dart';

/// Week 4 history showcase. Initially empty because SQLite persistence is
/// scheduled for Week 6. An opt-in DEMO demonstrates the planned list UI.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _showDemo = false;
  String? _selectedCategory;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final examples = _showDemo
        ? ref.watch(demoHistoryProvider)
        : <ScanHistoryEntry>[];
    final visible = filterDemoHistory(
      examples,
      category: _selectedCategory,
      query: _search,
    );
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: const Text('Riwayat'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            key: const ValueKey('historyList'),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
            children: [
              Text('Riwayat Pemindaian', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text(
                'Riwayat scan sebenarnya akan disimpan di perangkat pada Week 6.',
                style: TextStyle(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 20),
              if (!_showDemo) ...[
                const _EmptyHistory(),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  key: const ValueKey('historyDemoToggle'),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Lihat demo tampilan riwayat'),
                  onPressed: () => setState(() => _showDemo = true),
                ),
              ] else ...[
                Container(
                  key: const ValueKey('historyDemoBanner'),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warmSand,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.science_outlined, color: AppColors.darkText),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'DATA DEMO — bukan riwayat scan pengguna. '
                          'Tanggal, kategori, dan confidence adalah contoh.',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    key: const ValueKey('historyDemoHide'),
                    onPressed: () => setState(() {
                      _showDemo = false;
                      _selectedCategory = null;
                      _search = '';
                    }),
                    icon: const Icon(Icons.close),
                    label: const Text('Tutup demo'),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const ValueKey('historySearch'),
                  onChanged: (value) => setState(() => _search = value),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Cari kategori contoh...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    FilterChip(
                      key: const ValueKey('historyFilter_all'),
                      label: const Text('Semua'),
                      selected: _selectedCategory == null,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = null),
                    ),
                    for (final label in WasteSortingGuide.labels)
                      FilterChip(
                        key: ValueKey('historyFilter_$label'),
                        label: Text(WasteSortingGuide.fromLabel(label).name),
                        selected: _selectedCategory == label,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = label),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${visible.length} contoh ditemukan',
                  key: const ValueKey('historyDemoCount'),
                  style: const TextStyle(color: AppColors.secondaryText),
                ),
                const SizedBox(height: 8),
                if (visible.isEmpty)
                  const _EmptyFilteredHistory()
                else
                  for (final entry in visible) ...[
                    _HistoryDemoCard(
                      key: ValueKey('historyEntry_${entry.id}'),
                      entry: entry,
                    ),
                    const SizedBox(height: 10),
                  ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 42),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDE9DF)),
      ),
      child: const Column(
        children: [
          Icon(Icons.history_rounded, size: 68, color: AppColors.deepGreen),
          SizedBox(height: 16),
          Text(
            'Belum ada riwayat scan',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 10),
          Text(
            'Scan yang kamu lakukan belum disimpan permanen. '
            'Kamu bisa melihat contoh desain daftar riwayat di bawah.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

class _EmptyFilteredHistory extends StatelessWidget {
  const _EmptyFilteredHistory();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 42, color: AppColors.secondaryText),
          SizedBox(height: 10),
          Text('Tidak ada contoh yang cocok dengan filter.'),
        ],
      ),
    );
  }
}

class _HistoryDemoCard extends StatelessWidget {
  const _HistoryDemoCard({super.key, required this.entry});

  final ScanHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final category = WasteSortingGuide.fromLabel(entry.label);
    final time = entry.timestamp;
    final dateLabel =
        '${time.day.toString().padLeft(2, '0')}/'
        '${time.month.toString().padLeft(2, '0')}/${time.year}  '
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFDDE9DF)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showDemoDetail(context, entry),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              WasteCategoryIcon(label: entry.label, size: 58),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'DEMO · bukan hasil scan',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.softMint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${(entry.confidence * 100).round()}%',
                  style: const TextStyle(
                    color: AppColors.deepGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppColors.secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}

void _showDemoDetail(BuildContext context, ScanHistoryEntry entry) {
  final category = WasteSortingGuide.fromLabel(entry.label);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                WasteCategoryIcon(label: entry.label, size: 64),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Contoh: ${category.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'DATA DEMO — bukan klasifikasi AI atau riwayat nyata.',
              style: TextStyle(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 10),
            Text('Confidence contoh: ${(entry.confidence * 100).round()}%'),
            const Divider(height: 28),
            Text(
              'Panduan Pemilahan',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(category.summary),
            const SizedBox(height: 8),
            for (var i = 0; i < category.steps.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text('${i + 1}. ${category.steps[i]}'),
              ),
            const SizedBox(height: 8),
            const Text(
              'Selalu ikuti aturan pemilahan di daerahmu.',
              style: TextStyle(color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    ),
  );
}
