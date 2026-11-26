import 'package:flutter/material.dart';
import 'screens/home.dart';

void main() {
  runApp(const EngrCalcApp());
}

class EngrCalcApp extends StatelessWidget {
  const EngrCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EngrCalc_v1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315A78)),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}
