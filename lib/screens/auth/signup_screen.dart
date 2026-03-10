import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/custom_snackbar.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}


class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure = true;


  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }


  Future<void> _signup() async {
    final name  = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text.trim();
    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      CustomSnackbar.showError(context, 'Please fill in all fields.');
      return;
    }
    if (pass.length < 6) {
      CustomSnackbar.showError(context, 'Password must be at least 6 characters.');
      return;
    }
    await context.read<AppAuthProvider>().signUp(email, pass, name);
    // AuthGate picks up the state change and navigates to EmailVerificationScreen automatically
  }


  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final isLoading = auth.state == AuthState.loading;
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: kPrimaryDark,
        appBar: AppBar(title: const Text('Create Account'), backgroundColor: kPrimaryDark),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Join Kigali Directory', style: kHeadingLarge),
                const SizedBox(height: 8),
                const Text('Create your account to list places', style: kCaptionText),
                const SizedBox(height: 40),
                TextField(controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  style: kBodyText),
                const SizedBox(height: 16),
                TextField(controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  style: kBodyText),
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
                  style: kBodyText),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _signup,
                    child: const Text('Create Account'),
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
