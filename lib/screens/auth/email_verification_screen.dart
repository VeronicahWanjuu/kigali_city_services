import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_snackbar.dart';


// This is the hard gate the user cannot enter the app until
// they click the email verification link.
// I poll Firebase every 3 seconds to detect when they clicked it.


class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});
  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}


class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _resendEnabled = true;


  @override
  void initState() {
    super.initState();
    // Every 3 seconds I reload the Firebase user and check if emailVerified changed
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      context.read<AppAuthProvider>().refreshAuthState();
    });
  }


  @override
  void dispose() {
    _timer?.cancel(); // I always cancel timers in dispose
    super.dispose();
  }


  Future<void> _resend() async {
    setState(() => _resendEnabled = false);
    await context.read<AppAuthProvider>().sendVerificationEmail();
    if (!mounted) return;
    CustomSnackbar.showSuccess(context, 'Verification email sent!');
    // I disable the resend button for 30 seconds to prevent spam
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) setState(() => _resendEnabled = true);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread, color: kAccentGold, size: 80),
              const SizedBox(height: 24),
              const Text('Check Your Email', style: kHeadingLarge),
              const SizedBox(height: 12),
              const Text(
                'We sent a verification link to your email.\n'
                'Click the link then return to the app.',
                style: kBodyText,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: kAccentGold),
              ),
              const SizedBox(height: 8),
              const Text('Checking automatically every 3 seconds...', style: kCaptionText),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _resendEnabled ? _resend : null,
                  child: Text(_resendEnabled ? 'Resend Email' : 'Email Sent...'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.read<AppAuthProvider>().signOut(),
                child: const Text('Use a different account',
                  style: TextStyle(color: kTextSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
