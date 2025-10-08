import 'package:flutter/material.dart';
import '../../widgets/product_grid.dart';
import '../../widgets/search_bar.dart';

class CatalogPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(45, 0, 45, 30),
          child: CustomSearchBar(
            controller: searchController,
            hintText: "Искать в каталоге...",
            onSearchChanged: onSearchChanged,
            onSearchSubmitted: onSearchSubmitted,
            onClear: onClearSearch,
            height: 50,
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderColor: Theme.of(context).scaffoldBackgroundColor,
            borderWidth: 6,
            borderRadius: 22,
          ),
        ),
        const Expanded(
          child: ProductGrid(maxCrossAxisExtent: 280),
        ),
      ],
    );
  }
}
