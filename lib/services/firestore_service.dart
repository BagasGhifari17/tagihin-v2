import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bill_model.dart';
import '../models/transaction_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // ================= BILLS SYSTEM (Step 5) =================
  Stream<List<BillModel>> getBills() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('bills')
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BillModel.fromMap(
                doc.id, doc.data())) // <-- SEKARANG BERJODOH SEMPURNA
            .toList());
  }

  Future<void> addBill(BillModel bill) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('bills')
        .add(bill.toMap());
  }

  Future<void> toggleBillStatus(String billId, bool currentStatus) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('bills')
        .doc(billId)
        .update({'isPaid': !currentStatus});
  }

  Future<void> deleteBill(String billId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('bills')
        .doc(billId)
        .delete();
  }

  // ================= CASH FLOW SYSTEM (Step 6) =================
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

  Future<void> addTransaction(TransactionModel tx) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .add(tx.toMap());
  }
}
