import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/chat_provider.dart';
import '../../../../data/providers/auth_provider.dart';
import 'chat_detail_view.dart';
import 'chat_fab.dart';

class ChatWindow extends StatefulWidget {
  final VoidCallback onClose;
  const ChatWindow({super.key, required this.onClose});

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final chat = context.read<ChatProvider>();
    if (!chat.isConnected && auth.isAuthenticated) {
      chat.connect(auth.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatProvider = context.watch<ChatProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Row(
      children: [
        Container(
          width: 280,
          color: theme.colorScheme.surface,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: widget.onClose,
                          child: ChatFab(state: chatProvider.hasUnreadMessages ? MailboxState.hasUnread : MailboxState.closed),
                        ),
                        const SizedBox(width: 10),
                        const Text('Чаты', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Spacer(),
                        _buildStatusIndicator(chatProvider.isConnected),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Manager Mode", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        Switch(
                          value: chatProvider.isManagerMode,
                          onChanged: (v) => chatProvider.setManagerMode(v, authProvider.token),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (chatProvider.isManagerMode) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _ManagerPanelButton(
                        text: "Обновить список",
                        icon: Icons.refresh,
                        onTap: () => chatProvider.sendCommand("list"),
                      ),
                      if (chatProvider.activeTargetUserId != null)
                        _ManagerPanelButton(
                          text: "Закрыть сессию",
                          icon: Icons.close,
                          isDanger: true,
                          onTap: () => chatProvider.sendCommand("close"),
                        ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 10),
                  child: Text("ОЖИДАЮТ ОТВЕТА", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.2)),
                ),
                Expanded(
                  child: chatProvider.waitingUsers.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text("Нет активных запросов", 
                              textAlign: TextAlign.center, 
                              style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ),
                        )
                      : ListView.builder(
                          itemCount: chatProvider.waitingUsers.length,
                          itemBuilder: (context, index) {
                            final userId = chatProvider.waitingUsers[index];
                            final isSelected = chatProvider.activeTargetUserId == userId;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: _ManagerPanelButton(
                                text: "Клиент #$userId",
                                icon: Icons.person_search,
                                isSelected: isSelected,
                                onTap: () => chatProvider.sendCommand("take", targetId: userId),
                              ),
                            );
                          },
                        ),
                ),
              ] else 
                const Expanded(child: Center(child: Text("Чат поддержки", style: TextStyle(color: Colors.grey)))),
            ],
          ),
        ),
        
        const Expanded(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Card(
              margin: EdgeInsets.zero,
              child: ChatDetailView(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(bool connected) {
    return Container(
      width: 10, height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: connected ? Colors.green : Colors.red,
        boxShadow: [BoxShadow(color: (connected ? Colors.green : Colors.red).withValues(alpha: 0.4), blurRadius: 6)],
      ),
    );
  }
}

class _ManagerPanelButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDanger;
  final bool isSelected;

  const _ManagerPanelButton({
    required this.text,
    required this.icon,
    required this.onTap,
    this.isDanger = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: isSelected ? 8 : 2,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected ? BorderSide(color: colorScheme.primary, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isDanger ? Colors.red : (isSelected ? colorScheme.primary : colorScheme.onSurface)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isDanger ? Colors.red : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}