import 'package:flutter/material.dart';
import '../../../data/models/product.dart';
import '../../widgets/filter_panel.dart';
import '../../widgets/product_grid.dart';
import '../../widgets/search_bar.dart';

class CatalogPage extends StatefulWidget {
  final TextEditingController searchController;
  final Function(Product) onProductSelected;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final VoidCallback? onClearSearch;

  const CatalogPage({
    super.key,
    required this.searchController,
    required this.onProductSelected,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onClearSearch,
  });

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isFilterPanelVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  void _applyFilterAndClose() {
    _toggleFilterPanel();
  }

  @override
  Widget build(BuildContext context) {
    const double searchBarHeight = 50.0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
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
                controller: widget.searchController,
                hintText: "Искать в каталоге...",
                onSearchChanged: widget.onSearchChanged,
                onSearchSubmitted: widget.onSearchSubmitted,
                onClear: widget.onClearSearch,
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
                maxCrossAxisExtent: 280,
                onProductSelected: widget.onProductSelected,
              ),
            ),
          ),
        ),
      ],
    );
  }
}