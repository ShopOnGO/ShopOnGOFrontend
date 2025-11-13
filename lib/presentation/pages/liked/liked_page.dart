import 'package:flutter/material.dart';
import '../../../data/models/product.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/liked_provider.dart';
import '../../widgets/filter_panel.dart';
import '../../widgets/product_grid.dart';
import '../../widgets/search_bar.dart';

class LikedPage extends StatefulWidget {
  final TextEditingController searchController;
  final Function(Product) onProductSelected;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final VoidCallback? onClearSearch;

  const LikedPage({
    super.key,
    required this.searchController,
    required this.onProductSelected,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onClearSearch,
  });

  @override
  State<LikedPage> createState() => _LikedPageState();
}

class _LikedPageState extends State<LikedPage>
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

    final likedProvider = context.watch<LikedProvider>();
    final likedItems = likedProvider.likedItems
        .map((item) => item.product)
        .toList();

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
                hintText: "Искать в избранном...",
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
                products: likedItems,
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
