// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../data/models/product.dart';
import '../presentation/pages/cart/cart_page.dart';
import '../presentation/pages/catalog/catalog_page.dart';
import '../presentation/pages/liked/liked_page.dart';
import '../presentation/pages/main/main_page.dart';
import '../presentation/pages/product_detail/product_detail_page.dart';
import '../presentation/pages/profile/profile_page.dart';
import '../presentation/widgets/top_navbar.dart';
import '../presentation/pages/auth/login_page.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const DashboardPage({super.key, required this.toggleTheme});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  Product? _selectedProduct;

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

  void _selectProduct(Product product) {
    setState(() {
      _selectedProduct = product;
    });
  }

  void _closeProductDetail() {
    setState(() {
      _selectedProduct = null;
    });
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6), 
      builder: (BuildContext dialogContext) {
        return LoginPage(
          onClose: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }


  void _onSearchChanged(String query) {
    print("Dashboard: Search query changed to: $query");
  }

  void _onSearchSubmitted() {
    final query = _searchController.text.trim();
    print("Dashboard: Search submitted for: $query");

    if (query.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Поисковый запрос должен содержать минимум 3 символа'),
            ],
          ),
        ),
      );
    } else {
      _onTabSelected(catalogPageIndex);
    }
  }

  void _onClearSearch() {
    print("Dashboard: Search cleared.");
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      MainPage(
        searchController: _searchController,
        onProductSelected: _selectProduct,
        onSearchChanged: _onSearchChanged,
        onSearchSubmitted: _onSearchSubmitted,
        onClearSearch: _onClearSearch,
      ),
      CatalogPage(
        searchController: _searchController,
        onProductSelected: _selectProduct,
        onSearchChanged: _onSearchChanged,
        onSearchSubmitted: _onSearchSubmitted,
        onClearSearch: _onClearSearch,
      ),
      ProfilePage(
        onProductSelected: _selectProduct,
        onLoginRequested: _showLoginDialog, 
      ),
      LikedPage(
        searchController: _searchController,
        onProductSelected: _selectProduct,
        onSearchChanged: _onSearchChanged,
        onSearchSubmitted: _onSearchSubmitted,
        onClearSearch: _onClearSearch,
      ),
      CartPage(onProductSelected: _selectProduct),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    "Tailornado",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: TopNavbar(
                      currentIndex: currentIndex,
                      onTabSelected: _onTabSelected,
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
      body: Stack(
        children: [
          pages[currentIndex],
          IgnorePointer(
            ignoring: _selectedProduct == null,
            child: AnimatedOpacity(
              opacity: _selectedProduct != null ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: AnimatedScale(
                scale: _selectedProduct != null ? 1.0 : 0.9,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                child: _selectedProduct != null
                    ? ProductDetailPage(
                        product: _selectedProduct!,
                        onClose: _closeProductDetail,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
