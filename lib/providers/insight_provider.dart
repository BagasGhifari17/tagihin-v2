import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bill_provider.dart';

// Model sederhana untuk menampung data analitik yang tenang
class InsightData {
  final double completionRate; // Persentase tagihan lunas (0.0 - 100.0)
  final int totalBills;
  final int paidBills;
  final String financialHealthStatus; // Kondisi Keuangan
  final String emotionalInsight; // Pesan Supportive

  InsightData({
    required this.completionRate,
    required this.totalBills,
    required this.paidBills,
    required this.financialHealthStatus,
    required this.emotionalInsight,
  });
}

final insightProvider = Provider<InsightData>((ref) {
  final bills = ref.watch(billStreamProvider).value ?? [];
  final safeToSpend = ref.watch(safeToSpendProvider);
  final netBalance = ref.watch(netBalanceProvider);

  // 1. Hitung Bill Completion Rate
  final totalBills = bills.length;
  final paidBills = bills.where((b) => b.isPaid).length;
  final completionRate =
      totalBills == 0 ? 100.0 : (paidBills / totalBills) * 100;

  // 2. Tentukan Kondisi Finansial & Emotional Insight (Sesuai SOP PRD)
  String healthStatus = "Kondisi Keuangan Aman";
  String emotionalMessage =
      "Aman, Gas! Uang kantongmu masih sanggup menutup semua kewajiban.";

  if (netBalance == 0 && totalBills == 0) {
    healthStatus = "Memulai Langkah Baru";
    emotionalMessage =
        "Belum ada catatan transaksi nih. Yuk, catat cash flow atau tagihan pertamamu!";
  } else if (safeToSpend < 0) {
    healthStatus = "Pengeluaran Melebihi Batas Aman";
    emotionalMessage =
        "Waduh Gas, beban tagihanmu sudah menjebol uang kantong. Rem jajan dulu ya!";
  } else if (safeToSpend < (netBalance * 0.3)) {
    // Sisa uang aman di bawah 30% dari total uang kantong
    healthStatus = "Pengeluaran Mulai Padat";
    emotionalMessage =
        "Uang aman untuk jajan sisa sedikit, Gas. Prioritaskan amankan sisa tagihan aktifmu.";
  } else if (completionRate == 100 && totalBills > 0) {
    healthStatus = "Kombinasi Finansial Sempurna";
    emotionalMessage =
        "Luar biasa! Semua kewajiban bulan ini beres lunas. Hidup tenang, pikiran lapang.";
  }

  return InsightData(
    completionRate: completionRate,
    totalBills: totalBills,
    paidBills: paidBills,
    financialHealthStatus: healthStatus,
    emotionalInsight: emotionalMessage,
  );
});
