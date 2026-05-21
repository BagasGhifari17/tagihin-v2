import 'dart:ui'; // Core UI untuk mengaktifkan efek blur BackdropFilter ala iOS
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart'; // FIX: Jalur impor dibetulkan karena satu folder di dalam 'home'
import '../insights/insights_screen.dart';
import '../calendar/calendar_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/sheets/quick_action_sheet.dart';
import '../../widgets/sheets/bill_sheet.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const CalendarScreen(),
    const InsightsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody:
          true, // Membuat halaman konten meluncur mulus ke belakang bar melayang
      body: _pages[_selectedIndex],

      // ===========================================================================
      // ULTIMATE UPGRADE: FLOATING iOS PILL DOCK WITH BACKDROP BLUR (Anti-Bocor Visual)
      // ===========================================================================
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).padding.bottom > 0
              ? 24
              : 16, // Adaptive spacing untuk iOS Home Bar
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: 15,
                sigmaY: 15), // Membuat konten di belakang blur halus ala iOS
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                    alpha: 0.85), // Putih transparan tipis frosted glass
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(
                      alpha:
                          0.4), // Border tipis berkilau mewah khas Apple Wallet
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                        alpha: 0.02), // Shadow ultra-soft khas Apple
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDockItem(Icons.history_toggle_off_rounded,
                      Icons.history_rounded, "Riwayat", 0),
                  _buildDockItem(Icons.calendar_month_outlined,
                      Icons.calendar_month_rounded, "Kalender", 1),

                  // CORE FAB INTEGRATED
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _showActionSelectionSheet(context);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),

                  _buildDockItem(Icons.bar_chart_outlined,
                      Icons.bar_chart_rounded, "Insight", 2),
                  _buildDockItem(Icons.person_outline_rounded,
                      Icons.person_rounded, "Saya", 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // NAV ITEM ENGINE: KAPSUL CAPSULE WITH TIGHT VISUAL WEIGHT
  // ===========================================================================
  Widget _buildDockItem(
      IconData normalIcon, IconData activeIcon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _selectedIndex = index);
        },
        child: Container(
          color: Colors.transparent, // Memperluas area hit-box sentuhan jari
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2563EB).withValues(alpha: 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSelected ? activeIcon : normalIcon,
                  color: isSelected
                      ? const Color(0xFF1E3A8A)
                      : const Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFF1E3A8A)
                      : const Color(0xFF94A3B8),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActionSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding:
            const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10)),
            ),
            const Text(
              "Pilih Aksi Cepat",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  letterSpacing: -0.3,
                  color: Colors.black87),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE6F4EA),
                child: Icon(Icons.account_balance_wallet_rounded,
                    color: Color(0xFF137333), size: 20),
              ),
              title: const Text("Catat Cash Flow",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87)),
              subtitle: const Text("Pemasukan atau pengeluaran harian",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _showQuickActionSheet(context);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F0FE),
                child: Icon(Icons.receipt_long_rounded,
                    color: Color(0xFF1A73E8), size: 20),
              ),
              title: const Text("Tambah Tagihan Baru",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87)),
              subtitle: const Text("Kewajiban bulanan/berulang",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _showAddBillBottomSheet(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickActionSheet(),
    );
  }

  void _showAddBillBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BillSheet(),
    );
  }
}
