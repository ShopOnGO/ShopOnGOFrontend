import 'package:flutter/material.dart';
import '../presentation/pages/cart/cart_page.dart';
import '../presentation/pages/catalog/catalog_page.dart';
import '../presentation/pages/liked/liked_page.dart';
import '../presentation/pages/main/main_page.dart';
import '../presentation/pages/profile/profile_page.dart';
import '../presentation/widgets/top_navbar.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const DashboardPage({super.key, required this.toggleTheme});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentIndex = 0;
  final pages = const [
    MainPage(),
    CatalogPage(),
    ProfilePage(),
    LikedPage(),
    CartPage(),
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
        preferredSize: const Size.fromHeight(80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    "Tailornado",
                    style: Theme.of(context,).textTheme.headlineLarge?.copyWith(),
                  ),
                  const Spacer(),
                  TopNavbar(
                    currentIndex: currentIndex,
                    onTabSelected: onTabSelected,
                    activeColor: Theme.of(context).colorScheme.primary,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.brightness_6),
                    onPressed: widget.toggleTheme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: pages[currentIndex],
    );
  }
}
