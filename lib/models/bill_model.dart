import 'package:cloud_firestore/cloud_firestore.dart';

class BillModel {
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final String recurrence; // 'none', 'weekly', 'monthly', 'yearly'

  BillModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
    this.recurrence = 'none',
  });

  // --- KONSTRUKTOR UTAMA UNTUK FIRESTORE SERVICE ---
  factory BillModel.fromMap(String id, Map<String, dynamic> map) {
    return BillModel(
      id: id,
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      dueDate: map['dueDate'] is Timestamp
          ? (map['dueDate'] as Timestamp).toDate()
          : DateTime.parse(map['dueDate'] ?? DateTime.now().toString()),
      isPaid: map['isPaid'] ?? false,
      recurrence: map['recurrence'] ?? 'none',
    );
  }

  // --- PEMETAAN UNTUK MENULIS DATA KE FIRESTORE ---
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'isPaid': isPaid,
      'recurrence': recurrence,
    };
  }

  // Alias tambahan untuk fleksibilitas arsitektur ke depan
  factory BillModel.fromFirestore(Map<String, dynamic> json, String id) {
    return BillModel.fromMap(id, json);
  }

  Map<String, dynamic> toFirestore() {
    return toMap();
  }
}
