import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/auth_provider.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordSectionVisible = false;

  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    if (_isPasswordSectionVisible) {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      final oldPass = _oldPasswordController.text;
      final newPass = _newPasswordController.text;
      final confirmPass = _confirmPasswordController.text;

      try {
        await authProvider.changePassword(oldPass, newPass, confirmPass);
        
        if (mounted) {
           _showSuccess(messenger, 'Пароль успешно изменен');
           Navigator.of(context).pop();
        }
      } catch (e) {
        String msg = e.toString().replaceAll('Exception: ', '');
        if (mounted) {
          _showError(messenger, theme, msg);
        }
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showError(ScaffoldMessengerState messenger, ThemeData theme, String message) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration _buildDecoration({
    required String label,
    required IconData icon,
    required BuildContext context,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(12);

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Stack(
              children: [
                Card(
                  elevation: 24.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Редактирование профиля',
                          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        
                        Text(
                          "Личные данные",
                          style: textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameController,
                          enabled: !isLoading,
                          decoration: _buildDecoration(
                            label: 'Имя',
                            icon: Icons.person_outline,
                            context: context,
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isPasswordSectionVisible = !_isPasswordSectionVisible;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Row(
                            children: [
                              Text(
                                "Смена пароля",
                                style: textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                _isPasswordSectionVisible 
                                  ? Icons.keyboard_arrow_up 
                                  : Icons.keyboard_arrow_down,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                        
                        AnimatedCrossFade(
                          firstChild: Container(),
                          secondChild: Form(
                            key: _formKey,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                
                                TextFormField(
                                  controller: _oldPasswordController,
                                  obscureText: !_showOldPassword,
                                  enabled: !isLoading,
                                  decoration: _buildDecoration(
                                    label: 'Текущий пароль',
                                    icon: Icons.lock_outline,
                                    context: context,
                                    suffixIcon: IconButton(
                                      icon: Icon(_showOldPassword ? Icons.visibility : Icons.visibility_off),
                                      onPressed: () => setState(() => _showOldPassword = !_showOldPassword),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Введите текущий пароль';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                
                                TextFormField(
                                  controller: _newPasswordController,
                                  obscureText: !_showNewPassword,
                                  enabled: !isLoading,
                                  decoration: _buildDecoration(
                                    label: 'Новый пароль',
                                    icon: Icons.vpn_key_outlined,
                                    context: context,
                                    suffixIcon: IconButton(
                                      icon: Icon(_showNewPassword ? Icons.visibility : Icons.visibility_off),
                                      onPressed: () => setState(() => _showNewPassword = !_showNewPassword),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Придумайте новый пароль';
                                    if (value.length < 6) return 'Пароль слишком короткий (минимум 6 символов)';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: !_showConfirmPassword,
                                  enabled: !isLoading,
                                  decoration: _buildDecoration(
                                    label: 'Повторите новый пароль',
                                    icon: Icons.check_circle_outline,
                                    context: context,
                                    suffixIcon: IconButton(
                                      icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                                      onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Повторите пароль';
                                    if (value != _newPasswordController.text) return 'Пароли не совпадают';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          crossFadeState: _isPasswordSectionVisible
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 300),
                        ),

                        const SizedBox(height: 40),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("Отмена"),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isLoading ? null : () => _submit(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLoading 
                                  ? const SizedBox(
                                      height: 20, 
                                      width: 20, 
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                                    ) 
                                  : const Text("Сохранить"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                if (!isLoading)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.surface,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)
                          ],
                        ),
                        child: Icon(Icons.close, size: 20, color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}