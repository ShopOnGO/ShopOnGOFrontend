import 'package:flutter/material.dart';
import '../../../widgets/product_grid.dart';
import '../../../../data/models/product.dart';

class ViewHistorySection extends StatelessWidget {
  final Function(Product) onProductSelected;

  const ViewHistorySection({super.key, required this.onProductSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final Color panelColor = theme.colorScheme.secondaryContainer;
    final Color borderColor = theme.scaffoldBackgroundColor;
    const double borderWidth = 6.0;
    const double borderRadius = 22.0;

    return Container(
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              "История просмотра товаров",
              style: textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),

          ProductGrid(
            onProductSelected: onProductSelected,
            isScrollable: false,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          ),
        ],
      ),
    );
  }
}
