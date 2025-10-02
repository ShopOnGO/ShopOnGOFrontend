import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

class TopNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  final double height;
  final Color color;
  final Color activeColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsets margin;

  const TopNavbar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.height = 40,
    required this.color,
    required this.activeColor,
    required this.borderColor,
    this.borderWidth = 6,
    this.borderRadius = 22,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {"icon": Icons.home, "label": "Главная"},
      {"icon": Icons.list, "label": "Каталог"},
      {"icon": Icons.person, "label": "Личный кабинет"},
      {"icon": Icons.star, "label": "Избранное"},
      {"icon": Icons.shopping_cart, "label": "Корзина"},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth - margin.horizontal;
        double baseItemWidth = availableWidth / items.length;

        final double minContentWidth = 30;
        final double maxContentWidth = baseItemWidth;

        double calculatedItemWidth;
        double calculatedOverlap;

        if (baseItemWidth < minContentWidth) {
          calculatedItemWidth = minContentWidth;
          calculatedOverlap = (items.length * calculatedItemWidth - availableWidth) / (items.length - 1);
          if (calculatedOverlap < 0) calculatedOverlap = 0;
        } else {
          calculatedItemWidth = baseItemWidth * 1.1;
          calculatedOverlap = baseItemWidth * 0.1;
        }
        calculatedItemWidth = calculatedItemWidth.clamp(minContentWidth, maxContentWidth);
        double totalNavbarWidth = items.length * calculatedItemWidth - (items.length - 1) * calculatedOverlap;
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
                      return _buildTab(index, items[index], false, calculatedItemWidth, calculatedOverlap);
                    }),
                    _buildTab(currentIndex, items[currentIndex], true, calculatedItemWidth, calculatedOverlap),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab(int index, Map<String, dynamic> item, bool active, double itemWidth, double overlap) {
    return Positioned(
      left: index * itemWidth - index * overlap,
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: height,
          width: itemWidth,
          decoration: BoxDecoration(
            color: active ? activeColor : color,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.black26,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item["icon"], color: AppColors.textLight, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    item["label"],
                    style: AppTextStyles.topNavbarLabel.copyWith(fontSize: 14),
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