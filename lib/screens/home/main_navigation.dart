import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../insights/insights_screen.dart';
import '../calendar/calendar_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/sheets/quick_action_sheet.dart'; // <-- FIX: Jalur impor dibetulkan ke folder widgets utama
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
      extendBody: true,
      body: _pages[_selectedIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showActionSelectionSheet(context),
        shape: const CircleBorder(),
        backgroundColor: Colors.black87,
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.history_rounded, "Riwayat", 0),
              _buildNavItem(Icons.calendar_month_rounded, "Kalender", 1),
              const SizedBox(width: 48),
              _buildNavItem(Icons.bar_chart_rounded, "Insight", 2),
              _buildNavItem(Icons.person_outline_rounded, "Saya", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue.shade700 : Colors.grey,
            size: 26,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue.shade700 : Colors.grey,
            ),
          ),
        ],
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar minimalis
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(
                  bottom: 16), // <-- FIX: Perbaikan kesalahan sintaksis margin
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10)),
            ),
            const Text(
              "Pilih Aksi Cepat",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade50,
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.green),
              ),
              title: const Text("Catat Cash Flow",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              subtitle: const Text("Pemasukan atau pengeluaran harian",
                  style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                _showQuickActionSheet(context);
              },
            ),
            const SizedBox(height: 4),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                child:
                    const Icon(Icons.receipt_long_rounded, color: Colors.blue),
              ),
              title: const Text("Tambah Tagihan Baru",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              subtitle: const Text("Kewajiban bulanan/berulang",
                  style: TextStyle(fontSize: 12)),
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
      builder: (context) =>
          const QuickActionSheet(), // <-- FIX: Sekarang kelas terdeteksi dengan aman
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
