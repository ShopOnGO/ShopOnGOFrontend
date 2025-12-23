import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/providers/auth_provider.dart';

class TopNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  final double height;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsets margin;

  const TopNavbar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.height = 40,
    this.borderWidth = 6,
    this.borderRadius = 22,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authProvider = context.watch<AuthProvider>();

    final Color activeColor = colorScheme.primary;
    final Color inactiveColor = colorScheme.secondaryContainer;
    final Color borderColor = theme.scaffoldBackgroundColor;
    final Color iconAndTextColor = colorScheme.onSecondaryContainer;

    final items = [
      {"icon": Icons.home, "label": "tabs.home".tr()},
      {"icon": Icons.list, "label": "tabs.catalog".tr()},
      authProvider.isAuthenticated
          ? {"icon": Icons.person, "label": "tabs.profile".tr()}
          : {"icon": Icons.login, "label": "tabs.login".tr()},
      {"icon": Icons.star, "label": "tabs.favorites".tr()},
      {"icon": Icons.shopping_cart, "label": "tabs.cart".tr()},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth - margin.horizontal;
        double baseItemWidth = availableWidth / items.length;

        const double minContentWidth = 30;
        final double maxContentWidth = baseItemWidth;

        double calculatedItemWidth;
        double calculatedOverlap;

        if (baseItemWidth < minContentWidth) {
          calculatedItemWidth = minContentWidth;
          calculatedOverlap =
              (items.length * calculatedItemWidth - availableWidth) /
              (items.length - 1);
          if (calculatedOverlap < 0) calculatedOverlap = 0;
        } else {
          calculatedItemWidth = baseItemWidth * 1.1;
          calculatedOverlap = baseItemWidth * 0.1;
        }
        calculatedItemWidth = calculatedItemWidth.clamp(
          minContentWidth,
          maxContentWidth,
        );
        double totalNavbarWidth =
            items.length * calculatedItemWidth -
            (items.length - 1) * calculatedOverlap;
        totalNavbarWidth = totalNavbarWidth.clamp(0, availableWidth);
        
        return Padding(
          padding: margin,
          child: SizedBox(
            height: height,
            child: Center(
              child: SizedBox(
                width: totalNavbarWidth,
                height: height,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ...List.generate(items.length, (index) {
                      if (index == currentIndex) return const SizedBox();
                      return _buildTab(
                        context,
                        index,
                        items[index],
                        false,
                        calculatedItemWidth,
                        calculatedOverlap,
                        inactiveColor,
                        borderColor,
                        iconAndTextColor,
                      );
                    }),
                    _buildTab(
                      context,
                      currentIndex,
                      items[currentIndex],
                      true,
                      calculatedItemWidth,
                      calculatedOverlap,
                      activeColor,
                      borderColor,
                      iconAndTextColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab(
    BuildContext context,
    int index,
    Map<String, dynamic> item,
    bool active,
    double itemWidth,
    double overlap,
    Color backgroundColor,
    Color borderColor,
    Color contentColor,
  ) {
    final theme = Theme.of(context);

    return Positioned(
      left: index * itemWidth - index * overlap,
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: height,
          width: itemWidth,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item["icon"], color: contentColor, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    item["label"],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: contentColor,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}