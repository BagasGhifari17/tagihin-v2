import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/bill_model.dart';
import '../../providers/bill_provider.dart';
import 'package:intl/intl.dart';

class BillSheet extends ConsumerStatefulWidget {
  const BillSheet({super.key});

  @override
  ConsumerState<BillSheet> createState() => _BillSheetState();
}

class _BillSheetState extends ConsumerState<BillSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // State baru penampung periodik (Jaminan Aman dari Kode Merah)
  String _selectedRecurrence = 'none'; // 'none', 'weekly', 'monthly', 'yearly'
  double _inputAmount = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data balance realtime terpusat untuk kalkulator Live Preview Impact
    final netBalance = ref.watch(netBalanceProvider);
    final safeToSpend = ref.watch(safeToSpendProvider);

    // Hitung dampak penambahan tagihan terhadap Safe-to-Spend
    final projectedBebanTagihan = (netBalance - safeToSpend) + _inputAmount;
    final projectedSafeToSpend = safeToSpend - _inputAmount;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar atas minimalis ala iOS
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Tambah Tagihan Baru",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 24),

              // 1. NOMINAL INPUT (Fokus Utama - Nominal-First UX)
              const Text(
                "NOMINAL TAGIHAN",
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.5),
              ),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: "0",
                  prefixText: "Rp ",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey.shade300),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (val) {
                  setState(() {
                    _inputAmount = double.tryParse(val) ?? 0;
                  });
                },
                validator: (val) =>
                    (val == null || val.isEmpty || double.tryParse(val) == 0)
                        ? "Masukkan nominal"
                        : null,
              ),
              Divider(color: Colors.grey.shade200, height: 1),
              const SizedBox(height: 20),

              // 2. INPUT NAMA TAGIHAN
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: "Nama Tagihan",
                  hintText: "Misal: Listrik, Kost, Netflix",
                  labelStyle:
                      TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  floatingLabelStyle: const TextStyle(color: Colors.blue),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 1.5)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (val) => (val == null || val.isEmpty)
                    ? "Nama tagihan wajib diisi, Gas!"
                    : null,
              ),
              const SizedBox(height: 12),

              // 3. DATE PICKER JATUH TEMPO PREMIUM
              Theme(
                data: Theme.of(context).copyWith(
                  listTileTheme: const ListTileThemeData(horizontalTitleGap: 8),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: const Icon(Icons.calendar_today_rounded,
                        color: Colors.blue, size: 18),
                  ),
                  title: const Text("Tanggal Jatuh Tempo",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: Text(
                    DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: Colors.grey),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 4. CHOICECHIPS PERIODIK (Sistem Tagihan Berulang)
              const Text(
                "SISTEM TAGIHAN BERULANG",
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.5),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildRecurrenceChip("Sekali", 'none'),
                    _buildRecurrenceChip("Mingguan", 'weekly'),
                    _buildRecurrenceChip("Bulanan", 'monthly'),
                    _buildRecurrenceChip("Tahunan", 'yearly'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. LIVE IMPACT CARD (Financial Awareness)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: projectedSafeToSpend >= 0
                      ? Colors.blue.shade50.withValues(alpha: 0.5)
                      : Colors.red.shade50.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          projectedSafeToSpend >= 0
                              ? Icons.gpp_good_rounded
                              : Icons.warning_amber_rounded,
                          color: projectedSafeToSpend >= 0
                              ? Colors.blue.shade800
                              : Colors.redAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Proyeksi Finansial Setelah Ditambahkan:",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: projectedSafeToSpend >= 0
                                    ? Colors.blue.shade900
                                    : Colors.red.shade900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildImpactRow(
                        "Beban Tagihan Baru", projectedBebanTagihan),
                    const SizedBox(height: 4),
                    _buildImpactRow("Sisa Safe-to-Spend", projectedSafeToSpend),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 6. TOMBOL SIMPAN (Instant Dismiss & Fire-and-Forget)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final navigator = Navigator.of(context);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);

                      // Amblas instan tanpa nunggu network async gap
                      navigator.pop();

                      // Susun model dengan field recurrence yang aman terintegrasi
                      final newBill = BillModel(
                        id: '',
                        title: _titleController.text.trim(),
                        amount: _inputAmount,
                        dueDate: _selectedDate,
                        isPaid: false,
                        recurrence: _selectedRecurrence,
                      );

                      ref.read(firestoreServiceProvider).addBill(newBill);

                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text("Tagihan baru berhasil disimpan!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text("Simpan Tagihan",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecurrenceChip(String label, String value) {
    final isSelected = _selectedRecurrence == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.blue.shade700,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
        backgroundColor: Colors.grey.shade50,
        side: BorderSide(
            color: isSelected ? Colors.transparent : Colors.grey.shade200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onSelected: (accepted) {
          if (accepted) {
            setState(() => _selectedRecurrence = value);
          }
        },
      ),
    );
  }

  Widget _buildImpactRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        Text(
          "Rp ${NumberFormat('#,###', 'id_ID').format(amount)}",
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }
}
