import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import 'widgets/balance_card.dart';
import 'widgets/help_center_card.dart';
import 'widgets/user_info_card.dart';
import 'widgets/view_history_section.dart';
import '../../../data/models/product.dart';

class ProfilePage extends StatelessWidget {
  final Function(Product) onProductSelected;
  final VoidCallback onLoginRequested;
  final VoidCallback onSettingsRequested;
  final VoidCallback onFaqRequested;

  const ProfilePage({
    super.key,
    required this.onProductSelected,
    required this.onLoginRequested,
    required this.onSettingsRequested,
    required this.onFaqRequested,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final bool isMobile = MediaQuery.of(context).size.width < 650;

    final Color panelColor = theme.colorScheme.secondaryContainer;
    final Color borderColor = theme.scaffoldBackgroundColor;
    const double borderWidth = 6.0;
    const double borderRadius = 22.0;

    Widget userInfoSection = Container(
      padding: const EdgeInsets.all(borderWidth + 4),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: UserInfoCard(
        onLoginRequested: onLoginRequested,
        onSettingsTap: onSettingsRequested,
      ),
    );

    Widget supportSection = Container(
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
        children: [
          if (authProvider.isAuthenticated) ...[
            const BalanceCard(),
            const SizedBox(height: 16),
          ],
          HelpCenterCard(onFaqTap: onFaqRequested),
        ],
      ),
    );

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMobile)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: userInfoSection,
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 4,
                    child: supportSection,
                  ),
                ],
              )
            else
              Column(
                children: [
                  userInfoSection,
                  const SizedBox(height: 16),
                  supportSection,
                ],
              ),
            const SizedBox(height: 32),
            ViewHistorySection(onProductSelected: onProductSelected),
            if (isMobile) const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }
}