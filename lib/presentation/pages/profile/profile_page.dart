import 'package:flutter/material.dart';
import 'widgets/balance_card.dart';
import 'widgets/help_center_card.dart';
import 'widgets/user_info_card.dart';
import 'widgets/view_history_section.dart';
import '../../../data/models/product.dart';

class ProfilePage extends StatelessWidget {
  final Function(Product) onProductSelected;

  const ProfilePage({super.key, required this.onProductSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color panelColor = theme.colorScheme.secondaryContainer;
    final Color borderColor = theme.scaffoldBackgroundColor;
    const double borderWidth = 6.0;
    const double borderRadius = 22.0;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(borderWidth + 4),
                    decoration: BoxDecoration(
                      color: panelColor,
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(
                        color: borderColor,
                        width: borderWidth,
                      ),
                    ),
                    child: const UserInfoCard(),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(borderWidth + 4),
                    decoration: BoxDecoration(
                      color: panelColor,
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(
                        color: borderColor,
                        width: borderWidth,
                      ),
                    ),
                    child: Column(
                      children: const [
                        BalanceCard(),
                        SizedBox(height: 16),
                        HelpCenterCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ViewHistorySection(onProductSelected: onProductSelected),
          ],
        ),
      ),
    );
  }
}
