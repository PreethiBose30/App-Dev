import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/swiss.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../dashboard/home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email and password')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await AuthService.login(email: email, password: password);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type your email above first, then tap Forgot password.')),
      );
      return;
    }
    try {
      await AuthService.sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('If an account exists for $email, a reset link is on its way. Check spam too.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/icon/app_icon_tile.png', width: 52, height: 52),
              const SizedBox(height: 40),
              Text(
                'Sign in',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 52, height: 1.0, fontWeight: FontWeight.w900, letterSpacing: -2.5),
              ),
              const SizedBox(height: 10),
              Text(
                'Your bills, warranties and expiry dates, in one place.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 40),
              Container(height: 1.5, color: AppColors.rule),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
                decoration: swissInput('Email'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
                decoration: swissInput('Password'),
                onFieldSubmitted: (_) => _isSubmitting ? null : _login(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isSubmitting ? null : _forgotPassword,
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text('Forgot password?', style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 12),
              SwissButton('Sign in', onPressed: _login, loading: _isSubmitting),
              SlowHint(active: _isSubmitting, text: 'Waking up the server. The first sign-in can take up to a minute.'),
              const SizedBox(height: 12),
              SwissButton(
                'Create an account',
                outlined: true,
                onPressed: _isSubmitting
                    ? null
                    : () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
