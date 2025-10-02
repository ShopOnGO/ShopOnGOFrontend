import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final VoidCallback? onClear;
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
    this.height = 120,
    required this.color,
    required this.borderColor,
    this.borderWidth = 6,
    this.borderRadius = 22,
    this.hasShadow = true,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _showClearButton = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final bool newShowClearButton = widget.controller.text.isNotEmpty;
    if (_showClearButton != newShowClearButton) {
      setState(() {
        _showClearButton = newShowClearButton;
      });
    }
    widget.onSearchChanged?.call(widget.controller.text);
  }

  void _performSearchSubmit() {
    FocusScope.of(context).unfocus();
    widget.onSearchSubmitted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final double innerBorderRadius =
        widget.borderRadius - (widget.borderWidth / 2);

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
        boxShadow: widget.hasShadow
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
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              onSubmitted: (_) => _performSearchSubmit(),
              style: AppTextStyles.topNavbarLabel.copyWith(
                color: AppColors.textLight,
              ),
              cursorColor: AppColors.textLight,
              decoration: InputDecoration(
                hintText: widget.hintText,
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
                  onPressed: _performSearchSubmit,
                ),
                suffixIcon: _showClearButton
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.textLight.withValues(alpha: 0.7),
                        ),
                        onPressed: () {
                          widget.controller.clear();
                          widget.onClear?.call();
                        },
                      )
                    : null,
              ),
            ),
          ),
          Container(
            width: widget.height * 2.6,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.borderColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(innerBorderRadius),
                bottomLeft: Radius.circular(innerBorderRadius),
              ),
              border: Border(
                top: BorderSide(
                  color: widget.borderColor,
                  width: widget.borderWidth,
                ),
                bottom: BorderSide(
                  color: widget.borderColor,
                  width: widget.borderWidth,
                ),
                left: BorderSide(
                  color: widget.borderColor,
                  width: widget.borderWidth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
