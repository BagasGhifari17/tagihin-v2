import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/bill_provider.dart';
import '../../models/transaction_model.dart';
import 'package:intl/intl.dart';

class QuickActionSheet extends ConsumerStatefulWidget {
  const QuickActionSheet({super.key});

  @override
  ConsumerState<QuickActionSheet> createState() => _QuickActionSheetState();
}

class _QuickActionSheetState extends ConsumerState<QuickActionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedType = 'expense';
  String _selectedCategory = 'Makanan';
  double _inputAmount = 0;

  // KATEGORI KHUSUS PENGELUARAN (Expense) - Lebih padat pos jajan harian anak muda
  final Map<String, Map<String, dynamic>> _expenseCategories = {
    'Makanan': {'icon': Icons.local_cafe_rounded, 'color': Colors.brown},
    'Transportasi': {
      'icon': Icons.directions_car_rounded,
      'color': Colors.blue
    },
    'Hiburan': {'icon': Icons.sports_esports_rounded, 'color': Colors.purple},
    'Kost': {'icon': Icons.home_rounded, 'color': Colors.indigo},
    'Belanja': {'icon': Icons.shopping_bag_rounded, 'color': Colors.pink},
    'Umum': {'icon': Icons.category_rounded, 'color': Colors.blueGrey},
  };

  // KATEGORI KHUSUS PEMASUKAN (Income) - Fokus ke penambahan arus masuk
  final Map<String, Map<String, dynamic>> _incomeCategories = {
    'Gaji': {'icon': Icons.payments_rounded, 'color': Colors.green},
    'Sampingan': {'icon': Icons.work_rounded, 'color': Colors.teal},
    'Transferan': {'icon': Icons.card_giftcard_rounded, 'color': Colors.green},
    'Investasi': {
      'icon': Icons.trending_up_rounded,
      'color': Colors.cyan.shade700
    },
  };

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeToSpend = ref.watch(safeToSpendProvider);

    double projectedSafeToSpend = safeToSpend;
    if (_selectedType == 'income') {
      projectedSafeToSpend += _inputAmount;
    } else {
      projectedSafeToSpend -= _inputAmount;
    }

    // FILTER REALTIME: Ambil data map kategori yang sesuai dengan pilihan type tab saat ini
    final currentCategories =
        _selectedType == 'expense' ? _expenseCategories : _incomeCategories;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      label: "Pengeluaran",
                      type: 'expense',
                      activeColor: Colors.orange.shade800,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeButton(
                      label: "Pemasukan",
                      type: 'income',
                      activeColor: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                "NOMINAL TRANSAKSI",
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
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: "Keterangan transaksi",
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
                    ? "Keterangan tidak boleh kosong"
                    : null,
              ),
              const SizedBox(height: 20),
              const Text(
                "PILIH KATEGORI",
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.5),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: currentCategories.keys.map((catName) {
                    final catData = currentCategories[catName]!;
                    final isSelected = _selectedCategory == catName;
                    final Color catColor = catData['color'];

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Row(
                          children: [
                            Icon(catData['icon'],
                                size: 16,
                                color: isSelected ? Colors.white : catColor),
                            const SizedBox(width: 6),
                            Text(catName),
                          ],
                        ),
                        selected: isSelected,
                        selectedColor: catColor,
                        labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13),
                        backgroundColor: Colors.grey.shade50,
                        side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey.shade200),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        onSelected: (accepted) {
                          if (accepted) {
                            setState(() {
                              _selectedCategory = catName;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: projectedSafeToSpend >= 0
                      ? Colors.blue.shade50.withValues(alpha: 0.5)
                      : Colors.red.shade50.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
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
                        "Setelah ini, uang aman jajanmu tersisa Rp ${NumberFormat('#,###', 'id_ID').format(projectedSafeToSpend)}",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: projectedSafeToSpend >= 0
                                ? Colors.blue.shade900
                                : Colors.red.shade900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
                  onPressed: _submitData,
                  child: const Text("Simpan Transaksi",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(
      {required String label,
      required String type,
      required Color activeColor}) {
    final isSelected = _selectedType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
          // PENGAMAN UX: Begitu ganti jenis tipe, set default kategori agar terhindar dari state tidak valid
          if (type == 'income') _selectedCategory = 'Gaji';
          if (type == 'expense') _selectedCategory = 'Makanan';
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isSelected ? activeColor : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : Colors.grey.shade600),
          ),
        ),
      ),
    );
  }

  void _submitData() {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.lightImpact();

    final newTx = TransactionModel(
      id: '',
      title: _titleController.text.trim(),
      amount: _inputAmount,
      type: _selectedType,
      category: _selectedCategory,
      date: DateTime.now(),
    );

    ref.read(firestoreServiceProvider).addTransaction(newTx);

    Navigator.pop(context);
  }
}
