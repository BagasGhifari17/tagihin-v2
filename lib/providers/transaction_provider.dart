import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';
import 'bill_provider.dart';

class TransactionFormNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    return;
  }

  Future<bool> submitTransaction({
    required String title,
    required double amount,
    required String type,
    required String category,
    required DateTime date,
  }) async {
    state = const AsyncValue.loading();

    try {
      final tx = TransactionModel(
        id: '',
        title: title,
        amount: amount,
        type: type,
        category: category,
        date: date,
      );

      // JANGAN pakai 'await' di sini jika Firestore offline/network kamu membuat Future-nya gantung.
      // Firestore secara native akan mengurus antrean penulisan di latar belakang (Offline Persistence).
      ref.read(firestoreServiceProvider).addTransaction(tx);

      // Langsung set ke data sukses agar loading di UI langsung berhenti seketika
      state = const AsyncValue<void>.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  void resetForm() {
    state = const AsyncValue<void>.data(null);
  }
}

final transactionFormNotifierProvider =
    AsyncNotifierProvider<TransactionFormNotifier, void>(() {
  return TransactionFormNotifier();
});
