import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Impor core Firebase Auth untuk bypass logout
import '../../providers/auth_provider.dart';
import '../../providers/insight_provider.dart';

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
        slivers: [
          // APP BAR TITLE
          const SliverAppBar(
            floating: true,
            backgroundColor: Color(0xFFF8F9FB),
            elevation: 0,
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
              margin: const EdgeInsets.all(16),
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
                  _buildMenuTile(Icons.security_rounded, "Keamanan & Sandi"),
                  const Divider(height: 1, indent: 56),
                  _buildMenuTile(
                      Icons.privacy_tip_rounded, "Kebijakan Privasi"),
                  const Divider(height: 1, indent: 56),

                  // TOMBOL LOGOUT FIX (Aman dari Mismatch Nama Method)
                  ListTile(
                    leading: const Icon(Icons.logout_rounded,
                        color: Colors.redAccent),
                    title: const Text(
                      "Keluar dari Akun",
                      style: TextStyle(
                          color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      // Menampilkan Dialog Konfirmasi sebelum melempar Sesi Login
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
                                  Navigator.pop(
                                      dialogContext); // Tutup dialog konfirmasi

                                  try {
                                    // BYPASS SAKTI: Putus token login langsung dari core Firebase Instance
                                    await FirebaseAuth.instance.signOut();

                                    if (context.mounted) {
                                      // Tendang balik ke rute login dan hapus tumpukan riwayat halaman sebelumnya
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
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: () {},
    );
  }
}
