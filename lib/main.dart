import 'package:flutter/material.dart';
import 'widgets/sidebar.dart';
import 'widgets/top_navbar.dart';
import 'widgets/info_block.dart';

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
          Expanded(
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: TopNavbar(
                  itemCount: 7,
                  itemWidth: 100,
                  overlap: 20,
                  height: 40,
                  color: Colors.grey.shade300,
                  borderColor: const Color.fromARGB(255, 254, 247, 255),
                  borderWidth: 7,
                  borderRadius: 20,
                  margin: const EdgeInsets.all(8.0),
                ),
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: InfoBlock(
                      spacing: 16,
                      leftCardHeight: 150,
                      rightCardHeight: 150,
                      leftCardColor: const Color.fromARGB(255, 61, 59, 59),
                      rightCardColor: Colors.grey.shade300,
                    ),
                  ),
                  Expanded(child: Container(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
