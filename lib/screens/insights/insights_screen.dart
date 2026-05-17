import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/bill_provider.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(billStreamProvider);
    final transactionsAsync = ref.watch(transactionStreamProvider);

    final netBalance = ref.watch(netBalanceProvider);
    final safeToSpend = ref.watch(safeToSpendProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),
        elevation: 0,
        title: const Text(
          "Insight Mingguan",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22),
        ),
      ),
      body: billsAsync.when(
        data: (bills) {
          return transactionsAsync.when(
            data: (transactions) {
              // ---------------------------------------------------------------
              // CORE SMART ENGINE: KALKULASI TREN & BEHAVIOR (Poin 1 & 3)
              // ---------------------------------------------------------------
              final unpaidBills = bills.where((b) => !b.isPaid).toList();
              final totalBillsCount = bills.length;
              final paidBillsCount = bills.where((b) => b.isPaid).length;
              double progressPercent =
                  totalBillsCount > 0 ? paidBillsCount / totalBillsCount : 0.0;

              double bebanTagihan = netBalance - safeToSpend;

              // Ambil semua data transaksi bertipe pengeluaran (expense)
              final expenses =
                  transactions.where((tx) => tx.type == 'expense').toList();

              // LOGIKA TREN MINGGUAN: Bandingkan pengeluaran minggu ini vs minggu lalu (Simulasi Pintar)
              double totalExpenseWeekIni = 0;
              double totalExpenseWeekLalu = 0;
              final now = DateTime.now();

              for (var tx in expenses) {
                final diffDays = now.difference(tx.date).inDays;
                if (diffDays <= 7) {
                  totalExpenseWeekIni += tx.amount;
                } else if (diffDays > 7 && diffDays <= 14) {
                  totalExpenseWeekLalu += tx.amount;
                }
              }

              // Hitung persentase penurunan/kenaikan disiplin jajan harian
              String trendText =
                  "Pengeluaranmu minggu ini cukup stabil dibanding minggu lalu.";
              IconData trendIcon = Icons.trending_flat_rounded;
              Color trendColor = Colors.blueGrey.shade700;

              if (totalExpenseWeekLalu > 0) {
                double selisihPercent =
                    ((totalExpenseWeekLalu - totalExpenseWeekIni) /
                            totalExpenseWeekLalu) *
                        100;
                if (selisihPercent > 0) {
                  trendText =
                      "Mantap! Pengeluaranmu turun ${selisihPercent.toStringAsFixed(0)}% dibanding minggu lalu. Lebih hemat! 🎉";
                  trendIcon = Icons.trending_down_rounded;
                  trendColor = Colors.green.shade800;
                } else if (selisihPercent < 0) {
                  trendText =
                      "Waduh, jajanmu naik ${selisihPercent.abs().toStringAsFixed(0)}% dari minggu lalu. Mulai rem tipis-tipis, Gas.";
                  trendIcon = Icons.trending_up_rounded;
                  trendColor = Colors.orange.shade900;
                }
              }

              // LOGIKA SEGMENTED ALLOCATION BAR (Poin 1 - Menghindari Visual Bohong)
              // Total acuan bar adalah nilai Total Arus Masuk (netBalance)
              double totalBarAcuan = netBalance > 0 ? netBalance : 1.0;

              // Hitung presentase porsi murni untuk Flex Layout
              int bebanFlex = ((bebanTagihan / totalBarAcuan) * 100).toInt();
              int safeFlex = ((safeToSpend / totalBarAcuan) * 100).toInt();

              // Pengaman komponen visual agar tidak ghaib/menciut ke 0 piksel
              if (bebanTagihan > 0 && bebanFlex == 0) {
                bebanFlex = 3; // Kasih porsi minimal 3% biar keliatan merahnya
              }
              if (safeToSpend > 0 && safeFlex == 0) safeFlex = 3;

              // Sisa dari total bar 100% dialokasikan untuk sisa ruang dasar uang masuk
              int sisaUangMasukFlex = 100 - (bebanFlex + safeFlex);
              if (sisaUangMasukFlex < 0) sisaUangMasukFlex = 0;

              // Jembatan Teks Informasi Tagihan Terdekat
              String tagihanKonteksText =
                  "Semua kewajiban aman terpantau lunas.";
              if (unpaidBills.isNotEmpty) {
                final nextBill = unpaidBills.first;
                final today = DateTime(now.year, now.month, now.day);
                final billDay = DateTime(nextBill.dueDate.year,
                    nextBill.dueDate.month, nextBill.dueDate.day);
                final daysLeft = billDay.difference(today).inDays;

                if (daysLeft == 0) {
                  tagihanKonteksText =
                      "Tagihan '${nextBill.title}' jatuh tempo hari ini!";
                } else if (daysLeft == 1) {
                  tagihanKonteksText =
                      "Tagihan '${nextBill.title}' besok jatuh tempo, Gas.";
                } else if (daysLeft > 1) {
                  tagihanKonteksText =
                      "1 tagihan terdekat ('${nextBill.title}') tersisa $daysLeft hari lagi.";
                }
              }

              // LOGIKA EMOTIONAL COMPANION BOX BG COLOR
              Color insightCardBg = Colors.blue.shade50.withValues(alpha: 0.4);
              Color insightTextColor = Colors.blue.shade900;
              IconData insightIcon = Icons.wb_sunny_rounded;

              if (safeToSpend < 0) {
                insightCardBg = Colors.red.shade50.withValues(alpha: 0.4);
                insightTextColor = Colors.red.shade900;
                insightIcon = Icons.error_outline_rounded;
              }

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // 1. HERO SECTION: STRUKTUR SEGMENTED ALLOCATION BAR (Poin 1 - Anti Misleading)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.015),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Struktur Alokasi Dana",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 18),

                        // SEGMENTED BAR: [HIJAU TOTAL] -> [MERAH BEBAN] -> [BIRU SISA BERSIH]
                        Container(
                          height: 12,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.green.withValues(
                                alpha:
                                    0.2), // Base background hijau transparan lembut
                          ),
                          child: Row(
                            children: [
                              // Segmen Merah (Beban Tagihan)
                              if (bebanTagihan > 0)
                                Expanded(
                                  flex: bebanFlex,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.horizontal(
                                        left: const Radius.circular(6),
                                        right: Radius.circular(safeFlex == 0 &&
                                                sisaUangMasukFlex == 0
                                            ? 6
                                            : 0),
                                      ),
                                    ),
                                  ),
                                ),
                              // Segmen Biru (Safe-to-Spend Bersih)
                              if (safeToSpend > 0)
                                Expanded(
                                  flex: safeFlex,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade600,
                                      borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(
                                            bebanFlex == 0 ? 6 : 0),
                                        right: Radius.circular(
                                            sisaUangMasukFlex == 0 ? 6 : 0),
                                      ),
                                    ),
                                  ),
                                ),
                              // Segmen Hijau Sisa (Sisa Arus Masuk Pokok)
                              if (sisaUangMasukFlex > 0)
                                Expanded(
                                  flex: sisaUangMasukFlex,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade600,
                                      borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(
                                            bebanFlex == 0 && safeFlex == 0
                                                ? 6
                                                : 0),
                                        right: const Radius.circular(6),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildAllocationRow(Colors.green.shade600,
                            "Total Kantong (Arus Masuk)", netBalance),
                        const SizedBox(height: 12),
                        _buildAllocationRow(Colors.redAccent,
                            "Terikat Tagihan (Beban)", bebanTagihan),
                        const SizedBox(height: 12),
                        const Divider(height: 20),
                        _buildAllocationRow(Colors.blue.shade600,
                            "Sisa Bersih (Safe-to-Spend)", safeToSpend,
                            isBold: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. HERO CARD: SMART FINANCIAL INSIGHT COMPANION
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: insightCardBg,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(insightIcon, color: insightTextColor, size: 24),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Kondisi Keuangan",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: insightTextColor),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                safeToSpend < 0
                                    ? "Defisit terdeteksi! Beban tagihanmu melampaui sisa uang kantong aktif saat ini."
                                    : "Aman, Gas! Uang kantongmu masih sanggup menutup semua kewajiban.",
                                style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        insightTextColor.withValues(alpha: 0.8),
                                    height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. NEW SECTION: ASISTEN REALTIME TREN MINGGUAN (Poin 3 - Pemenuhan Validitas Nama Halaman)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.015),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Evaluasi Performa Mingguan",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  trendColor.withValues(alpha: 0.1),
                              child:
                                  Icon(trendIcon, color: trendColor, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                trendText,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                    height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. PROGRESS KEWAJIBAN CONTEXTUAL
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.015),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Penyelesaian Kewajiban",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$paidBillsCount dari $totalBillsCount Tagihan Lunas",
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87),
                            ),
                            Text(
                              "${(progressPercent * 100).toInt()}%",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: totalBillsCount > 0 ? progressPercent : 1.0,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue.shade600),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                tagihanKonteksText,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. BRUTAL MOBILE COPY: TIPS KEHIDUPAN TENANG (Poin 2 - Sat-Set Anti-Mager Membaca)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color:
                              const Color(0xFFE5E7EB).withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.spa_outlined,
                                size: 18, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              "Tips Kehidupan Tenang",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Diskon gak selalu harus dibeli, Gas. Safe-to-Spend yang aman jauh lebih penting 👍", // FIX: Brutal mobile copy, pendek, ngena!
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
            error: (e, s) => Center(child: Text("Gagal memuat transaksi: $e")),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, s) => Center(child: Text("Gagal memuat tagihan: $e")),
      ),
    );
  }

  Widget _buildAllocationRow(Color indicatorColor, String label, double amount,
      {bool isBold = false}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: indicatorColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ),
        Text(
          "Rp ${NumberFormat('#,###', 'id_ID').format(amount)}",
          style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
              color: isBold ? Colors.black : Colors.black87),
        ),
      ],
    );
  }
}
