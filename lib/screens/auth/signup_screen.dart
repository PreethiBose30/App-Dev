import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // Deep Black
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFF4F4F0), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Typography
                  const Text(
                    'CREATE ACCOUNT',
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
                    'Join the digital vault.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF7A7A7A), // Cool Grey
                    ),
                  ),
                  const SizedBox(height: 40),

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
                        // Full Name Field
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Color(0xFFF4F4F0), fontSize: 15),
                          decoration: InputDecoration(
                            labelText: 'FULL NAME',
                            labelStyle: const TextStyle(color: Color(0xFF7A7A7A), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                            prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF7A7A7A), size: 20),
                            border: InputBorder.none,
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFF4F4F0))),
                          ),
                        ),
                        const SizedBox(height: 20),

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
                        const SizedBox(height: 20),

                        // Confirm Password Field
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          style: const TextStyle(color: Color(0xFFF4F4F0), fontSize: 15),
                          decoration: InputDecoration(
                            labelText: 'CONFIRM PASSWORD',
                            labelStyle: const TextStyle(color: Color(0xFF7A7A7A), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF7A7A7A), size: 20),
                            border: InputBorder.none,
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFF4F4F0))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Elite Ivory Register Button
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
                          // Sign Up Logic
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
                        'REGISTER',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Return to Login Link
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "ALREADY HAVE AN ACCOUNT? SIGN IN",
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