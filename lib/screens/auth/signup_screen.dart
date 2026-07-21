import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
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
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'INITIALIZE PROTOCOL',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 2.5, color: Color(0xFFF4F4F0)),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Provision fresh terminal security records.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF7A7A7A)),
                ),
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Color(0xFFF4F4F0), fontSize: 15),
                        decoration: InputDecoration(
                          labelText: 'OPERATOR IDENTITY NAME',
                          labelStyle: const TextStyle(color: Color(0xFF7A7A7A), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF7A7A7A), size: 18),
                          border: InputBorder.none,
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFF4F4F0))),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Color(0xFFF4F4F0), fontSize: 15),
                        decoration: InputDecoration(
                          labelText: 'EMAIL LINK REFERENCE',
                          labelStyle: const TextStyle(color: Color(0xFF7A7A7A), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                          prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF7A7A7A), size: 18),
                          border: InputBorder.none,
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFF4F4F0))),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Color(0xFFF4F4F0), fontSize: 15),
                        decoration: InputDecoration(
                          labelText: 'SECURE CREDENTIAL KEY',
                          labelStyle: const TextStyle(color: Color(0xFF7A7A7A), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF7A7A7A), size: 18),
                          border: InputBorder.none,
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFF4F4F0))),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF4F4F0),
                    foregroundColor: const Color(0xFF0D0D0D),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('REGISTER TERMINAL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}