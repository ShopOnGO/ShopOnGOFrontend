import 'package:flutter/material.dart';
import '../../widgets/filter_panel.dart';
import '../../widgets/product_grid.dart';
import '../../widgets/search_bar.dart';

class CatalogPage extends StatefulWidget {
  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final VoidCallback? onClearSearch;

  const CatalogPage({
    super.key,
    required this.searchController,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onClearSearch,
  });

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isFilterPanelVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
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

  @override
  Widget build(BuildContext context) {
    const double searchBarHeight = 50.0;
    const double topMargin = 30.0;

    return Stack(
      children: [
        GestureDetector(
          onTap: _isFilterPanelVisible ? _toggleFilterPanel : null,
          child: Padding(
            padding: const EdgeInsets.only(top: searchBarHeight + topMargin),
            child: const ProductGrid(maxCrossAxisExtent: 280),
          ),
        ),
        
        Positioned(
          top: (topMargin / 2) + (searchBarHeight - 22),
          left: 45,
          right: 45,
          child: ClipRect(
            child: FadeTransition(
              opacity: _animationController,
              child: SlideTransition(
                position: _slideAnimation,
                child: FilterPanel(
                  onApply: widget.onSearchSubmitted,
                ),
              ),
            ),
          ),
        ),

        Positioned(
          top: topMargin / 2,
          left: 45,
          right: 45,
          child: CustomSearchBar(
            controller: widget.searchController,
            hintText: "Искать в каталоге...",
            onSearchChanged: widget.onSearchChanged,
            onSearchSubmitted: widget.onSearchSubmitted,
            onClear: widget.onClearSearch,
            onFilterTap: _toggleFilterPanel,
            height: searchBarHeight,
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderColor: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
      ],
    );
  }
}