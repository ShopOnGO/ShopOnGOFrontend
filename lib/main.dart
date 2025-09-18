import 'package:flutter/material.dart';
import 'themes/app_theme.dart';
import 'widgets/top_navbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: DashboardPage(toggleTheme: toggleTheme),
    );
  }
}

class DashboardPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const DashboardPage({super.key, required this.toggleTheme});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentIndex = 0;

  final pages = const [
    Center(child: Text("Главная страница")),
    Center(child: Text("Каталог")),
    Center(child: Text("Личный кабинет")),
    Center(child: Text("Корзина")),
  ];

  void onTabSelected(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: TopNavbar(
          currentIndex: currentIndex,
          onTabSelected: onTabSelected,
          activeColor: Theme.of(context).colorScheme.primary,
          color: Colors.grey.shade600,
          borderColor: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
      body: pages[currentIndex],
    );
  }
}
