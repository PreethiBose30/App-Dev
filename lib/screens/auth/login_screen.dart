import 'package:flutter/material.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // Deep Black
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Elegant Logo/Icon Placeholder
                  Center(
                    child: Container(
                      height: 64,
                      width: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F0), // Ivory
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.all_inbox_rounded,
                        color: Color(0xFF0D0D0D),
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Header Typography
                  const Text(
                    'DIGITAL INVENTORY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                      color: Color(0xFFF4F4F0), // Ivory Text
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'An elegant vault for your product documents.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF7A7A7A), // Cool Grey
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Input Form Container with Shadow
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A), // Dark Charcoal Card
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Color(0xFFF4F4F0), fontSize: 15),
                          decoration: InputDecoration(
                            labelText: 'EMAIL ADDRESS',
                            labelStyle: const TextStyle(color: Color(0xFF7A7A7A), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                            prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF7A7A7A), size: 20),
                            border: InputBorder.none,
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFF4F4F0))),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Color(0xFFF4F4F0), fontSize: 15),
                          decoration: InputDecoration(
                            labelText: 'PASSWORD',
                            labelStyle: const TextStyle(color: Color(0xFF7A7A7A), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                            prefixIcon: const Icon(Icons.lock_open_rounded, color: Color(0xFF7A7A7A), size: 20),
                            border: InputBorder.none,
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFF4F4F0))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Elite Ivory Login Button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF4F4F0).withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Login Logic
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF4F4F0), // Ivory
                        foregroundColor: const Color(0xFF0D0D0D), // Black text
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'SIGN IN',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Subtext Link
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    },
                    child: const Text(
                      "CREATE AN ACCOUNT",
                      style: TextStyle(
                        color: Color(0xFF7A7A7A),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}