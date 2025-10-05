import 'package:flutter/material.dart';
import '../../widgets/search_bar.dart';

class MainPage extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final VoidCallback? onClearSearch;

  const MainPage({
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
            hintText: "Искать товары...",
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
                  "Главная страница",
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
