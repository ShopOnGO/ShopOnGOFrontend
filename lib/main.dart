import 'package:flutter/material.dart';
import 'widgets/sidebar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            itemCount: 6,
            width: 70,
            backgroundColor: Colors.grey.shade200,
            iconColor: Colors.grey.shade400,
            spacing: 12,
            radius: 15,
          ),
        ],
      ),
    );
  }
}
