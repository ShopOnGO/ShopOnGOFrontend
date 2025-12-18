import 'package:flutter/material.dart';
import '../../../data/models/product.dart';
import '../../../data/models/brand.dart';
import '../../../data/services/product_service.dart';
import '../../widgets/filter_panel.dart';
import '../../widgets/product_grid.dart';
import '../../widgets/search_bar.dart';

class CatalogPage extends StatefulWidget {
  final TextEditingController searchController;
  final Function(Product) onProductSelected;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final VoidCallback? onClearSearch;
  
  final RangeValues priceRange;
  final int? selectedBrandId;
  final Function(RangeValues, int?)? onApplyFilters;

  const CatalogPage({
    super.key,
    required this.searchController,
    required this.onProductSelected,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onClearSearch,
    this.priceRange = const RangeValues(0, 300),
    this.selectedBrandId,
    this.onApplyFilters,
  });

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isFilterPanelVisible = false;

  final ProductService _productService = ProductService();
  
  List<Product> _allProducts = [];       
  List<Product> _filteredProducts = [];
  List<Brand> _brands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    widget.searchController.addListener(_onSearchChangedLocal);
    _loadData();
  }

  @override
  void didUpdateWidget(CatalogPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.priceRange != widget.priceRange || 
        oldWidget.selectedBrandId != widget.selectedBrandId) {
      _runFilter();
    }
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChangedLocal);
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
        setState(() {
          _allProducts = results[0] as List<Product>;
          _brands = results[1] as List<Brand>;
          _isLoading = false;
        });
        _runFilter();
      }
    } catch (e) {
      debugPrint("Error loading catalog: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChangedLocal() {
    _runFilter();
    widget.onSearchChanged?.call(widget.searchController.text);
  }

  void _onApplyFiltersLocal(RangeValues range, int? brandId) {
    widget.onApplyFilters?.call(range, brandId);
    _toggleFilterPanel();
  }

  void _runFilter() {
    if (_allProducts.isEmpty) return;

    final queryLower = widget.searchController.text.toLowerCase().trim();

    setState(() {
      _filteredProducts = _allProducts.where((product) {
        if (queryLower.isNotEmpty) {
          final nameMatches = product.name.toLowerCase().contains(queryLower);
          final brandMatches = product.brand.name.toLowerCase().contains(queryLower);
          if (!nameMatches && !brandMatches) return false;
        }

        if (product.variants.isNotEmpty) {
          final price = product.variants.first.price;
          if (price < widget.priceRange.start || price > widget.priceRange.end) {
            return false;
          }
        }

        if (widget.selectedBrandId != null) {
          if (product.brand.id != widget.selectedBrandId) {
            return false;
          }
        }

        return true;
      }).toList();
    });
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
                    initialBrandId: widget.selectedBrandId,
                    initialRange: widget.priceRange,
                    onApply: _onApplyFiltersLocal,
                  ),
                ),
              ),

              CustomSearchBar(
                controller: widget.searchController,
                hintText: "Искать в каталоге...",
                onSearchChanged: null,
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
                    products: _filteredProducts,
                    maxCrossAxisExtent: 280,
                    onProductSelected: widget.onProductSelected,
                  ),
          ),
        ),
      ],
    );
  }
}