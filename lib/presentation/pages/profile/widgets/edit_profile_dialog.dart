import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/auth_provider.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordSectionVisible = false;

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
      final oldPass = _oldPasswordController.text;
      final newPass = _newPasswordController.text;
      final confirmPass = _confirmPasswordController.text;

      if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
        _showError(messenger, theme, 'Заполните все поля пароля');
        return;
      }

      if (newPass != confirmPass) {
        _showError(messenger, theme, 'Новые пароли не совпадают');
        return;
      }
      
      if (newPass.length < 6) {
        _showError(messenger, theme, 'Пароль слишком короткий (минимум 6 символов)');
        return;
      }

      try {
        await authProvider.changePassword(oldPass, newPass, confirmPass);
        
        if (mounted) {
           _showSuccess(messenger, 'Пароль успешно изменен');
        }
      } catch (e) {
        String msg = e.toString().replaceAll('Exception: ', '');
        if (mounted) {
          _showError(messenger, theme, msg);
        }
        return;
      }
    }

    // TODO: Здесь будет вызов смены имени
    
    if (mounted) {
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Редактирование профиля',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
                          decoration: InputDecoration(
                            labelText: 'Имя',
                            hintText: 'Как к вам обращаться',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.person_outline),
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
                          secondChild: Column(
                            children: [
                              const SizedBox(height: 16),
                              TextField(
                                controller: _oldPasswordController,
                                obscureText: true,
                                enabled: !isLoading,
                                decoration: InputDecoration(
                                  labelText: 'Текущий пароль',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _newPasswordController,
                                obscureText: true,
                                enabled: !isLoading,
                                decoration: InputDecoration(
                                  labelText: 'Новый пароль',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.vpn_key_outlined),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _confirmPasswordController,
                                obscureText: true,
                                enabled: !isLoading,
                                decoration: InputDecoration(
                                  labelText: 'Повторите новый пароль',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.check_circle_outline),
                                ),
                              ),
                            ],
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
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: theme.colorScheme.onSurface,
                        ),
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