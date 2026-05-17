import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bill_model.dart';
import '../models/transaction_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // ===========================================================================
  // BILLS SYSTEM (Manajemen Tagihan Mandiri)
  // ===========================================================================

  // 1. Stream Daftar Tagihan Realtime (Dipakai di HomeScreen)
  Stream<List<BillModel>> getBills() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('bills')
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BillModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // 2. Tambah Data Tagihan Baru (Dipakai di BillSheet Mode Tambah)
  Future<void> addBill(BillModel bill) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('bills')
        .add(bill.toMap());
  }

  // 3. Update/Ubah Data Tagihan Lama (Dipakai di BillSheet Mode Edit/Tekan Lama)
  Future<void> updateBill(String billId, BillModel bill) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('bills')
        .doc(billId)
        .update(bill.toMap());
  }

  // 4. Ubah Status Centang Lunas / Belum (Dipakai di Checkbox HomeScreen)
  Future<void> toggleBillStatus(String billId, bool currentStatus) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('bills')
        .doc(billId)
        .update({'isPaid': !currentStatus});
  }

  // 5. Hapus Tagihan Permanen (Dipakai di Swipe/Geser Kiri HomeScreen)
  Future<void> deleteBill(String billId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('bills')
        .doc(billId)
        .delete();
  }

  // ===========================================================================
  // CASH FLOW SYSTEM (Manajemen Arus Uang Kantong)
  // ===========================================================================

  // 1. Stream Riwayat Transaksi Realtime (Dipakai di HomeScreen)
  Stream<List<TransactionModel>> getTransactions() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // 2. Catat Transaksi Baru Masuk / Keluar (Dipakai di QuickActionSheet)
  Future<void> addTransaction(TransactionModel tx) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .add(tx.toMap());
  }
}
