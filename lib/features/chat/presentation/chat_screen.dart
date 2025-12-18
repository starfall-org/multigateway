import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../agents/presentation/agent_list_screen.dart';
import '../widgets/chat_drawer.dart';
import '../widgets/chat_input_area.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/models_drawer.dart';
import 'chat_viewmodel.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ChatViewModel();
    _viewModel.initChat();
    _viewModel.loadSelectedAgent();
    _viewModel.refreshProviders();
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
              icon: Icon(Icons.menu, color: Theme.of(context).iconTheme.color?.withOpacity(0.7)),
              onPressed: _viewModel.openDrawer,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'chat.title'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _viewModel.selectedAgent?.name ?? 'Default Agent',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              Expanded(
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: _buildMessageList(),
                ),
              ),
              if (_viewModel.isGenerating)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(),
                ),
              SafeArea(
                top: false,
                child: ChatInputArea(
                  controller: _viewModel.textController,
                  onSubmitted: (text) =>
                      _viewModel.handleSubmitted(text, context),
                  attachments: _viewModel.pendingAttachments,
                  onPickAttachments: () => _viewModel.pickAttachments(context),
                  onRemoveAttachment: _viewModel.removeAttachmentAt,
                  isGenerating: _viewModel.isGenerating,
                  onOpenModelPicker: () => _openModelPicker(context),
                  onMicTap: _viewModel.speakLastModelMessage,
                  onOpenMenu: _viewModel.openDrawer,
                ),
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
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Text(
            ((_viewModel.selectedAgent?.name.isNotEmpty == true
                    ? _viewModel.selectedAgent!.name[0]
                    : 'A'))
                .toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color?.withOpacity(0.7)),
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

  void _openModelPicker(BuildContext context) {
    ModelsDrawer.show(
      context,
      providers: _viewModel.providers,
      providerCollapsed: _viewModel.providerCollapsed,
      selectedProviderName: _viewModel.selectedProviderName,
      selectedModelName: _viewModel.selectedModelName,
      onToggleProvider: (providerName, collapsed) {
        _viewModel.setProviderCollapsed(providerName, collapsed);
      },
      onSelectModel: (providerName, modelName) {
        _viewModel.selectModel(providerName, modelName);
      },
    );
  }

  Widget _buildMessageList() {
    if (_viewModel.currentSession?.messages.isEmpty ?? true) {
      return Center(
        child: Text(
          'chat.start'.tr(),
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
        ),
      );
    }

    return ChatMessageList(
      messages: _viewModel.currentSession!.messages,
      scrollController: _viewModel.scrollController,
    );
  }
}
