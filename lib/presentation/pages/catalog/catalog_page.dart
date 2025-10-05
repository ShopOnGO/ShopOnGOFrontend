import 'package:flutter/material.dart';
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
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Каталог",
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                if (searchController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Результаты для: ${searchController.text}",
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
