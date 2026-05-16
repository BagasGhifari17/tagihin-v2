import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';

class DartSplashScreen extends ConsumerStatefulWidget {
  const DartSplashScreen({super.key});

  @override
  ConsumerState<DartSplashScreen> createState() => _DartSplashScreenState();
}

class _DartSplashScreenState extends ConsumerState<DartSplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextGate();
  }

  void _navigateToNextGate() async {
    // Jeda 3 detik untuk membangun "vibe" premium & tenang
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final authStatus = ref.read(authStatusProvider);

    if (authStatus == AuthStatus.authenticated) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FB), // Background off-white (Calming)
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            children: [
              // 1. AREA ATAS KOSONG (Hierarchy Breathing Space)
              const Spacer(flex: 3),

              // 2. LOGO BESAR (Modern Pocket Concept)
              const SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: TagihInPocketPainter(),
                ),
              ),

              const SizedBox(height: 32),

              // 3. TITLE "Tagih.In" (Tegas & Profesional)
              const Text(
                'Tagih.In',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E3A8A), // Deep Blue (Trustworthy)
                  letterSpacing: -1.0,
                ),
              ),

              const SizedBox(height: 8),

              // 4. TAGLINE KECIL (Subtle & Light)
              Text(
                'Ingat Tagihan, Tenang Kehidupan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.blueGrey.withValues(alpha: .7),
                  letterSpacing: 0.2,
                ),
              ),

              // 5. SPACER TENGAH
              const Spacer(flex: 4),

              // 6. LOADING INDICATOR KECIL (Minimalis)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                ),
              ),

              // 7. BOTTOM SAFE AREA PADDING
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===========================================================================
/// CUSTOM PAINTER: MODERN POCKET LOGO (Financial Calm Identity)
/// ===========================================================================
class TagihInPocketPainter extends CustomPainter {
  const TagihInPocketPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6) // Fintech Blue (Calming yet Modern)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // A. MENGGAMBAR BENTUK POCKET (Rounded & Geometris)
    // Bentuk dasar kantong uang modern yang solid
    final RRect pocketRect = RRect.fromLTRBAndCorners(
      size.width * 0.15,
      size.height * 0.10,
      size.width * 0.85,
      size.height * 0.90,
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: const Radius.circular(40),
      bottomRight: const Radius.circular(40),
    );
    canvas.drawRRect(pocketRect, paint);

    // B. GARIS HORIZONTAL KHAS (The "Tagih" Slit)
    // Garis tipis melengkung halus di bagian atas kantong
    final Path slitPath = Path()
      ..moveTo(size.width * 0.30, size.height * 0.35)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.40,
        size.width * 0.70,
        size.height * 0.35,
      );
    canvas.drawPath(slitPath, linePaint);

    // C. TITIK KHAS TAGIH.IN (The Signature Dot)
    // Diletakkan di sudut kanan bawah sebagai identitas unik
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.70),
      7.0,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
