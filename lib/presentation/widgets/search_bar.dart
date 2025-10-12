import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onFilterTap;
  final double height;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final bool hasShadow;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.hintText = "Поиск...",
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onClear,
    this.onFilterTap,
    this.height = 50,
    required this.color,
    required this.borderColor,
    this.borderWidth = 6,
    this.borderRadius = 22,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: hasShadow
            ? [
                const BoxShadow(
                  color: AppColors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSearchSubmitted?.call(),
              style: AppTextStyles.topNavbarLabel.copyWith(
                color: AppColors.textLight,
              ),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTextStyles.topNavbarLabel.copyWith(
                  color: AppColors.textLight.withValues(alpha: 0.7),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                prefixIcon: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: AppColors.textLight,
                    size: 24,
                  ),
                  onPressed: onSearchSubmitted,
                ),
              ),
            ),
          ),
          SizedBox(
            width: height * 1.5,
            height: height,
            child: Material(
              color: borderColor,
              borderRadius: BorderRadius.circular(borderRadius - borderWidth),
              child: InkWell(
                onTap: onFilterTap,
                borderRadius: BorderRadius.circular(borderRadius - borderWidth),
                child: Icon(Icons.filter_list_rounded, color: color, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
