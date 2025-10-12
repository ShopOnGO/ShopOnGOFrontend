import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onFilterTap;
  final double height;
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
    this.borderWidth = 6,
    this.borderRadius = 22,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final inputTheme = theme.inputDecorationTheme;

    final Color containerColor = colorScheme.secondaryContainer;
    final Color borderColor = theme.scaffoldBackgroundColor;
    final Color iconColor = colorScheme.onSecondaryContainer;

    final ShapeBorder buttonVisualShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.horizontal(
        left: Radius.circular(borderRadius - borderWidth),
      ),
    );

    final ShapeBorder splashEffectShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius - borderWidth),
    );

    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: theme.shadowColor,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSearchSubmitted?.call(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: iconColor,
                  ),
              cursorColor: colorScheme.primary,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: inputTheme.hintStyle,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                prefixIcon: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: iconColor,
                    size: 24,
                  ),
                  onPressed: onSearchSubmitted,
                ),
              ),
            ),
          ),
          SizedBox(
            width: height * 1.5,
            child: Material(
              color: borderColor,
              shape: buttonVisualShape,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                customBorder: splashEffectShape,
                onTap: onFilterTap,
                child: Icon(Icons.filter_list_rounded, color: containerColor, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}