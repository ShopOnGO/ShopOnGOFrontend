import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../data/models/product.dart';
import '../presentation/pages/cart/cart_page.dart';
import '../presentation/pages/catalog/catalog_page.dart';
import '../presentation/pages/liked/liked_page.dart';
import '../presentation/pages/main/main_page.dart';
import '../presentation/pages/product_detail/product_detail_page.dart';
import '../presentation/pages/profile/profile_page.dart';
import '../presentation/widgets/top_navbar.dart';
import '../presentation/widgets/bottom_navbar.dart';
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

  RangeValues _priceRange = const RangeValues(0, 10000);
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
    setState(() {
      _selectedProduct = product;
    });
  }

  void _closeProductDetail() {
    setState(() {
      _selectedProduct = null;
    });
  }

  void _showProfileOverlay(ProfileOverlay type) {
    setState(() {
      _activeProfileOverlay = type;
    });

    Widget page;
    if (type == ProfileOverlay.settings) {
      page = SettingsPage(onClose: () => Navigator.of(context).pop());
    } else {
      page = FaqPage(onClose: () => Navigator.of(context).pop());
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (BuildContext dialogContext) => page,
    ).then((_) {
      setState(() {
        _activeProfileOverlay = ProfileOverlay.none;
      });
    });
  }

  void _showLoginDialog() {
    setState(() => _activeProfileOverlay = ProfileOverlay.none);
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (BuildContext dialogContext) {
        return LoginPage(onClose: () => Navigator.of(dialogContext).pop());
      },
    );
  }

  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
    });
  }

  void _onSearchSubmitted() {
    _onTabSelected(catalogPageIndex);
  }

  void _onApplyFilters(RangeValues range, int? brandId) {
    setState(() {
      _priceRange = range;
      _selectedBrandId = brandId;
    });
    _onTabSelected(catalogPageIndex);
  }

  void _toggleLanguage() {
    if (context.locale == const Locale('ru')) {
      context.setLocale(const Locale('en'));
      logger.i('App: Language changed to English');
    } else {
      context.setLocale(const Locale('ru'));
      logger.i('App: Language changed to Russian');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 650;
    const double bottomNavbarHeight = 95.0;

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
      LikedPage(onProductSelected: _selectProduct),
      CartPage(onProductSelected: _selectProduct),
    ];

    bool isProductDetailOpen = _selectedProduct != null;
    bool isAnyOverlayOpen =
        isProductDetailOpen || _activeProfileOverlay != ProfileOverlay.none;

    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isMobile ? 75 : 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    "Tailornado",
                    style: isMobile
                        ? Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          )
                        : Theme.of(context).textTheme.headlineLarge,
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 5,
                      child: TopNavbar(
                        currentIndex: currentIndex,
                        onTabSelected: _onTabSelected,
                      ),
                    ),
                  ],
                  const SizedBox(width: 16),
                  if (isMobile) const Spacer(),
                  TextButton(
                    onPressed: _toggleLanguage,
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "lang_code".tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 16 : 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.brightness_6, size: isMobile ? 28 : 24),
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

          if (isProductDetailOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeProductDetail,
                child: Container(color: Colors.black.withValues(alpha: 0.4)),
              ),
            ),

          IgnorePointer(
            ignoring: !isProductDetailOpen,
            child: AnimatedOpacity(
              opacity: isProductDetailOpen ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: isMobile ? bottomNavbarHeight : 0,
                ),
                child: isProductDetailOpen
                    ? ProductDetailPage(
                        product: _selectedProduct!,
                        onClose: _closeProductDetail,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),

          Positioned(
            right: isMobile ? (_isChatOpen ? 12.0 : 24.0) : 24.0,
            bottom: isMobile ? 115.0 : 24.0,
            child: IgnorePointer(
              ignoring: isAnyOverlayOpen,
              child: AnimatedOpacity(
                opacity: isAnyOverlayOpen ? 0.0 : 1.0,
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
      bottomNavigationBar: isMobile
          ? BottomNavbar(
              currentIndex: currentIndex,
              onTabSelected: _onTabSelected,
            )
          : null,
    );
  }
}
