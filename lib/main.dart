import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Inventory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // Fits a clean dark theme
      home: const LoginScreen(),
    );
  }
}