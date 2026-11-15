import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/swiss.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../dashboard/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill in all fields')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await AuthService.register(name: name, email: email, password: password);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: swissAppBar(context, 'Create account'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New here',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 44, height: 1.0, fontWeight: FontWeight.w900, letterSpacing: -2),
              ),
              const SizedBox(height: 10),
              Text(
                'Make an account to keep your products and documents safe and in sync.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
                decoration: swissInput('Name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
                decoration: swissInput('Email'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
                decoration: swissInput('Password', hint: 'At least 6 characters'),
              ),
              const SizedBox(height: 36),
              SwissButton('Create account', onPressed: _register, loading: _isSubmitting),
              SlowHint(active: _isSubmitting, text: 'Waking up the server. This can take up to a minute the first time.'),
            ],
          ),
        ),
      ),
    );
  }
}
