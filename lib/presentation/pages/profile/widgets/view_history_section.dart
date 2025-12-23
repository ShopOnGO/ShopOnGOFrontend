import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../data/providers/view_history_provider.dart';
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

    final historyProvider = context.watch<ViewHistoryProvider>();
    final viewedProducts = historyProvider.viewedProducts;

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
              "profile.history_title".tr(),
              style: textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),

          viewedProducts.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 48.0,
                    horizontal: 20.0,
                  ),
                  child: Center(
                    child: Text(
                      'profile.history_empty'.tr(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer
                            .withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                )
              : ProductGrid(
                  products: viewedProducts,
                  onProductSelected: onProductSelected,
                  isScrollable: false,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                ),
        ],
      ),
    );
  }
}