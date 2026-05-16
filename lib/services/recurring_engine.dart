import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bill_model.dart';
import 'firestore_service.dart';

class RecurringEngine {
  final FirestoreService _firestoreService;

  // LAPIS PENGAMAN 1: Gembok boolean untuk mencegah tumpang tindih fungsi async
  bool _isProcessing = false;

  // LAPIS PENGAMAN 2: Mencatat ID dokumen yang sudah/sedang diproses agar tidak dieksekusi ganda
  final Set<String> _processedBillIds = {};

  RecurringEngine(this._firestoreService);

  Future<void> checkAndGenerateRecurringBills(
      List<BillModel> activeBills) async {
    // Jika engine sedang sibuk menulis ke Firebase, langsung batalkan masuk
    if (_isProcessing) return;

    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // FIX BARIS 28 & 30: Membungkus semua struktur statement 'if' dengan blok kurung kurawal {} sesuai linter rule
    final billsToProcess = activeBills.where((bill) {
      if (bill.recurrence == 'none') {
        return false;
      }
      if (bill.id.isEmpty) {
        return false;
      }
      if (_processedBillIds.contains(bill.id)) {
        return false;
      }

      final billDueDate =
          DateTime(bill.dueDate.year, bill.dueDate.month, bill.dueDate.day);
      return billDueDate.isBefore(today) || billDueDate.isAtSameMomentAs(today);
    }).toList();

    if (billsToProcess.isEmpty) return;

    try {
      // Kunci palang pintu engine
      _isProcessing = true;

      for (var bill in billsToProcess) {
        // Daftarkan ID dokumen ke dalam blacklist pelacak sebelum melakukan mutasi data
        _processedBillIds.add(bill.id);

        await _generateNextPeriodBill(bill);
      }
    } finally {
      // Buka gembok kembali setelah seluruh antrean selesai dikerjakan
      _isProcessing = false;

      // Bersihkan tracker lokal agar dokumen bisa diproses kembali di siklus hari esok
      _processedBillIds.clear();
    }
  }

  Future<void> _generateNextPeriodBill(BillModel oldBill) async {
    DateTime nextDueDate;

    switch (oldBill.recurrence) {
      case 'weekly':
        nextDueDate = oldBill.dueDate.add(const Duration(days: 7));
        break;
      case 'monthly':
        nextDueDate = DateTime(oldBill.dueDate.year, oldBill.dueDate.month + 1,
            oldBill.dueDate.day);
        break;
      case 'yearly':
        nextDueDate = DateTime(oldBill.dueDate.year + 1, oldBill.dueDate.month,
            oldBill.dueDate.day);
        break;
      default:
        return;
    }

    final newBill = BillModel(
      id: '',
      title: oldBill.title,
      amount: oldBill.amount,
      dueDate: nextDueDate,
      isPaid: false,
      recurrence: oldBill.recurrence,
    );

    // 1. Matikan status perulangan dokumen lama di Firestore TERLEBIH DAHULU agar siklus putus di server
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_firestoreService.uid)
        .collection('bills')
        .doc(oldBill.id)
        .update({'recurrence': 'none'});

    // 2. Setelah status di masa lalu mati, baru lahirkan dokumen baru untuk masa depan
    await _firestoreService.addBill(newBill);
  }
}
