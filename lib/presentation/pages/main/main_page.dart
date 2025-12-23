import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../data/models/product.dart';
import '../../../data/models/brand.dart';
import '../../../data/services/product_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../widgets/filter_panel.dart';
import '../../widgets/product_grid.dart';
import '../../widgets/search_bar.dart';

class MainPage extends StatefulWidget {
  final TextEditingController searchController;
  final Function(Product) onProductSelected;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final VoidCallback? onClearSearch;
  final Function(RangeValues, int?)? onApplyFilters;

  const MainPage({
    super.key,
    required this.searchController,
    required this.onProductSelected,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onClearSearch,
    this.onApplyFilters,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isFilterPanelVisible = false;

  final ProductService _productService = ProductService();
  List<Product> _products = [];
  List<Brand> _brands = [];
  bool _isLoading = true;
  double _maxPriceLimit = 1000;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _productService.fetchProducts(),
        _productService.getAllBrands(),
      ]);

      if (mounted) {
        final products = results[0] as List<Product>;
        
        double maxFound = 0;
        for (var p in products) {
          for (var v in p.variants) {
            if (v.price > maxFound) maxFound = v.price;
          }
        }

        setState(() {
          _products = products;
          _brands = results[1] as List<Brand>;
          _maxPriceLimit = maxFound > 0 ? maxFound : 1000;
          _isLoading = false;
        });
        logger.d("MainPage: Data loaded. Max price: $_maxPriceLimit");
      }
    } catch (e, stackTrace) {
      logger.e("MainPage: Error loading initial data", error: e, stackTrace: stackTrace);
      if (mounted) setState(() => _isLoading = false);
    }
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

  void _handleFilterApply(RangeValues range, int? brandId) {
    logger.i("MainPage: Applying global filters");
    _toggleFilterPanel();
    widget.onApplyFilters?.call(range, brandId);
  }

  @override
  Widget build(BuildContext context) {
    const double searchBarHeight = 50.0;

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
                    maxLimit: _maxPriceLimit,
                    onApply: _handleFilterApply,
                  ),
                ),
              ),
              CustomSearchBar(
                controller: widget.searchController,
                hintText: "search.main_hint".tr(),
                onSearchChanged: widget.onSearchChanged,
                onSearchSubmitted: widget.onSearchSubmitted,
                onClear: widget.onClearSearch,
                onFilterTap: _toggleFilterPanel,
              ),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : ProductGrid(
                    products: _products,
                    onProductSelected: widget.onProductSelected
                  ),
          ),
        ),
      ],
    );
  }
}