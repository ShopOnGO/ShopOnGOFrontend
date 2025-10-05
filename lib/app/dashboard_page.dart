// ignore_for_file: avoid_print

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
  final TextEditingController _searchController = TextEditingController();

  static const int catalogPageIndex = 1;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void _onSearchChanged(String query) {
    print("Dashboard: Search query changed to: $query");
  }

  void _onSearchSubmitted() {
    print("Dashboard: Search submitted for: ${_searchController.text}");
    _onTabSelected(catalogPageIndex);
  }

  void _onClearSearch() {
    print("Dashboard: Search cleared.");
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      MainPage(
        searchController: _searchController,
        onSearchChanged: _onSearchChanged,
        onSearchSubmitted: _onSearchSubmitted,
        onClearSearch: _onClearSearch,
      ),
      CatalogPage(
        searchController: _searchController,
        onSearchChanged: _onSearchChanged,
        onSearchSubmitted: _onSearchSubmitted,
        onClearSearch: _onClearSearch,
      ),
      const ProfilePage(),
      const LikedPage(),
      const CartPage(),
    ];

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
                    style: Theme.of(
                      context,
                    ).textTheme.headlineLarge?.copyWith(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: TopNavbar(
                      currentIndex: currentIndex,
                      onTabSelected: _onTabSelected,
                      activeColor: Theme.of(context).colorScheme.primary,
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                  const SizedBox(width: 16),
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
