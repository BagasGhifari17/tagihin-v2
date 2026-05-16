import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart'; // <-- FIX: Lokasi path disesuaikan agar terdeteksi
import '../models/bill_model.dart';
import '../models/transaction_model.dart';
import '../services/recurring_engine.dart';

final firestoreServiceProvider = Provider((ref) => FirestoreService());

// Stream Tagihan Realtime
final billStreamProvider = StreamProvider<List<BillModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getBills();
});

// Stream Cash Flow Transaksi Realtime
final transactionStreamProvider = StreamProvider<List<TransactionModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getTransactions();
});

// Safe to Spend Engine Berdasarkan Arus Arsitektur Realtime
final safeToSpendProvider = Provider<double>((ref) {
  final bills = ref.watch(billStreamProvider).value ?? [];
  final transactions = ref.watch(transactionStreamProvider).value ?? [];

  final totalIncome = transactions
      .where((tx) => tx.type == 'income')
      .fold(0.0, (total, item) => total + item.amount);

  final totalExpense = transactions
      .where((tx) => tx.type == 'expense')
      .fold(0.0, (total, item) => total + item.amount);

  final totalUnpaidBills = bills
      .where((bill) => !bill.isPaid)
      .fold(0.0, (total, item) => total + item.amount);

  return (totalIncome - totalExpense) - totalUnpaidBills;
});

// Provider Tampilan Info Saldo Bersih Kotor
final netBalanceProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionStreamProvider).value ?? [];
  final totalIncome = transactions
      .where((tx) => tx.type == 'income')
      .fold(0.0, (total, item) => total + item.amount);
  final totalExpense = transactions
      .where((tx) => tx.type == 'expense')
      .fold(0.0, (total, item) => total + item.amount);

  return totalIncome - totalExpense;
});

// Inisialisasi RecurringEngine Dengan Penguncian Boolean Lokasi Pengaman Loop
final recurringEngineProvider = Provider<RecurringEngine>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return RecurringEngine(firestoreService);
});
