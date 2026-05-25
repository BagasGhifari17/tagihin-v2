import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Impor core Firebase Auth untuk bypass logout & reset sandi
import '../../providers/auth_provider.dart';
import '../../providers/insight_provider.dart';
// Menggunakan import relatif agar kebal dari eror package pathing uri_does_not_exist
import '../../widgets/cards/premium_profile_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final insight = ref.watch(insightProvider);

    // Ambil data user dari Firebase Auth State
    final user = authState.value;
    final email = user?.email ?? "pengguna@tagihin.com";
    final initial = email.isNotEmpty ? email[0].toUpperCase() : "U";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: CustomScrollView(
        // FIX SCROLL MANTUL: Menggunakan ClampingScrollPhysics dikombinasikan dengan AlwaysScrollable
        // Ini taktik mutlak biar Android/iOS gak mantul brutal ke atas pas kontennya ditarik ke bawah.
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        slivers: [
          // APP BAR TITLE
          const SliverAppBar(
            floating: true,
            backgroundColor: Color(0xFFF8F9FB),
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              "Profil Saya",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 22),
            ),
          ),

          // 1. HERO USER IDENTITAS CARD
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.blue.shade50,
                    child: Text(
                      initial,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Halo, Sobat Tagih.In",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. FINTECH PERFORMANCE TRACKER (Statistik Kedisiplinan)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Text("Performa Keuangan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
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
                      const Text("Skor Kedisiplinan",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      Text(
                        "${insight.completionRate.toInt()}% Tepat Waktu",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: insight.completionRate == 100
                                ? Colors.green
                                : Colors.blue.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: insight.completionRate / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        insight.completionRate == 100
                            ? Colors.green
                            : Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Kamu telah menyelesaikan ${insight.paidBills} dari ${insight.totalBills} total kewajiban tagihan aktif bulan ini.",
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600, height: 1.4),
                  ),
                ],
              ),
            ),
          ),

          // FITUR EKSKLUSIF BANNER SECTION
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Text("Fitur Eksklusif",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          const SliverToBoxAdapter(
            child: PremiumProfileCard(),
          ),

          // 3. MENU PENGATURAN & LOGOUT ELEGAN
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Text("Pengaturan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin:
                  const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  // KEAMANAN SHEET INTERAKTIF
                  _buildMenuTile(
                    context,
                    Icons.security_rounded,
                    "Keamanan & Sandi",
                    onTap: () {
                      HapticFeedback.lightImpact();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(24)),
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
                                        borderRadius:
                                            BorderRadius.circular(10))),
                              ),
                              const SizedBox(height: 24),
                              const Text("Keamanan Akun",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.4)),
                              const SizedBox(height: 6),
                              Text(
                                  "Akun kamu dilindungi oleh Google Firebase Authentication System.",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FB),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: const Color(0xFFE5E7EB))),
                                child: Row(
                                  children: [
                                    Icon(Icons.verified_user_rounded,
                                        color: Colors.green.shade600, size: 20),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Metode Autentikasi",
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(height: 2),
                                          Text("Secure Email & Password Sync",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.mail_outline_rounded,
                                      size: 18),
                                  label: const Text("Kirim Email Reset Sandi",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                  onPressed: () async {
                                    HapticFeedback.mediumImpact();
                                    Navigator.pop(context);

                                    try {
                                      await FirebaseAuth.instance
                                          .sendPasswordResetEmail(email: email);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "Link pengaturan ulang sandi berhasil dikirim ke $email! ✉️"),
                                            backgroundColor:
                                                Colors.green.shade700,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "Gagal mengirim email: ${e.toString()}"),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),

                  // PRIVASI TERMS SHEET RINGKASAN
                  _buildMenuTile(
                    context,
                    Icons.privacy_tip_rounded,
                    "Kebijakan Privasi",
                    onTap: () {
                      HapticFeedback.lightImpact();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(24)),
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
                                        borderRadius:
                                            BorderRadius.circular(10))),
                              ),
                              const SizedBox(height: 24),
                              const Text("Kebijakan Privasi",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.4)),
                              const SizedBox(height: 4),
                              Text(
                                  "Bagaimana Tagih.In menjaga amunisi datamu tetap steril:",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 20),
                              _buildPrivacyPoint(
                                  Icons.cloud_done_rounded,
                                  "Cloud Synchronization",
                                  "Seluruh riwayat cash flow dan siklus tagihan dienkripsi secara aman saat disinkronkan ke server Google Cloud."),
                              _buildPrivacyPoint(
                                  Icons.phonelink_lock_rounded,
                                  "Offline Encryption",
                                  "Saat kondisi offline, data cash flow kamu dikunci rapat secara lokal di dalam memori penyimpanan internal device."),
                              _buildPrivacyPoint(
                                  Icons.front_hand_rounded,
                                  "Zero Data Selling",
                                  "Tagih.In berkomitmen penuh 100% untuk tidak membagikan, menyewakan, atau menjual data jajan harianmu ke pihak ketiga mana pun."),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12))),
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Saya Mengerti",
                                      style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),

                  // TOMBOL LOGOUT
                  ListTile(
                    leading: const Icon(Icons.logout_rounded,
                        color: Colors.redAccent),
                    title: const Text(
                      "Keluar dari Akun",
                      style: TextStyle(
                          color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text(
                              'Keluar Akun',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: const Text(
                                'Apakah Anda yakin ingin keluar dari aplikasi Tagih.In?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(dialogContext);

                                  try {
                                    await FirebaseAuth.instance.signOut();
                                    if (context.mounted) {
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                              '/login', (route) => false);
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Gagal keluar akun: ${e.toString()}'),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: const Text(
                                  'Keluar',
                                  style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // FIX UTAMA: Memberikan tambahan ruang kosong setinggi 110 pixel di bawah list pengaturan
          // Ini trik sakti biar container menu terbawah tidak nyangkut / membal naik ke atas saat di-scroll
          const SliverToBoxAdapter(
            child: SizedBox(height: 110),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String title,
      {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildPrivacyPoint(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 18),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 2),
                Text(description,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.4,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
