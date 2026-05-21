import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // 1. ANTISIPASI KOSONG: Kalau dihapus sampai habis, langsung balikin teks kosong biar gak crash
    if (newValue.text.isEmpty) {
      return newValue;
    }

    if (newValue.selection.baseOffset == 0) return newValue;

    // 2. BERSIHKAN TITIK: Buang semua titik bawaan format IDR lama sebelum di-parse ke double
    String cleanText = newValue.text.replaceAll('.', '');

    // 3. AMAN PARSING: Gunakan tryParse agar kalau ada karakter aneh, aplikasi gak mental crash
    double value = double.tryParse(cleanText) ?? 0;

    // Tetap mempertahankan decimalPattern 'id' kebanggaan lo rill
    final formatter = NumberFormat.decimalPattern('id');
    String newText = formatter.format(value);

    return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length));
  }
}
