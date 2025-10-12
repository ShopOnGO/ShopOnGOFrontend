import 'package:flutter/material.dart';
import 'profile_action_button.dart';

class UserInfoCard extends StatelessWidget {
  const UserInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text("ИМЯ....", style: textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 20),
            const ProfileActionButton(text: "Способы оплаты..."),
            const ProfileActionButton(text: "Настройки"),
            ProfileActionButton(
              text: "Ваши устройства",
              trailing: _buildProBadge(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProBadge(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "Pro",
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
