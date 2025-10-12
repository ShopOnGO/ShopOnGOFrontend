import 'package:flutter/material.dart';
import 'profile_action_button.dart';

class HelpCenterCard extends StatelessWidget {
  const HelpCenterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Сервисы и помощи", style: textTheme.titleLarge),
            const SizedBox(height: 16),
            const ProfileActionButton(text: "ПОДДЕРЖКА"),
            const ProfileActionButton(text: "Частые вопросы"),
          ],
        ),
      ),
    );
  }
}
