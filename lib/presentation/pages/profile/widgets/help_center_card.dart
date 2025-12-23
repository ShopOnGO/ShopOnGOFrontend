import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'profile_action_button.dart';

class HelpCenterCard extends StatelessWidget {
  final VoidCallback onFaqTap;

  const HelpCenterCard({super.key, required this.onFaqTap});

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
            Text("profile.help".tr(), style: textTheme.titleLarge),
            const SizedBox(height: 16),
            ProfileActionButton(
              text: "profile.faq".tr(),
              onTap: onFaqTap,
            ),
          ],
        ),
      ),
    );
  }
}