import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transaction_provider.dart';
// Mengimpor utilitas formatter core asli bawaan proyek lo
import '../../core/utils/currency_formatter.dart';

class CashFlowSheet extends ConsumerStatefulWidget {
  const CashFlowSheet({super.key});

  @override
  ConsumerState<CashFlowSheet> createState() => _CashFlowSheetState();
}

class _CashFlowSheetState extends ConsumerState<CashFlowSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedType = 'expense';
  String _selectedCategory = 'Makanan';
  final DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    'Makanan',
    'Transportasi',
    'Hiburan',
    'Gaji',
    'E-Wallet',
    'Umum'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(transactionFormNotifierProvider);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Catat Cash Flow",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text("Pengeluaran")),
                      selected: _selectedType == 'expense',
                      selectedColor: Colors.orange.shade100,
                      labelStyle: TextStyle(
                          color: _selectedType == 'expense'
                              ? Colors.orange.shade900
                              : Colors.black),
                      onSelected: (val) =>
                          setState(() => _selectedType = 'expense'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text("Pemasukan")),
                      selected: _selectedType == 'income',
                      selectedColor: Colors.green.shade100,
                      labelStyle: TextStyle(
                          color: _selectedType == 'income'
                              ? Colors.green.shade900
                              : Colors.black),
                      onSelected: (val) =>
                          setState(() => _selectedType = 'income'),
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
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(), // <--- Memanggil core utility bawaan proyek lo
                ],
                // SUNTIKAN KUNCI KESUKSESAN MUTLAK: Meniru gaya bill_sheet.dart untuk memaksa offset me-refresh
                onChanged: (val) {
                  setState(() {});
                },
                validator: (val) {
                  if (val == null || val.isEmpty) return "Masukkan nominal";
                  String cleanText = val.replaceAll('.', '');
                  if ((double.tryParse(cleanText) ?? 0) == 0) {
                    return "Masukkan nominal";
                  }
                  return null;
                },
              ),
              Divider(color: Colors.grey.shade200, height: 1),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: "Keterangan transaksi",
                  hintText: "Misal: Jajan Kopi, Gaji Bulanan",
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
                validator: (val) =>
                    val!.isEmpty ? "Keterangan tidak boleh kosong, Gas!" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: "Pilih Kategori",
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
                items: _categories
                    .map((cat) =>
                        DropdownMenuItem<String>(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategory = val);
                  }
                },
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
                  onPressed: formState.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            // Bersihkan karakter titik sebelum di-parse ke double untuk disinkronkan ke database Firestore
                            final cleanAmount = double.parse(
                                _amountController.text.replaceAll('.', ''));

                            final navigator = Navigator.of(context);
                            final scaffoldMessenger =
                                ScaffoldMessenger.of(context);

                            navigator.pop();

                            final success = await ref
                                .read(transactionFormNotifierProvider.notifier)
                                .submitTransaction(
                                  title: _titleController.text.trim(),
                                  amount: cleanAmount,
                                  type: _selectedType,
                                  category: _selectedCategory,
                                  date: _selectedDate,
                                );

                            if (success) {
                              ref
                                  .read(
                                      transactionFormNotifierProvider.notifier)
                                  .resetForm();
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text("Cash Flow berhasil dicatat!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        },
                  child: formState.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text("Simpan Transaksi",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
