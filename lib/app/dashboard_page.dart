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
import '../presentation/pages/chat/chat_overlay.dart';
import '../presentation/pages/profile/settings_page.dart';
import '../presentation/pages/profile/faq_page.dart';
import '../core/utils/app_logger.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const DashboardPage({super.key, required this.toggleTheme});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

enum ProfileOverlay { none, settings, faq }

class _DashboardPageState extends State<DashboardPage> {
  
  int currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  
  RangeValues _priceRange = const RangeValues(0, 300);
  int? _selectedBrandId;

  Product? _selectedProduct;
  ProfileOverlay _activeProfileOverlay = ProfileOverlay.none;
  bool _isChatOpen = false;

  static const int catalogPageIndex = 1;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    logger.i('Navigation: Tab changed to index $index');
    setState(() {
      currentIndex = index;
    });
  }

  void _selectProduct(Product product) {
    logger.i('Navigation: Opening Product Detail for ID ${product.id}');
    setState(() {
      _selectedProduct = product;
    });
  }

  void _closeProductDetail() {
    logger.d('Navigation: Closing Product Detail');
    setState(() {
      _selectedProduct = null;
    });
  }

  void _showProfileOverlay(ProfileOverlay type) {
    logger.i('Navigation: Showing profile overlay: $type');
    setState(() {
      _activeProfileOverlay = type;
    });
  }

  void _closeProfileOverlay() {
    logger.d('Navigation: Closing profile overlay');
    setState(() {
      _activeProfileOverlay = ProfileOverlay.none;
    });
  }

  void _showLoginDialog() {
    logger.i('Auth: Login Dialog requested');
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6), 
      builder: (BuildContext dialogContext) {
        return LoginPage(
          onClose: () {
            logger.d('Auth: Login Dialog closed');
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  void _toggleChat() {
    logger.d('Chat: Toggle chat window. Current state open: $_isChatOpen');
    setState(() {
      _isChatOpen = !_isChatOpen;
    });
  }

  void _onSearchSubmitted() {
    logger.i('Search: Global search submitted: "${_searchController.text}"');
    _onTabSelected(catalogPageIndex);
  }

  void _onApplyFilters(RangeValues range, int? brandId) {
    logger.i('Filters: Global filter applied. Price: $range, Brand: $brandId');
    setState(() {
      _priceRange = range;
      _selectedBrandId = brandId;
    });
    _onTabSelected(catalogPageIndex);
  }
  
  @override
  Widget build(BuildContext context) {
    final pages = [
      MainPage(
        searchController: _searchController,
        onProductSelected: _selectProduct,
        onSearchChanged: (q) {},
        onSearchSubmitted: _onSearchSubmitted,
        onClearSearch: () => _searchController.clear(),
        onApplyFilters: _onApplyFilters,
      ),
      CatalogPage(
        searchController: _searchController,
        priceRange: _priceRange,
        selectedBrandId: _selectedBrandId,
        onProductSelected: _selectProduct,
        onSearchChanged: (q) {},
        onSearchSubmitted: _onSearchSubmitted,
        onClearSearch: () => _searchController.clear(),
        onApplyFilters: _onApplyFilters,
      ),
      ProfilePage(
        onProductSelected: _selectProduct,
        onLoginRequested: _showLoginDialog,
        onSettingsRequested: () => _showProfileOverlay(ProfileOverlay.settings),
        onFaqRequested: () => _showProfileOverlay(ProfileOverlay.faq),
      ),
      LikedPage(
        onProductSelected: _selectProduct,
      ),
      CartPage(onProductSelected: _selectProduct),
    ];

    bool isOverlayOpen = _selectedProduct != null || _activeProfileOverlay != ProfileOverlay.none;

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
                    onPressed: () {
                      logger.d('App: Theme toggled');
                      widget.toggleTheme();
                    },
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
              child: _selectedProduct != null
                  ? ProductDetailPage(
                      product: _selectedProduct!,
                      onClose: _closeProductDetail,
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          if (_activeProfileOverlay == ProfileOverlay.settings)
            SettingsPage(onClose: _closeProfileOverlay),

          if (_activeProfileOverlay == ProfileOverlay.faq)
            FaqPage(onClose: _closeProfileOverlay),

          Positioned(
            right: 24.0,
            bottom: 24.0,
            child: IgnorePointer(
              ignoring: isOverlayOpen,
              child: AnimatedOpacity(
                opacity: isOverlayOpen ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: ChatOverlay(
                  isChatOpen: _isChatOpen,
                  toggleChat: _toggleChat,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}