import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecovision/app/app.dart';

void main() {
  testWidgets('Home displays Pilahin branding and scan action', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PilahinApp()));
    await tester.pumpAndSettle();

    expect(find.text('Pilahin'), findsOneWidget);
    expect(find.text('Mulai Scan'), findsOneWidget);
  });

  testWidgets('Scan button navigates to Scan placeholder', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PilahinApp()));
    await tester.pumpAndSettle();

    final scanButton = find.text('Mulai Scan');

    // Scroll sampai tombol terlihat di layar.
    await tester.ensureVisible(scanButton);
    await tester.pumpAndSettle();

    // Tekan tombol setelah terlihat.
    await tester.tap(scanButton);
    await tester.pumpAndSettle();

    expect(find.text('Pilih gambar untuk dianalisis'), findsOneWidget);
  });

  testWidgets('History action navigates to empty history state', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PilahinApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Riwayat Scan'));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada riwayat scan'), findsOneWidget);
  });
}
