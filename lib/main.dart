import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/floating_window.dart';

void main() {
  runApp(const MyApp());
}

// Overlay entry point
@pragma("vm:entry-point")
void overlayMain() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AdvancedFloatingButton(), // Updated to use AdvancedFloatingButton
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viannie',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}