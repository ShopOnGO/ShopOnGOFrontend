import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../data/models/product.dart';
import '../../../data/providers/product_provider.dart';
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

class _CatalogPageState extends State<CatalogPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isFilterPanelVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    widget.searchController.addListener(_onSearchListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  void _onSearchListener() {
    setState(() {});
    widget.onSearchChanged?.call(widget.searchController.text);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchListener);
    _animationController.dispose();
    super.dispose();
  }

  void _onApplyFiltersLocal(RangeValues range, int? brandId) {
    widget.onApplyFilters?.call(range, brandId);
    if (MediaQuery.of(context).size.width < 650) {
      Navigator.pop(context);
    } else {
      _toggleFilterPanel();
    }
  }

  void _toggleFilterPanel() {
    final bool isMobile = MediaQuery.of(context).size.width < 650;
    final productProvider = context.read<ProductProvider>();

    if (isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        builder: (context) => FilterPanel(
          brands: productProvider.brands,
          initialBrandId: widget.selectedBrandId,
          initialRange: widget.priceRange,
          maxLimit: productProvider.maxPrice,
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

    final productProvider = context.watch<ProductProvider>();

    final queryLower = widget.searchController.text.toLowerCase().trim();
    final filteredProducts = productProvider.products.where((product) {
      if (queryLower.isNotEmpty) {
        final nameMatches = product.name.toLowerCase().contains(queryLower);
        final brandMatches = product.brand.name.toLowerCase().contains(
          queryLower,
        );
        if (!nameMatches && !brandMatches) return false;
      }
      bool anyVariantInPriceRange = product.variants.any(
        (v) =>
            v.price >= widget.priceRange.start &&
            v.price <= widget.priceRange.end,
      );
      if (!anyVariantInPriceRange) return false;

      if (widget.selectedBrandId != null &&
          product.brand.id != widget.selectedBrandId) {
        return false;
      }
      return true;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            5,
            horizontalPadding,
            0,
          ),
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
                      brands: productProvider.brands,
                      initialBrandId: widget.selectedBrandId,
                      initialRange: widget.priceRange,
                      maxLimit: productProvider.maxPrice,
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
            child: productProvider.isLoading
                ? Center(child: Text('catalog.loading'.tr()))
                : RefreshIndicator(
                    onRefresh: () => productProvider.loadProducts(force: true),
                    child: ProductGrid(
                      products: filteredProducts,
                      maxCrossAxisExtent: isMobile ? 350 : 280,
                      onProductSelected: widget.onProductSelected,
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 20,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
