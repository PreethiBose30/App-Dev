import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/dashboard/add_product_screen.dart';

void main() {
  runApp(const DigitalVaultApp());
}

class DigitalVaultApp extends StatelessWidget {
  const DigitalVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Vault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D), // Pure Velvet Black
        brightness: Brightness.dark,
        fontFamily: 'Montserrat',
      ),
      initialRoute: '//add-product',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/add-product': (context) => const AddProductScreen(),
        // Preethi's screens route into this matrix smoothly
      },
    );
  }
}