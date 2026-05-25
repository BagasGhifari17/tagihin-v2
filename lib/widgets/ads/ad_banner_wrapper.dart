import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/premium_provider.dart';

class AdBannerWrapper extends ConsumerWidget {
  const AdBannerWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    // KUNCI UTAMA: Jika premium aktif, hancurkan widget iklan dari pohon memori render
    if (isPremium) {
      return const SizedBox.shrink();
    }

    // Tampilan layout iklan versi gratisan yang estetik (iOS Style Card)
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "IKLAN",
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Ruang Iklan Mitra Tagih.In",
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
