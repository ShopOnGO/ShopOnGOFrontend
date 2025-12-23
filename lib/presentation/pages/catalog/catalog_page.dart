import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:easy_localization/easy_localization.dart';
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
    this.priceRange = const RangeValues(0, 10000), 
    this.selectedBrandId,
    this.onApplyFilters,
  });

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> with SingleTickerProviderStateMixin {
  final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true),
  );

  late AnimationController _animationController;
  bool _isFilterPanelVisible = false;

  final ProductService _productService = ProductService();
  
  List<Product> _allProducts = [];       
  List<Product> _filteredProducts = [];
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
    _logger.i('Catalog: Loading data...');
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
          _allProducts = products;
          _brands = results[1] as List<Brand>;
          _maxPriceLimit = maxFound > 0 ? maxFound : 1000;
          _isLoading = false;
        });
        _logger.i('Catalog: Data loaded. Max price limit set to: $_maxPriceLimit');
        _runFilter();
      }
    } catch (e, stackTrace) {
      _logger.e('Catalog: Failed to load data', error: e, stackTrace: stackTrace);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChangedLocal() {
    _runFilter();
    widget.onSearchChanged?.call(widget.searchController.text);
  }

  void _onApplyFiltersLocal(RangeValues range, int? brandId) {
    widget.onApplyFilters?.call(range, brandId);
    if (MediaQuery.of(context).size.width < 650) {
      Navigator.pop(context);
    } else {
      _toggleFilterPanel();
    }
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
          bool anyVariantInPriceRange = product.variants.any((v) => 
            v.price >= widget.priceRange.start && v.price <= widget.priceRange.end
          );
          if (!anyVariantInPriceRange) return false;
        }
        if (widget.selectedBrandId != null) {
          if (product.brand.id != widget.selectedBrandId) return false;
        }
        return true;
      }).toList();
    });
  }

  void _toggleFilterPanel() {
    final bool isMobile = MediaQuery.of(context).size.width < 650;

    if (isMobile) {
      _logger.i('Catalog: Opening mobile filter sheet');
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        builder: (context) => FilterPanel(
          brands: _brands,
          initialBrandId: widget.selectedBrandId,
          initialRange: widget.priceRange,
          maxLimit: _maxPriceLimit,
          onApply: _onApplyFiltersLocal,
          isMobile: true,
        ),
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

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 650;
    const double searchBarHeight = 50.0;
    final double horizontalPadding = isMobile ? 16.0 : 45.0;

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
                      initialBrandId: widget.selectedBrandId,
                      initialRange: widget.priceRange,
                      maxLimit: _maxPriceLimit,
                      onApply: _onApplyFiltersLocal,
                    ),
                  ),
                ),

              CustomSearchBar(
                controller: widget.searchController,
                hintText: "search.catalog_hint".tr(),
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
            padding: EdgeInsets.only(top: isMobile ? 15 : 30),
            child: _isLoading 
                ? Center(child: Text('catalog.loading'.tr()))
                : ProductGrid(
                    products: _filteredProducts,
                    maxCrossAxisExtent: isMobile ? 350 : 280,
                    onProductSelected: widget.onProductSelected,
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
                  ),
          ),
        ),
      ],
    );
  }
}