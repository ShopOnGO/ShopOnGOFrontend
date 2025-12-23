import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/chat_provider.dart';
import 'profile_action_button.dart';
import 'edit_profile_dialog.dart';
import '../add_product_dialog.dart';

class UserInfoCard extends StatelessWidget {
  final VoidCallback onLoginRequested;
  final VoidCallback onSettingsTap;

  const UserInfoCard({
    super.key,
    required this.onLoginRequested,
    required this.onSettingsTap,
  });

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          elevation: 24.0,
          title: Text('auth.logout_title'.tr()),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text('auth.logout_confirm'.tr())],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('auth.btn_cancel'.tr()),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('auth.btn_logout'.tr()),
              onPressed: () {
                context.read<ChatProvider>().disconnect();
                context.read<AuthProvider>().logout();
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (BuildContext context) => const EditProfileDialog(),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (BuildContext context) => const AddProductDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: authProvider.isAuthenticated
            ? _buildAuthenticatedView(context, theme, textTheme, authProvider)
            : _buildUnauthenticatedView(context, theme, textTheme),
      ),
    );
  }

  Widget _buildAuthenticatedView(
    BuildContext context,
    ThemeData theme,
    TextTheme textTheme,
    AuthProvider authProvider,
  ) {
    final user = authProvider.user!;
    final buttonStyle = IconButton.styleFrom(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(
        color: theme.colorScheme.outline.withValues(alpha: 0.5),
        width: 1.5,
      ),
      fixedSize: const Size(44, 44),
    );

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                width: 60,
                height: 60,
                color: theme.colorScheme.surfaceContainerHighest,
                child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                    ? Image.network(
                        user.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            const Icon(Icons.person_outline, size: 32),
                      )
                    : const Icon(Icons.person_outline, size: 32),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name ?? 'Имя', style: textTheme.headlineSmall),
                  Text(
                    user.email,
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showEditProfileDialog(context),
              style: buttonStyle,
              tooltip: 'profile.edit_title'.tr(),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutConfirmationDialog(context),
              style: buttonStyle,
              tooltip: 'auth.btn_logout'.tr(),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        if (user.role == 'seller') ...[
          Text(
            "profile.seller_panel".tr(),
            style: textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary, 
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 8),
          ProfileActionButton(
            text: "profile.add_product".tr(),
            trailing: Icon(Icons.add_box_outlined, color: theme.colorScheme.primary),
            onTap: () => _showAddProductDialog(context),
          ),
          const SizedBox(height: 12),
        ],

        ProfileActionButton(
          text: "profile.settings".tr(),
          onTap: onSettingsTap,
        ),
      ],
    );
  }

  Widget _buildUnauthenticatedView(
    BuildContext context,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'profile.unauth_msg'.tr(),
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onLoginRequested,
              child: Text('profile.btn_go_login'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}