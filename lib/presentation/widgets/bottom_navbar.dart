import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/providers/auth_provider.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authProvider = context.watch<AuthProvider>();

    final Color activeColor = colorScheme.primary;
    final Color inactiveColor = colorScheme.secondaryContainer;
    final Color borderColor = theme.scaffoldBackgroundColor;
    final Color contentColor = colorScheme.onSecondaryContainer;

    final items = [
      {"icon": Icons.home_rounded, "label": "tabs.home".tr()},
      {"icon": Icons.grid_view_rounded, "label": "tabs.catalog".tr()},
      authProvider.isAuthenticated
          ? {"icon": Icons.person_rounded, "label": "tabs.profile".tr()}
          : {"icon": Icons.login_rounded, "label": "tabs.login".tr()},
      {"icon": Icons.star_rounded, "label": "tabs.favorites".tr()},
      {"icon": Icons.shopping_cart_rounded, "label": "tabs.cart".tr()},
    ];

    return Container(
      height: 95,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: inactiveColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 6),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final bool isActive = index == currentIndex;
            return Expanded(
              child: InkWell(
                onTap: () => onTabSelected(index),
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isActive ? activeColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[index]["icon"] as IconData,
                        color: isActive ? Colors.white : contentColor.withValues(alpha: 0.9),
                        size: 26,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index]["label"] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                          color: isActive ? Colors.white : contentColor.withValues(alpha: 0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}