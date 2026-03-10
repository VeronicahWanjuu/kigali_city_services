import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

// This is the first screen the user sees when the app opens.
// It shows the app name with a fade-in animation for 2 seconds.
// During this time Firebase Auth is checking if there is a saved session.
// AuthGate in main.dart handles the navigation automatically.

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    // I use an AnimationController to fade the content in over 1.5 seconds
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDark,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gold location pin icon as the app logo
              const Icon(
                Icons.location_pin,
                color: kAccentGold,
                size: 80,
              ),
              const SizedBox(height: 24),
              const Text(
                'Kigali City Services',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Places Directory',
                style: TextStyle(
                  color: kAccentGold,
                  fontSize: 16,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: kAccentGold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}