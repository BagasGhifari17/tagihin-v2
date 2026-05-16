import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/bill_provider.dart';
import '../../models/bill_model.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay =
        DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
  }

  @override
  Widget build(BuildContext context) {
    final billsAsync = ref.watch(billStreamProvider);
    final List<BillModel> allBills = billsAsync.value ?? [];

    final daysInMonth =
        DateUtils.getDaysInMonth(_focusedDay.year, _focusedDay.month);
    final firstDayOffset =
        DateTime(_focusedDay.year, _focusedDay.month, 1).weekday - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: CustomScrollView(
        slivers: [
          // APP BAR TITLE
          const SliverAppBar(
            floating: true,
            backgroundColor: Color(0xFFF8F9FB),
            elevation: 0,
            title: Text(
              "Jadwal Tagihan",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 22),
            ),
          ),

          // 1. MONTH PICKER HEADER
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM yyyy', 'id_ID').format(_focusedDay),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => setState(() {
                          _focusedDay =
                              DateTime(_focusedDay.year, _focusedDay.month - 1);
                        }),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => setState(() {
                          _focusedDay =
                              DateTime(_focusedDay.year, _focusedDay.month + 1);
                        }),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          // 2. WEEKDAY LABELS (Sen, Sel, Rab...) - FIX TEXT ALIGN
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                    .map((day) {
                  return SizedBox(
                    width: 40,
                    child: Text(
                      day,
                      textAlign: TextAlign
                          .center, // <-- FIX: Tipe TextAlign yang benar
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 3. CALENDAR GRID
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
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
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: daysInMonth + firstDayOffset,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  if (index < firstDayOffset) return const SizedBox.shrink();

                  final dayNumber = index - firstDayOffset + 1;
                  final currentDay =
                      DateTime(_focusedDay.year, _focusedDay.month, dayNumber);
                  final isSelected = _selectedDay == currentDay;

                  final dayBills = allBills
                      .where((b) =>
                          b.dueDate.year == currentDay.year &&
                          b.dueDate.month == currentDay.month &&
                          b.dueDate.day == currentDay.day)
                      .toList();

                  final hasUnpaid = dayBills.any((b) => !b.isPaid);

                  return InkWell(
                    onTap: () => setState(() => _selectedDay = currentDay),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.shade700
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$dayNumber",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : currentDay.day == DateTime.now().day &&
                                          currentDay.month ==
                                              DateTime.now().month &&
                                          currentDay.year == DateTime.now().year
                                      ? Colors.blue.shade700
                                      : Colors
                                          .black87, // <-- FIX: Menggunakan kelas warna bawaan SDK yang valid
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (dayBills.isNotEmpty)
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : hasUnpaid
                                        ? Colors.redAccent
                                        : Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 4. SELECTED DAY BILLS LIST
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Text("Agenda Pada Hari Ini",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          _buildSelectedDayBills(allBills),
        ],
      ),
    );
  }

  Widget _buildSelectedDayBills(List<BillModel> allBills) {
    if (_selectedDay == null) {
      return const SliverFillRemaining(
          child: Center(child: Text("Pilih tanggal untuk melihat detail.")));
    }

    final activeBills = allBills
        .where((b) =>
            b.dueDate.year == _selectedDay!.year &&
            b.dueDate.month == _selectedDay!.month &&
            b.dueDate.day == _selectedDay!.day)
        .toList();

    if (activeBills.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              "Tenang, tidak ada tagihan jatuh tempo hari ini. ✨",
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final bill = activeBills[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: Icon(
                bill.isPaid
                    ? Icons.check_circle_outline_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: bill.isPaid ? Colors.green : Colors.redAccent,
              ),
              title: Text(bill.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text(
                "Rp ${NumberFormat('#,###', 'id_ID').format(bill.amount)}",
                style: TextStyle(
                    color: bill.isPaid ? Colors.green : Colors.redAccent,
                    fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
        childCount: activeBills.length,
      ),
    );
  }
}
