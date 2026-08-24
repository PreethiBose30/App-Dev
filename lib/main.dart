import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
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
      home: const SplashScreen(),
    );
  }
}
