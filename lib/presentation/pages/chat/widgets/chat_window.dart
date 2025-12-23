import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
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
    final bool isMobile = MediaQuery.of(context).size.width < 650;

    Widget sidebar = Container(
      width: isMobile ? double.infinity : 280,
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
                    Text('chat.title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    _buildStatusIndicator(chatProvider.isConnected),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("chat.manager_mode".tr(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
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
              child: _ManagerPanelButton(
                text: "chat.refresh_list".tr(),
                icon: Icons.refresh,
                onTap: () => chatProvider.sendCommand("list"),
              ),
            ),
            const SizedBox(height: 10),
            Text("chat.waiting_response".tr(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.2)),
            Expanded(
              child: chatProvider.waitingUsers.isEmpty
                  ? Center(child: Text("chat.no_active_requests".tr(), style: const TextStyle(color: Colors.grey, fontSize: 12)))
                  : ListView.builder(
                      itemCount: chatProvider.waitingUsers.length,
                      itemBuilder: (context, index) {
                        final userId = chatProvider.waitingUsers[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: _ManagerPanelButton(
                            text: "chat.client_label".tr(args: [userId.toString()]),
                            icon: Icons.person_search,
                            isSelected: chatProvider.activeTargetUserId == userId,
                            onTap: () => chatProvider.sendCommand("take", targetId: userId),
                          ),
                        );
                      },
                    ),
            ),
          ] else 
            Expanded(child: Center(child: Text("chat.support_name".tr(), style: const TextStyle(color: Colors.grey)))),
        ],
      ),
    );

    Widget detailView = isMobile 
      ? Expanded(child: ChatDetailView(onClose: widget.onClose))
      : Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(margin: EdgeInsets.zero, child: ChatDetailView(onClose: widget.onClose)),
          ),
        );

    if (!isMobile) {
      return Row(children: [sidebar, detailView]);
    } else {
      return Column(
        children: [
          if (chatProvider.isManagerMode && chatProvider.activeTargetUserId == null)
            Expanded(child: sidebar)
          else
            detailView,
        ],
      );
    }
  }

  Widget _buildStatusIndicator(bool connected) {
    return Container(
      width: 10, height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: connected ? Colors.green : Colors.red,
      ),
    );
  }
}

class _ManagerPanelButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  const _ManagerPanelButton({
    required this.text,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected ? BorderSide(color: theme.colorScheme.primary, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isSelected ? theme.colorScheme.primary : null),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : null))),
            ],
          ),
        ),
      ),
    );
  }
}