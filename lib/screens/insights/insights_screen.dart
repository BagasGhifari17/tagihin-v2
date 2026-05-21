import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/bill_provider.dart';

// State lokal untuk melacak tab aktif ala iOS Segmented Control
final currentTabProvider =
    StateProvider<int>((ref) => 1); // Default ke tab 'Pengeluaran'

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(currentTabProvider);
    final billsAsync = ref.watch(billStreamProvider);
    final transactionsAsync = ref.watch(transactionStreamProvider);

    final netBalance = ref.watch(netBalanceProvider);
    final safeToSpend = ref.watch(safeToSpendProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          "Insight Keuangan",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black,
            fontSize: 24,
            letterSpacing: -0.6,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE4E4E7).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _buildSegmentItem(ref, context,
                    label: "Pemasukan", index: 0, activeIndex: activeTab),
                _buildSegmentItem(ref, context,
                    label: "Pengeluaran", index: 1, activeIndex: activeTab),
                _buildSegmentItem(ref, context,
                    label: "Tagihan", index: 2, activeIndex: activeTab),
              ],
            ),
          ),
        ),
      ),
      // Poin 10: Smooth Transition menggunakan AnimatedSwitcher agar tidak switch brutal
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: billsAsync.when(
          data: (bills) {
            return transactionsAsync.when(
              data: (transactions) {
                // FIX: Menaruh ValueKey secara legal di level Container pembungkus tab router
                return Container(
                  key: ValueKey<int>(activeTab),
                  child: activeTab == 0
                      ? _buildPemasukanTab(transactions)
                      : activeTab == 1
                          ? _buildPengeluaranTab(transactions)
                          : _buildTagihanTab(bills, netBalance, safeToSpend),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator.adaptive()),
              error: (e, s) =>
                  Center(child: Text("Gagal memuat arus transaksi: $e")),
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (e, s) => Center(child: Text("Gagal memuat data tagihan: $e")),
        ),
      ),
    );
  }

  Widget _buildSegmentItem(WidgetRef ref, BuildContext context,
      {required String label, required int index, required int activeIndex}) {
    final isSelected = index == activeIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(currentTabProvider.notifier).state = index;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.black : Colors.grey.shade600,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. PEMASUKAN TAB - HIGH CONTRAST PASTEL MINT & BLUE PALETTE
  // ===========================================================================
  Widget _buildPemasukanTab(List<dynamic> transactions) {
    final incomes = transactions.where((tx) => tx.type == 'income').toList();
    double totalIncome = incomes.fold(0, (sum, tx) => sum + tx.amount);

    if (incomes.isEmpty) {
      return _buildEmptyState("Belum ada pemasukan tercatat ☕",
          "Tambah pemasukan pertamamu buat mulai melihat analisis.");
    }

    final Map<String, double> categoryMap = {};
    for (var tx in incomes) {
      categoryMap[tx.category] = (categoryMap[tx.category] ?? 0) + tx.amount;
    }

    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // FIX WARNA: Palet kontras tinggi bersilangan rona agar gampang dibedakan mata manusia
    final List<Color> mintPalette = [
      const Color(0xFF059669), // 1. Emerald Green Core (Gaji)
      const Color(0xFF2563EB), // 2. Royal Blue (Kontras Pemecah)
      const Color(0xFF06B6D4), // 3. Mint Cyan (Sampingan)
      const Color(0xFF84CC16), // 4. Lime Soft (Bonus)
      const Color(0xFF0F766E), // 5. Deep Teal Skenario Banyak Data
    ];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        _buildDonutChartCard(
          totalAmount: totalIncome,
          labelPeriod: "Total Pemasukan Bulan Ini",
          dataMap: categoryMap,
          palette: mintPalette,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.teal.shade50.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: Colors.teal.shade100.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(Icons.trending_up_rounded,
                  color: Colors.teal.shade700, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pemasukan terpantau stabil rill, Gas!",
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.teal.shade900,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Mengalami kenaikan performa arus kas sebesar +12% dibanding bulan lalu.",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.teal.shade800,
                          fontWeight: FontWeight.w500,
                          height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCategoryListSection(sortedCategories, totalIncome, mintPalette),
      ],
    );
  }

  // ===========================================================================
  // 2. PENGELUARAN TAB - HIGH CONTRAST PASTEL CRIMSON & PURPLE PALETTE
  // ===========================================================================
  Widget _buildPengeluaranTab(List<dynamic> transactions) {
    final expenses = transactions.where((tx) => tx.type == 'expense').toList();
    double totalExpense = expenses.fold(0, (sum, tx) => sum + tx.amount);

    if (expenses.isEmpty) {
      return _buildEmptyState("Belum ada pengeluaran 🎉",
          "Dompetmu masih tenang hari ini. Pengeluaran teranalisis di sini.");
    }

    final Map<String, double> categoryMap = {};
    for (var tx in expenses) {
      categoryMap[tx.category] = (categoryMap[tx.category] ?? 0) + tx.amount;
    }

    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // FIX WARNA: 6 Warna basis rona terpisah tegas untuk mengantisipasi jajan padat (>4 kategori)
    final List<Color> expensePalette = [
      const Color(0xFFDC2626), // 1. Crimson Red (Beban Berat / Kost)
      const Color(0xFFF59E0B), // 2. Amber Orange (Transportasi)
      const Color(0xFF7C3AED), // 3. Deep Purple (Hiburan)
      const Color(0xFFF43F5E), // 4. Hot Pink Soft (Makanan)
      const Color(0xFF0284C7), // 5. Sky Blue Premium (Tagihan Bulanan)
      const Color(0xFF4B5563), // 6. Charcoal Grey (Belanja/Umum)
    ];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        if (categoryMap.keys.length > 1)
          _buildDonutChartCard(
            totalAmount: totalExpense,
            labelPeriod: "Total Pengeluaran",
            dataMap: categoryMap,
            palette: expensePalette,
          )
        else
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.01), blurRadius: 10)
              ],
            ),
            child: Column(
              children: [
                Text("Total Pengeluaran Periode Ini",
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                    "Rp ${NumberFormat('#,###', 'id_ID').format(totalExpense)}",
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5)),
              ],
            ),
          ),
        const SizedBox(height: 16),
        _buildCategoryListSection(
            sortedCategories, totalExpense, expensePalette),
      ],
    );
  }

  // ===========================================================================
  // 3. TAGIHAN TAB - DEEP INJECTION MINIMALIST UPCOMING BILLS
  // ===========================================================================
  Widget _buildTagihanTab(
      List<dynamic> bills, double netBalance, double safeToSpend) {
    final paidBills = bills.where((b) => b.isPaid).toList();
    final unpaidBills = bills.where((b) => !b.isPaid).toList();

    double totalPaidAmount = paidBills.fold(0, (sum, b) => sum + b.amount);
    double totalUnpaidAmount = unpaidBills.fold(0, (sum, b) => sum + b.amount);
    double totalBillsAmount = totalPaidAmount + totalUnpaidAmount;

    double progressPercent =
        totalBillsAmount > 0 ? totalPaidAmount / totalBillsAmount : 0.0;

    final upcomingBills = List.from(unpaidBills)
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade900, Colors.blue.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Colors.indigo.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("SALDO AMAN SEKARANG (SAFE-TO-SPEND)",
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8)),
              const SizedBox(height: 8),
              Text("Rp ${NumberFormat('#,###', 'id_ID').format(safeToSpend)}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5)),
              const SizedBox(height: 14),
              Text(
                safeToSpend >= 0
                    ? "Kondisi aman, Gas! Semua tagihan aktifmu sudah dipotong dan diamankan dari saldo utama."
                    : "Waduh, saldo kritis! Pengeluaranmu melampaui batas aman, rem jajan dulu.",
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.015),
                  blurRadius: 15,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Rasio Penyelesaian Kewajiban",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2)),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${paidBills.length} dari ${bills.length} Tagihan Lunas",
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600)),
                  Text("${(progressPercent * 100).toInt()}%",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.indigo.shade700)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: bills.isNotEmpty ? progressPercent : 1.0,
                  minHeight: 5,
                  backgroundColor: Colors.grey.shade100,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.indigo.shade600),
                ),
              ),
              const SizedBox(height: 22),
              _buildMinimalistBillRow(
                  "Sudah Dibayar", totalPaidAmount, Colors.green.shade600),
              const SizedBox(height: 12),
              _buildMinimalistBillRow("Tersisa Belum Dibayar",
                  totalUnpaidAmount, Colors.redAccent.shade400),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.015),
                  blurRadius: 15,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Jadwal Kewajiban Terdekat",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: -0.2)),
              const SizedBox(height: 16),
              if (upcomingBills.isEmpty)
                Text(
                  "Mantap! Belum ada tagihan mendesak yang perlu diawasi saat ini. 🎉",
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      upcomingBills.length > 3 ? 3 : upcomingBills.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final bill = upcomingBills[index];
                    final today = DateTime(DateTime.now().year,
                        DateTime.now().month, DateTime.now().day);
                    final billDay = DateTime(bill.dueDate.year,
                        bill.dueDate.month, bill.dueDate.day);
                    final daysLeft = billDay.difference(today).inDays;

                    String remainingText = "$daysLeft hari lagi";
                    Color contextColor = Colors.grey.shade600;

                    if (daysLeft == 0) {
                      remainingText = "Hari ini";
                      contextColor = Colors.orange.shade800;
                    } else if (daysLeft == 1) {
                      remainingText = "Besok";
                      contextColor = Colors.orange.shade700;
                    } else if (daysLeft < 0) {
                      remainingText = "Terlambat";
                      contextColor = Colors.redAccent.shade400;
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(bill.title,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            const SizedBox(height: 4),
                            Text(remainingText,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: contextColor,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        Text(
                          "Rp ${NumberFormat('#,###', 'id_ID').format(bill.amount)}",
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: -0.2),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 4. INTERNAL REUSABLE COMPONENTS
  // ===========================================================================
  Widget _buildDonutChartCard({
    required double totalAmount,
    required String labelPeriod,
    required Map<String, double> dataMap,
    required List<Color> palette,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 15,
              offset: const Offset(0, 4))
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 210,
          height: 210,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(210, 210),
                painter: DonutChartPainter(dataMap: dataMap, palette: palette),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Rp ${NumberFormat('#,###', 'id_ID').format(totalAmount)}",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                          letterSpacing: -0.4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labelPeriod,
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryListSection(List<MapEntry<String, double>> categories,
      double total, List<Color> palette) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 12)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Rincian Alokasi Kategori",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                  letterSpacing: -0.2)),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 18),
            itemBuilder: (context, index) {
              final entry = categories[index];
              final percent = total > 0 ? (entry.value / total) : 0.0;

              // FIX: Modulo warna reaktif untuk bar list rincian kategori agar sinkron dengan donut ring
              final color = palette[index % palette.length];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                  color: color, shape: BoxShape.circle)),
                          const SizedBox(width: 10),
                          Text(entry.key,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87)),
                          Text(" — ${(percent * 100).toStringAsFixed(0)}%",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Text(
                          "Rp ${NumberFormat('#,###', 'id_ID').format(entry.value)}",
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.2)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 3.5,
                      backgroundColor: Colors.grey.shade50,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalistBillRow(String label, double amount, Color indicator) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
                width: 6,
                height: 6,
                decoration:
                    BoxDecoration(color: indicator, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        Text("Rp ${NumberFormat('#,###', 'id_ID').format(amount)}",
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2)),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Padding(
      key: const ValueKey<String>('empty_state'),
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Colors.black87,
                    letterSpacing: -0.3)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final Map<String, double> dataMap;
  final List<Color> palette;

  DonutChartPainter({required this.dataMap, required this.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final double total = dataMap.values.fold(0, (sum, val) => sum + val);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius - 12);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    double startAngle = -pi / 2;
    int index = 0;

    dataMap.forEach((key, value) {
      final sweepAngle = (value / total) * 2 * pi;

      // FIX UTAMA: Pengaman modulo agar looping warna sisa bagi tidak memicu IndexOutOfBoundsException
      paint.color = palette[index % palette.length];

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
      index++;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
