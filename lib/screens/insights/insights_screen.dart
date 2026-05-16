import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/insight_provider.dart';
import '../../providers/bill_provider.dart';
import 'package:intl/intl.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insight = ref.watch(insightProvider);
    final netBalance = ref.watch(netBalanceProvider);
    final safeToSpend = ref.watch(safeToSpendProvider);

    // Hitung total pengeluaran & pemasukan kotor dari tagihan + transaksi
    final totalBebanTagihan = netBalance - safeToSpend;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CARD EMOTIONAL HEALTH (The Priority)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        insight.completionRate == 100
                            ? Icons.check_circle_rounded
                            : safeToSpend < 0
                                ? Icons.error_rounded
                                : Icons.wb_sunny_rounded,
                        color:
                            safeToSpend < 0 ? Colors.redAccent : Colors.orange,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        insight.financialHealthStatus,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    insight.emotionalInsight,
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade700, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. COMPLETION RATE CARD (Linear Minimal Progress)
            const Text(
              "Penyelesaian Kewajiban",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${insight.paidBills} dari ${insight.totalBills} Tagihan Lunas",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "${insight.completionRate.toInt()}%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: insight.completionRate == 100
                              ? Colors.green
                              : Colors.blue.shade700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: insight.completionRate / 100,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        insight.completionRate == 100
                            ? Colors.green
                            : Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. MINIMALIST BUDGET DISTRIBUTION
            const Text(
              "Struktur Alokasi Dana",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildAllocationRow(
                      "Total Kantong (Arus Masuk)", netBalance, Colors.green),
                  const Divider(height: 24),
                  _buildAllocationRow("Terikat Tagihan (Beban)",
                      totalBebanTagihan, Colors.redAccent),
                  const Divider(height: 24),
                  _buildAllocationRow("Sisa Bersih (Safe-to-Spend)",
                      safeToSpend, Colors.blue.shade700),
                ],
              ),
            ),
            const SizedBox(height: 100), // Space bottom bar safety
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Text(label,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
        Text(
          "Rp ${NumberFormat('#,###', 'id_ID').format(amount)}",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
