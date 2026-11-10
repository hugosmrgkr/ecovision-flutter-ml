/// A category-specific *general* sorting guide.
///
/// This content is informational: local waste rules and accepted materials vary.
/// Labels remain compatible with the ML `labels.json` contract.
class WasteSortingGuide {
  const WasteSortingGuide({
    required this.label,
    required this.name,
    required this.summary,
    required this.steps,
  });

  final String label;
  final String name;
  final String summary;
  final List<String> steps;

  static const List<String> labels = [
    'cardboard',
    'glass',
    'metal',
    'paper',
    'plastic',
    'trash',
  ];

  static WasteSortingGuide fromLabel(String label) => switch (label) {
    'cardboard' => const WasteSortingGuide(
      label: 'cardboard',
      name: 'Kardus',
      summary: 'Kardus bersih dan kering umumnya lebih mudah dipilah.',
      steps: [
        'Pisahkan kardus dari sampah basah atau sisa makanan.',
        'Lipat agar tidak memakan banyak tempat.',
        'Periksa aturan penerimaan kardus di fasilitas setempat.',
      ],
    ),
    'glass' => const WasteSortingGuide(
      label: 'glass',
      name: 'Kaca',
      summary:
          'Jenis kaca yang dapat didaur ulang berbeda-beda menurut daerah.',
      steps: [
        'Pastikan benda memang berbahan kaca, bukan keramik.',
        'Kosongkan wadah dan bersihkan jika diperlukan.',
        'Pisahkan kaca pecah dengan aman; ikuti aturan setempat.',
      ],
    ),
    'metal' => const WasteSortingGuide(
      label: 'metal',
      name: 'Logam',
      summary: 'Kemasan logam dapat dipilah jika fasilitas menerima jenisnya.',
      steps: [
        'Kosongkan kemasan logam sebelum dipilah.',
        'Bersihkan residu makanan bila perlu.',
        'Pisahkan benda tajam dan ikuti panduan fasilitas setempat.',
      ],
    ),
    'paper' => const WasteSortingGuide(
      label: 'paper',
      name: 'Kertas',
      summary:
          'Kertas yang bersih dan kering biasanya lebih mudah didaur ulang.',
      steps: [
        'Pastikan bahan utamanya kertas dan tidak terlapisi bahan lain.',
        'Jaga kertas tetap kering, terpisah dari sampah basah.',
        'Periksa apakah kertas berminyak atau berlapis diterima setempat.',
      ],
    ),
    'plastic' => const WasteSortingGuide(
      label: 'plastic',
      name: 'Plastik',
      summary: 'Tidak semua jenis plastik diterima oleh fasilitas daur ulang.',
      steps: [
        'Pastikan benda memang berbahan plastik.',
        'Kosongkan dan bersihkan wadah bila diperlukan.',
        'Ikuti aturan lokal untuk jenis plastik yang diterima.',
      ],
    ),
    'trash' => const WasteSortingGuide(
      label: 'trash',
      name: 'Sampah residu',
      summary:
          'Kategori residu tidak otomatis berarti semua bahan harus dibuang.',
      steps: [
        'Periksa dulu apakah bagian tertentu dapat dipilah ulang.',
        'Pisahkan limbah berbahaya atau elektronik untuk penanganan khusus.',
        'Buang sisanya sesuai aturan pengelolaan sampah setempat.',
      ],
    ),
    _ => const WasteSortingGuide(
      label: 'unknown',
      name: 'Tidak diketahui',
      summary: 'Material belum dapat dipastikan.',
      steps: [
        'Periksa bahan benda secara langsung.',
        'Ikuti panduan pemilahan sampah yang berlaku di daerahmu.',
      ],
    ),
  };
}
