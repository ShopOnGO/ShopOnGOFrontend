import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../data/providers/chat_provider.dart';
import '../../../../core/utils/app_logger.dart';
import 'chat_message_bubble.dart';

class ChatDetailView extends StatefulWidget {
  final VoidCallback onClose;
  const ChatDetailView({super.key, required this.onClose});

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

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    logger.d('Chat Detail: User sending message: $text');
    
    context.read<ChatProvider>().sendMessage(text: text);
    _controller.clear();
  }

  Future<void> _handlePickFile() async {
    logger.d("Chat UI: Opening file picker...");
    
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (!mounted) return;

    if (result != null && result.files.first.bytes != null) {
      final file = result.files.first;
      
      logger.i("Chat UI: File selected: ${file.name}, size: ${file.size}");
      
      await context.read<ChatProvider>().uploadAndSendImage(
        file.bytes!, 
        file.name,
      );
    } else {
      logger.w("Chat UI: File picker cancelled or failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final theme = Theme.of(context);
    final bool isMobile = MediaQuery.of(context).size.width < 650;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    String title = "chat.support_name".tr();
    if (chatProvider.isManagerMode) {
      title = chatProvider.activeTargetUserId != null 
          ? "chat.chat_with_user".tr(args: [chatProvider.activeTargetUserId.toString()]) 
          : "chat.select_user_hint".tr();
    }

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 12, 
            vertical: isMobile ? 8 : 12
          ),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.dividerColor))),
          child: Row(
            children: [
              if (isMobile && chatProvider.isManagerMode && chatProvider.activeTargetUserId != null)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  onPressed: () {
                    logger.i('Chat UI: Manager returning to user list');
                    chatProvider.sendCommand("list", targetId: null);
                  },
                ),
              if (isMobile && chatProvider.isManagerMode && chatProvider.activeTargetUserId != null)
                const SizedBox(width: 8),
                
              CircleAvatar(
                radius: isMobile ? 14 : 20, 
                child: Icon(Icons.person, size: isMobile ? 16 : 24)
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: isMobile ? 14 : 16
                  ), 
                  overflow: TextOverflow.ellipsis
                )
              ),
              
              if (chatProvider.isUploading)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: SizedBox(
                    width: 16, 
                    height: 16, 
                    child: CircularProgressIndicator(strokeWidth: 2)
                  ),
                ),

              if (isMobile)
                IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  onPressed: widget.onClose,
                ),
            ],
          ),
        ),
        
        Expanded(
          child: chatProvider.messages.isEmpty
              ? Center(
                  child: Text(
                    "chat.no_messages".tr(), 
                    style: TextStyle(color: Colors.grey, fontSize: isMobile ? 12 : 14)
                  )
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(isMobile ? 10 : 16),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) => ChatMessageBubble(message: chatProvider.messages[index]),
                ),
        ),
        
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 4 : 8, 
            vertical: isMobile ? 4 : 8
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.image_outlined, size: isMobile ? 22 : 24),
                tooltip: "chat.send_image_tooltip".tr(),
                onPressed: chatProvider.isUploading ? null : _handlePickFile,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: !chatProvider.isManagerMode || (chatProvider.isManagerMode && chatProvider.activeTargetUserId != null),
                  style: TextStyle(fontSize: isMobile ? 14 : 16),
                  decoration: InputDecoration(
                    hintText: 'chat.hint'.tr(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16, 
                      vertical: isMobile ? 10 : 12
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.send, size: isMobile ? 22 : 24),
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