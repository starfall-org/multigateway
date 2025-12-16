import 'package:ai_gateway/features/agents/views/agent_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ai_gateway/features/chat/views/chat_screen_viewmodel.dart';
import 'package:ai_gateway/features/chat/widgets/chat_drawer.dart';
import 'package:ai_gateway/features/chat/widgets/chat_input_area.dart';
import 'package:ai_gateway/features/chat/widgets/chat_message_list.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatScreenViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ChatScreenViewModel();
    _viewModel.initChat();
    _viewModel.loadSelectedAgent();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        if (_viewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          key: _viewModel.scaffoldKey,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.black54),
              onPressed: _viewModel.openDrawer,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'chat.title'.tr(),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _viewModel.selectedAgent?.name ?? 'Default Agent',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
            actions: [_buildAgentAvatar(), _buildPopupMenu()],
          ),
          drawer: ChatDrawer(
            onSessionSelected: (sessionId) {
              Navigator.pop(context);
              _viewModel.loadSession(sessionId);
            },
            onNewChat: () {
              Navigator.pop(context);
              _viewModel.createNewSession();
            },
            onAgentChanged: () {
              _viewModel.loadSelectedAgent();
            },
          ),
          body: Column(
            children: [
              Expanded(child: _buildMessageList()),
              if (_viewModel.isGenerating)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(),
                ),
              ChatInputArea(
                controller: _viewModel.textController,
                onSubmitted: (text) =>
                    _viewModel.handleSubmitted(text, context),
                attachments: _viewModel.pendingAttachments,
                onPickAttachments: () => _viewModel.pickAttachments(context),
                onRemoveAttachment: _viewModel.removeAttachmentAt,
                isGenerating: _viewModel.isGenerating,
                onMicTap: _viewModel.speakLastModelMessage,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAgentAvatar() {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AgentListScreen()),
        );
        if (result == true) {
          _viewModel.loadSelectedAgent();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: CircleAvatar(
          radius: 14,
          backgroundColor: Colors.blue.shade100,
          child: Text(
            ((_viewModel.selectedAgent?.name.isNotEmpty == true
                    ? _viewModel.selectedAgent!.name[0]
                    : 'A'))
                .toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black54),
      onSelected: (value) {
        switch (value) {
          case 'regen':
            _viewModel.regenerateLast(context);
            break;
          case 'clear':
            _viewModel.clearChat();
            break;
          case 'copy':
            _viewModel.copyTranscript(context);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'regen', child: Text('chat.regenerate'.tr())),
        PopupMenuItem(value: 'clear', child: Text('chat.clear'.tr())),
        PopupMenuItem(value: 'copy', child: Text('chat.copy'.tr())),
      ],
    );
  }

  Widget _buildMessageList() {
    if (_viewModel.currentSession?.messages.isEmpty ?? true) {
      return Center(
        child: Text(
          'chat.start'.tr(),
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ChatMessageList(
      messages: _viewModel.currentSession!.messages,
      scrollController: _viewModel.scrollController,
    );
  }
}
