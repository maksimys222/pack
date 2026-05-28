import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const UPKApp());
}

class UPKApp extends StatelessWidget {
  const UPKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'УПК РФ — 100 задач',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
