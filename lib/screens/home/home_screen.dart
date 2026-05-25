import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/bill_provider.dart';
import 'package:intl/intl.dart';
import '../../models/bill_model.dart';
import '../../widgets/sheets/bill_sheet.dart';
import '../../providers/notification_service.dart';
import '../../widgets/ads/ad_banner_wrapper.dart'; // <--- MODIFIKASI: Impor pembungkus iklan premium lo

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ------------------------------------------------------------------------
    // DATA STREAM & LOCK ENGINE (Aman dari Looping Setan)
    // ------------------------------------------------------------------------
    final billsAsync = ref.watch(billStreamProvider);
    final transactionsAsync = ref.watch(transactionStreamProvider);

    final netBalance = ref.watch(netBalanceProvider);
    final safeToSpend = ref.watch(safeToSpendProvider);

    // KUNCI PENGAMAN LOOP: Picu engine secara aman hanya saat frame UI selesai dimuat
    if (billsAsync.value != null && billsAsync.value!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final activeBills = billsAsync.value!.cast<BillModel>();

        // A. Jalankan engine pengecekan tagihan berulang bawaan lo
        ref
            .read(recurringEngineProvider)
            .checkAndGenerateRecurringBills(activeBills);

        // B. SUNTIKAN SAKTI V2: Daftarkan booking alarm H-1 subuh otomatis (Anti-Gagal v1)
        final notifService = ref.read(notificationServiceProvider);
        for (var bill in activeBills) {
          if (!bill.isPaid) {
            notifService.scheduleBillReminder(bill);
          }
        }
      });
    }

    // LOGIKA EMOTIONAL MICROCOPY (Financial Insight)
    String emotionalInsight = "Kondisi finansialmu terpantau aman 👍";
    IconData insightIcon = Icons.check_circle_outline_rounded;

    if (safeToSpend < 0) {
      emotionalInsight =
          "Beban tagihan melebihi batas aman keduamu, Gas. Rem jajan dulu ya.";
      insightIcon = Icons.error_outline_rounded;
    } else if (safeToSpend < (netBalance * 0.3) && netBalance > 0) {
      emotionalInsight =
          "Pengeluaran mulai padat. Amankan sisa tagihan aktifmu terlebih dahulu.";
      insightIcon = Icons.wb_sunny_rounded;
    } else if (netBalance == 0) {
      emotionalInsight =
          "Dompetmu masih tenang hari ini. Belum ada aktivitas tercatat.";
      insightIcon = Icons.spa_outlined;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // APP BAR PREMIUM
          const SliverAppBar(
            floating: true,
            pinned: false,
            backgroundColor: Color(0xFFF8F9FB),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              "Tagih.In",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E3A8A),
                  letterSpacing: -0.5,
                  fontSize: 24),
            ),
          ),

          // 1. HERO CARD: SAFE TO SPEND INTELLIGENCE
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: .2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "SALDO AMAN UNTUKMU",
                    style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Rp ${NumberFormat('#,###', 'id_ID').format(safeToSpend)}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(insightIcon, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            emotionalInsight,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniInfo("Uang Kantong", netBalance),
                      _buildMiniInfo("Beban Tagihan", netBalance - safeToSpend),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2. SECTION: KEWAJIBAN AKTIF
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 16, top: 20, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Kewajiban Aktif",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  if (billsAsync.value != null && billsAsync.value!.isNotEmpty)
                    Text(
                      "${billsAsync.value!.where((b) => !b.isPaid).length} tersisa",
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                ],
              ),
            ),
          ),

          billsAsync.when(
            data: (bills) {
              final unpaidBills = bills.where((b) => !b.isPaid).toList();
              if (unpaidBills.isEmpty) {
                return SliverToBoxAdapter(
                  child: _buildEmptyState("Belum ada tagihan aktif 🎉",
                      "Semua kewajibanmu bulan ini selesai lunas."),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final bill = unpaidBills[index];

                    final today = DateTime(DateTime.now().year,
                        DateTime.now().month, DateTime.now().day);
                    final billDay = DateTime(bill.dueDate.year,
                        bill.dueDate.month, bill.dueDate.day);
                    final daysLeft = billDay.difference(today).inDays;

                    String urgencyText = "$daysLeft hari lagi";
                    Color urgencyColor = Colors.grey.shade600;
                    Color cardBorderColor = Colors.transparent;

                    if (daysLeft == 0) {
                      urgencyText = "Hari ini";
                      urgencyColor = Colors.orange.shade900;
                      cardBorderColor = Colors.orange.withValues(alpha: 0.2);
                    } else if (daysLeft == 1) {
                      urgencyText = "Besok";
                      urgencyColor = Colors.orange.shade700;
                    } else if (daysLeft < 0) {
                      urgencyText = "Terlambat ${daysLeft.abs()} hari";
                      urgencyColor = Colors.redAccent;
                      cardBorderColor = Colors.red.withValues(alpha: 0.15);
                    }

                    final isRecurring = bill.recurrence != 'none';
                    String recurrenceLabel = "";
                    if (bill.recurrence == 'weekly') {
                      recurrenceLabel = "Mingguan";
                    }
                    if (bill.recurrence == 'monthly') {
                      recurrenceLabel = "Bulanan";
                    }
                    if (bill.recurrence == 'yearly') {
                      recurrenceLabel = "Tahunan";
                    }

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Container(
                            padding: EdgeInsets.only(
                              bottom:
                                  MediaQuery.of(context).viewInsets.bottom + 32,
                              left: 24,
                              right: 24,
                              top: 24,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(28)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width: 36,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  "Konfirmasi Pelunasan",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Pastikan kamu sudah melunasi tagihan ini melalui rekening bank atau dompet digitalmu.",
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade500,
                                      height: 1.4),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FB),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Nama Tagihan",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade600,
                                                  fontWeight: FontWeight.w500)),
                                          Text(bill.title,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87)),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Total Nominal",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade600,
                                                  fontWeight: FontWeight.w500)),
                                          Text(
                                            "Rp ${NumberFormat('#,###', 'id_ID').format(bill.amount)}",
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50
                                        .withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline_rounded,
                                          color: Colors.orange.shade900,
                                          size: 18),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "Safe-to-Spend tetap terjaga lunas sebesar Rp ${NumberFormat('#,###', 'id_ID').format(bill.amount)} dari pos alokasi terikat.",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.orange.shade900,
                                              fontWeight: FontWeight.w500,
                                              height: 1.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 52,
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          14))),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text("Batal",
                                              style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: SizedBox(
                                        height: 52,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.blue.shade700,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14)),
                                          ),
                                          onPressed: () {
                                            HapticFeedback.heavyImpact();
                                            Navigator.pop(context);
                                            ref
                                                .read(firestoreServiceProvider)
                                                .toggleBillStatus(
                                                    bill.id, bill.isPaid);

                                            ref
                                                .read(
                                                    notificationServiceProvider)
                                                .cancelNotification(bill.id);

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    "Kewajiban '${bill.title}' selesai dilunasi! 🎉"),
                                                backgroundColor:
                                                    Colors.green.shade700,
                                              ),
                                            );
                                          },
                                          child: const Text("Konfirmasi Bayar",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      onLongPress: () {
                        HapticFeedback.heavyImpact();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => BillSheet(billToEdit: bill),
                        );
                      },
                      child: Dismissible(
                        key: Key(bill.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 5),
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("Hapus Tagihan ",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              Icon(Icons.delete_sweep_rounded,
                                  color: Colors.white, size: 24),
                            ],
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              title: const Text("Hapus Tagihan?"),
                              content: Text(
                                  "Apakah kamu yakin mau menghapus tagihan '${bill.title}'?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text("Batal",
                                      style: TextStyle(color: Colors.grey)),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text("Hapus",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          try {
                            await ref
                                .read(firestoreServiceProvider)
                                .deleteBill(bill.id);

                            ref
                                .read(notificationServiceProvider)
                                .cancelNotification(bill.id);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Tagihan '${bill.title}' berhasil dihapus.")),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Gagal menghapus: ${e.toString()}"),
                                    backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: cardBorderColor, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2))
                            ],
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.receipt_long_rounded,
                                color: Color(0xFF2563EB), size: 22),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(bill.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black87)),
                                ),
                                if (isRecurring)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Text(
                                      recurrenceLabel,
                                      style: TextStyle(
                                          color: Colors.blue.shade800,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time_filled_rounded,
                                      size: 12,
                                      color:
                                          urgencyColor.withValues(alpha: 0.7)),
                                  const SizedBox(width: 4),
                                  Text(urgencyText,
                                      style: TextStyle(
                                          color: urgencyColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                  Text(
                                      " • ${DateFormat('dd MMM').format(bill.dueDate)}",
                                      style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                            trailing: Text(
                              "Rp ${NumberFormat('#,###', 'id_ID').format(bill.amount)}",
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: unpaidBills.length > 3 ? 3 : unpaidBills.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
                child: Center(
                    child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator.adaptive()))),
            error: (e, s) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // 3. SECTION: HISTORY CASH FLOW
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 16, top: 24, bottom: 8),
              child: Text("Aktivitas Terakhir",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          transactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return SliverToBoxAdapter(
                  child: _buildEmptyState("Belum ada transaksi ☕",
                      "Catat pengeluaran harianmu agar cash flow terpantau."),
                );
              }

              final limitedTx = transactions.take(5).toList();

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tx = limitedTx[index];
                    final isIncome = tx.type == 'income';

                    IconData catIcon = Icons.local_cafe_rounded;
                    Color catColor = Colors.brown;

                    if (tx.category == 'Gaji') {
                      catIcon = Icons.payments_rounded;
                      catColor = Colors.green;
                    } else if (tx.category == 'Transportasi') {
                      catIcon = Icons.directions_car_rounded;
                      catColor = Colors.blue;
                    } else if (tx.category == 'Hiburan') {
                      catIcon = Icons.sports_esports_rounded;
                      catColor = Colors.purple;
                    } else if (tx.category == 'Kost') {
                      catIcon = Icons.home_rounded;
                      catColor = Colors.indigo;
                    } else if (tx.category == 'Belanja') {
                      catIcon = Icons.shopping_bag_rounded;
                      catColor = Colors.pink;
                    } else if (tx.category == 'Umum') {
                      catIcon = Icons.category_rounded;
                      catColor = Colors.blueGrey;
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.01),
                              blurRadius: 8,
                              offset: const Offset(0, 1))
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: catColor.withValues(alpha: 0.1),
                          child: Icon(catIcon, color: catColor, size: 20),
                        ),
                        title: Text(tx.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text(
                          DateFormat('dd MMM • HH:mm', 'id_ID').format(tx.date),
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 11),
                        ),
                        trailing: Text(
                          "${isIncome ? '+' : '-'} Rp ${NumberFormat('#,###', 'id_ID').format(tx.amount)}",
                          style: TextStyle(
                              color: isIncome
                                  ? Colors.green.shade700
                                  : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ),
                    );
                  },
                  childCount: limitedTx.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (e, s) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // MODIFIKASI SAKTI: Menyuntikkan Banner Area Iklan non-intrusif di paling bawah viewport scroll
          const SliverToBoxAdapter(
            child: AdBannerWrapper(), // <--- TANCAP DI SINI SECARA BERKELAS
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),
    );
  }

  Widget _buildMiniInfo(String label, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          "Rp ${NumberFormat('#,###', 'id_ID').format(amount)}",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
