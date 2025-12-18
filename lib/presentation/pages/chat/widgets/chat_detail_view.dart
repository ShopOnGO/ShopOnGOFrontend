import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../data/providers/chat_provider.dart';
import 'chat_message_bubble.dart';

class ChatDetailView extends StatefulWidget {
  const ChatDetailView({super.key});

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatProvider>().sendMessage(text: text);
    _controller.clear();
    _scrollToBottom();
  }

  Future<void> _handlePickFile() async {
    print(">>> [UI] Opening file picker...");
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (!mounted) return;

    if (result != null && result.files.first.bytes != null) {
      final file = result.files.first;
      print(">>> [UI] File selected: ${file.name}, size: ${file.size}");
      
      await context.read<ChatProvider>().uploadAndSendImage(
        file.bytes!, 
        file.name,
      );
      _scrollToBottom();
    } else {
      print(">>> [UI] File picker cancelled or failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final theme = Theme.of(context);

    if (chatProvider.messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }

    String title = "Поддержка Tailornado";
    if (chatProvider.isManagerMode) {
      title = chatProvider.activeTargetUserId != null 
          ? "Чат с пользователем #${chatProvider.activeTargetUserId}" 
          : "Выберите пользователя слева";
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.dividerColor))),
          child: Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              if (chatProvider.isUploading)
                const SizedBox(
                  width: 20, 
                  height: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2)
                ),
            ],
          ),
        ),

        Expanded(
          child: chatProvider.messages.isEmpty
              ? const Center(child: Text("Сообщений нет", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) => ChatMessageBubble(message: chatProvider.messages[index]),
                ),
        ),

        Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image_outlined),
                tooltip: "Отправить изображение",
                onPressed: chatProvider.isUploading ? null : _handlePickFile,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: !chatProvider.isManagerMode || (chatProvider.isManagerMode && chatProvider.activeTargetUserId != null),
                  decoration: InputDecoration(
                    hintText: 'Введите сообщение...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _handleSend,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}