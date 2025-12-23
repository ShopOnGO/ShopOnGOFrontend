import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    setState(() {
      _isFilterPanelVisible = !_isFilterPanelVisible;
      if (_isFilterPanelVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _applyFilterAndClose(RangeValues range, int? brandId) {
    setState(() {
      _priceRange = range;
      _selectedBrandId = brandId;
    });
    _toggleFilterPanel();
  }

  @override
  Widget build(BuildContext context) {
    const double searchBarHeight = 50.0;

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
        bool hasValidPrice = product.variants.any(
          (v) => v.price >= _priceRange.start && v.price <= _priceRange.end,
        );
        if (!hasValidPrice) return false;
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
          padding: const EdgeInsets.fromLTRB(45, 5, 45, 0),
          child: Stack(
            children: [
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
                hintText: "Искать в избранном...",
                onSearchSubmitted: _onSearchSubmitted,
                onClear: _onClearSearch,
                onFilterTap: _toggleFilterPanel,
              ),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: _isFilterPanelVisible ? _toggleFilterPanel : null,
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: ProductGrid(
                products: filteredProducts,
                maxCrossAxisExtent: 420,
                onProductSelected: widget.onProductSelected,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
