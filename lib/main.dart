import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import internal project
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/main_navigation.dart';
import 'screens/splash/splash_screen.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

enum AuthStatus { unknown, authenticated, unauthenticated }

final authStatusProvider = Provider<AuthStatus>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user != null) {
        return AuthStatus.authenticated;
      } else {
        return AuthStatus.unauthenticated;
      }
    },
    loading: () => AuthStatus.unknown,
    error: (_, __) => AuthStatus.unauthenticated,
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFF8F9FB),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await initializeDateFormatting('id_ID', null);

  runApp(
    const ProviderScope(
      child: TagihInApp(),
    ),
  );
}

class TagihInApp extends ConsumerWidget {
  const TagihInApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tetap pancing listener auth di level tertinggi sejak awal booting aplikasi
    ref.watch(authStatusProvider);

    return MaterialApp(
      title: 'Tagih.In',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // FIX SAKTI: Selalu render Splash Screen duluan di gerbang utama tanpa interupsi kondisi auth reaktif
      home: const DartSplashScreen(),

      // Peta navigasi penuh untuk mendukung perpindahan rute dari Splash Screen lo
      routes: {
        '/splash': (context) => const DartSplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainNavigation(),
      },
    );
  }
}
