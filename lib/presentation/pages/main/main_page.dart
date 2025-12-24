import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../data/providers/product_provider.dart';
import '../../widgets/filter_panel.dart';
import '../../widgets/product_grid.dart';
import '../../widgets/search_bar.dart';
import '../../../data/models/product.dart';

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

class _MainPageState extends State<MainPage>
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          maxLimit: productProvider.maxPrice,
          onApply: _handleFilterApply,
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

  void _handleFilterApply(RangeValues range, int? brandId) {
    if (MediaQuery.of(context).size.width < 650) {
      Navigator.pop(context);
    } else {
      _toggleFilterPanel();
    }
    widget.onApplyFilters?.call(range, brandId);
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 650;
    const double searchBarHeight = 50.0;
    final double horizontalPadding = isMobile ? 16.0 : 45.0;

    final productProvider = context.watch<ProductProvider>();

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
                      maxLimit: productProvider.maxPrice,
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
            padding: EdgeInsets.only(top: isMobile ? 15 : 30),
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => productProvider.loadProducts(force: true),
                    child: ProductGrid(
                      products: productProvider.products,
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
