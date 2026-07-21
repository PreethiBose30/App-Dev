import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'DIGITAL VAULT',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 3.0, color: Color(0xFFF4F4F0)),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Secure document repository infrastructure.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF7A7A7A)),
                ),
                const SizedBox(height: 44),

                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A), // Charcoal Card
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Color(0xFFF4F4F0), fontSize: 15),
                        decoration: InputDecoration(
                          labelText: 'ACCESS IDENTITY / EMAIL',
                          labelStyle: const TextStyle(color: Color(0xFF7A7A7A), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                          prefixIcon: const Icon(Icons.shield_outlined, color: Color(0xFF7A7A7A), size: 18),
                          border: InputBorder.none,
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFF4F4F0))),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Color(0xFFF4F4F0), fontSize: 15),
                        decoration: InputDecoration(
                          labelText: 'PASSWORD',
                          labelStyle: const TextStyle(color: Color(0xFF7A7A7A), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                          prefixIcon: const Icon(Icons.lock_open_outlined, color: Color(0xFF7A7A7A), size: 18),
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
                  onPressed: () {
                    // Placeholder action to transition straight into dashboard
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Access Granted. Routing initialized.')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF4F4F0), // Ivory Fill
                    foregroundColor: const Color(0xFF0D0D0D),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('AUTHORIZE ACCESS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                ),
                const SizedBox(height: 24),

                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text(
                    "CREATE SYSTEM ACCOUNT",
                    style: TextStyle(color: Color(0xFF7A7A7A), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2),
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