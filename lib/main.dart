import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/place_provider.dart';
import 'providers/location_provider.dart';
import 'providers/review_provider.dart';
import 'providers/bookmark_provider.dart';
import 'services/auth_service.dart';
import 'services/place_service.dart';
import 'services/review_service.dart';
import 'services/bookmark_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/main_screen.dart';
import 'utils/app_theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  runApp(const KigaliDirectoryApp());
}


class KigaliDirectoryApp extends StatelessWidget {
  const KigaliDirectoryApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider(AuthService())),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => PlaceProvider(PlaceService())),
        ChangeNotifierProvider(create: (_) => ReviewProvider(ReviewService())),
        ChangeNotifierProvider(create: (_) => BookmarkProvider(BookmarkService())),
      ],
      child: MaterialApp(
        title: 'Kigali Directory',
        theme: AppTheme.darkTheme,
        home: const AuthGate(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}


// AuthGate watches AppAuthProvider and routes to the right screen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});


  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppAuthProvider>().state;
    return switch (s) {
      AuthState.initial || AuthState.loading => const SplashScreen(),
      AuthState.authenticated               => const MainScreen(),
      AuthState.verificationRequired        => const EmailVerificationScreen(),
      AuthState.unauthenticated || AuthState.error => const LoginScreen(),
    };
  }
}
