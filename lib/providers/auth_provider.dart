import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

// 1. Menyediakan instansi AuthService untuk dipakai aksi Login & Profile Screen
final authServiceProvider = Provider((ref) => AuthService());

// 2. Menyediakan stream global status user agar ProfileScreen bisa tahu siapa yang sedang login
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authServiceProvider).userStream;
});
