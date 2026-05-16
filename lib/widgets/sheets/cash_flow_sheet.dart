import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';

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

  void _formatCurrency(String value) {
    if (value.isEmpty) return;
    final text = value.replaceAll('.', '');
    final amount = int.tryParse(text);
    if (amount == null) return;

    final formatted =
        NumberFormat('#,###', 'id_ID').format(amount).replaceAll(',', '.');

    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

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
              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                onChanged: _formatCurrency,
                decoration: const InputDecoration(
                  labelText: "Nominal",
                  prefixText: "Rp ",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                ),
                validator: (val) => val!.isEmpty ? "Masukkan nominal" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: "Keterangan (cth: Jajan Kopi, Gaji Bulanan)",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                ),
                validator: (val) =>
                    val!.isEmpty ? "Keterangan tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),

              // PERBAIKAN: Menggunakan properti modern DropdownButtonFormField agar warning lenyap
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Kategori",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16))),
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
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: formState.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final cleanAmount = double.parse(
                                _amountController.text.replaceAll('.', ''));

                            final navigator = Navigator.of(context);
                            final scaffoldMessenger =
                                ScaffoldMessenger.of(context);

                            // AGRESIP & RESPONSIP: Langsung tutup sheet tanpa menunggu async gap gantung
                            navigator.pop();

                            final success = await ref
                                .read(transactionFormNotifierProvider.notifier)
                                .submitTransaction(
                                  title: _titleController.text,
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
                              fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
