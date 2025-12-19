import 'package:flutter/material.dart';

class NotificationHelper {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    Color? backgroundColor,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    final Color finalBackgroundColor =
        backgroundColor ??
        (isError ? theme.colorScheme.error : Colors.green.shade600);
    final IconData finalIcon =
        icon ??
        (isError
            ? Icons.warning_amber_rounded
            : Icons.check_circle_outline_rounded);

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: finalBackgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(finalIcon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
