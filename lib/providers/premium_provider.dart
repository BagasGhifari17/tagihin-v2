import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider state premium (default awal: false/free user)
final isPremiumProvider = StateProvider<bool>((ref) {
  return false;
});
