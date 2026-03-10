import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/custom_snackbar.dart';
import 'signup_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure = true;


  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }


  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      CustomSnackbar.showError(context, 'Please fill in all fields.');
      return;
    }
    await context.read<AppAuthProvider>().signIn(email, pass);
    if (!mounted) return;
    final err = context.read<AppAuthProvider>().errorMessage;
    if (err != null) CustomSnackbar.showError(context, err);
  }


  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final isLoading = auth.state == AuthState.loading;
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: kPrimaryDark,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                const Text('Welcome Back', style: kHeadingLarge),
                const SizedBox(height: 8),
                const Text('Sign in to your account', style: kCaptionText),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  style: kBodyText,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                        color: kTextSecondary,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  style: kBodyText,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    child: const Text('Sign In'),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SignupScreen())),
                    child: const Text("Don't have an account? Sign Up",
                      style: TextStyle(color: kAccentGold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
