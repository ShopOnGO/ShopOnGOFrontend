// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/product.dart';
import '../../../data/providers/liked_provider.dart';
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

  String _searchQuery = '';
  bool _isFilterPanelVisible = false;

  RangeValues _priceRange = const RangeValues(0, 300);
  int? _selectedBrandId;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
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
    print("Search submitted on LikedPage: $_searchQuery");
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

    final filteredProducts = allLikedProducts.where((product) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = product.name.toLowerCase().contains(query);
        final brandMatch = product.brand.name.toLowerCase().contains(query);
        if (!nameMatch && !brandMatch) return false;
      }

      if (product.variants.isNotEmpty) {
        final price = product.variants.first.price;
        if (price < _priceRange.start || price > _priceRange.end) {
          return false;
        }
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
                  child: FilterPanel(onApply: _applyFilterAndClose),
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