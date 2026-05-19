import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const PrismApp());
}

class PrismApp extends StatelessWidget {
  const PrismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PRISM AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF185FA5)),
        fontFamily: 'Georgia',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
