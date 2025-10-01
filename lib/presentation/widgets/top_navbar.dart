import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

class TopNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  final double itemWidth;
  final double overlap;
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
    this.itemWidth = 250,
    this.overlap = 30,
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

    return Padding(
      padding: margin,
      child: SizedBox(
        height: height,
        child: Center(
          child: SizedBox(
            width: items.length * itemWidth - (items.length - 1) * overlap,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ...List.generate(items.length, (index) {
                  if (index == currentIndex) return const SizedBox();
                  return _buildTab(index, items[index], false);
                }),
                _buildTab(currentIndex, items[currentIndex], true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, Map<String, dynamic> item, bool active) {
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item["icon"], color: AppColors.textLight, size: 20),
              const SizedBox(width: 6),
              Text(item["label"], style: AppTextStyles.topNavbarLabel),
            ],
          ),
        ),
      ),
    );
  }
}
