import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../data/models/product.dart';
import '../../../data/models/brand.dart';
import '../../../data/providers/liked_provider.dart';
import '../../../data/services/product_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../widgets/filter_panel.dart';
import '../../widgets/product_grid.dart';
import '../../widgets/search_bar.dart';

class LikedPage extends StatefulWidget {
  final Function(Product) onProductSelected;

  const LikedPage({super.key, required this.onProductSelected});

  @override
  State<LikedPage> createState() => _LikedPageState();
}

class _LikedPageState extends State<LikedPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final AnimationController _animationController;
  final ProductService _productService = ProductService();

  String _searchQuery = '';
  bool _isFilterPanelVisible = false;

  RangeValues _priceRange = const RangeValues(0, 10000);
  int? _selectedBrandId;
  List<Brand> _brands = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    final brands = await _productService.getAllBrands();
    if (mounted) {
      setState(() {
        _brands = brands;
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchQuery != _searchController.text.trim()) {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    }
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _onSearchSubmitted() {
    logger.i("LikedPage: Search submitted for query: $_searchQuery");
  }

  void _toggleFilterPanel() {
    final bool isMobile = MediaQuery.of(context).size.width < 650;

    if (isMobile) {
      logger.i('LikedPage: Opening mobile filter sheet');
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        builder: (context) {
          final likedProvider = context.read<LikedProvider>();
          double maxLikedPrice = 0;
          for (var item in likedProvider.likedItems) {
            for (var v in item.product.variants) {
              if (v.price > maxLikedPrice) maxLikedPrice = v.price;
            }
          }
          if (maxLikedPrice == 0) maxLikedPrice = 1000;

          return FilterPanel(
            brands: _brands,
            initialBrandId: _selectedBrandId,
            initialRange: _priceRange,
            maxLimit: maxLikedPrice,
            onApply: _applyFilterAndClose,
            isMobile: true,
          );
        },
      );
    } else {
      setState(() {
        _isFilterPanelVisible = !_isFilterPanelVisible;
        if (_isFilterPanelVisible) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
    }
  }

  void _applyFilterAndClose(RangeValues range, int? brandId) {
    setState(() {
      _priceRange = range;
      _selectedBrandId = brandId;
    });

    if (MediaQuery.of(context).size.width < 650) {
      Navigator.pop(context);
    } else {
      _toggleFilterPanel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 650;
    const double searchBarHeight = 50.0;
    final double horizontalPadding = isMobile ? 16.0 : 45.0;

    final likedProvider = context.watch<LikedProvider>();
    final allLikedProducts = likedProvider.likedItems
        .map((item) => item.product)
        .toList();

    double maxLikedPrice = 0;
    for (var p in allLikedProducts) {
      for (var v in p.variants) {
        if (v.price > maxLikedPrice) maxLikedPrice = v.price;
      }
    }
    if (maxLikedPrice == 0) maxLikedPrice = 1000;

    final filteredProducts = allLikedProducts.where((product) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = product.name.toLowerCase().contains(query);
        final brandMatch = product.brand.name.toLowerCase().contains(query);
        if (!nameMatch && !brandMatch) return false;
      }

      if (product.variants.isNotEmpty) {
        bool hasValidVariant = product.variants.any((v) => 
          v.price >= _priceRange.start && v.price <= _priceRange.end
        );
        if (!hasValidVariant) return false;
      }

      if (_selectedBrandId != null) {
        if (product.brand.id != _selectedBrandId) {
          return false;
        }
      }

      return true;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 5, horizontalPadding, 0),
          child: Stack(
            children: [
              if (!isMobile)
                Padding(
                  padding: const EdgeInsets.only(top: searchBarHeight / 2),
                  child: SizeTransition(
                    sizeFactor: CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.fastOutSlowIn,
                    ),
                    child: FilterPanel(
                      brands: _brands,
                      initialBrandId: _selectedBrandId,
                      initialRange: _priceRange,
                      maxLimit: maxLikedPrice,
                      onApply: _applyFilterAndClose,
                    ),
                  ),
                ),
              CustomSearchBar(
                controller: _searchController,
                hintText: "search.liked_hint".tr(), 
                onSearchSubmitted: _onSearchSubmitted,
                onClear: _onClearSearch,
                onFilterTap: _toggleFilterPanel,
              ),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: (_isFilterPanelVisible && !isMobile) ? _toggleFilterPanel : null,
            child: Padding(
              padding: EdgeInsets.only(top: isMobile ? 15 : 30),
              child: ProductGrid(
                products: filteredProducts,
                maxCrossAxisExtent: isMobile ? 350 : 420,
                onProductSelected: widget.onProductSelected,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}