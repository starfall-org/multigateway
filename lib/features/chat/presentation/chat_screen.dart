import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../agents/presentation/agent_list_screen.dart';
import '../widgets/chat_drawer.dart';
import '../widgets/chat_input_area.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/models_drawer.dart';
import 'chat_viewmodel.dart';
import '../../../core/widgets/sidebar_right.dart';
import '../../../core/widgets/empty_state.dart';
import 'dart:io';

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
              icon: Icon(
                Icons.menu,
                color: Theme.of(
                  context,
                ).iconTheme.color?.withValues(alpha: 0.7),
              ),
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
          endDrawer: _buildEndDrawer(context),
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
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.1),
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
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
      ),
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
      return EmptyState(
        icon: Icons.chat_bubble_outline,
        message: 'chat.start'.tr(),
      );
    }

    return ChatMessageList(
      messages: _viewModel.currentSession!.messages,
      scrollController: _viewModel.scrollController,
      onCopy: (m) => _viewModel.copyMessage(context, m),
      onEdit: (m) => _viewModel.openEditMessageDialog(context, m),
      onDelete: (m) => _viewModel.deleteMessage(m),
      onOpenAttachmentsSidebar: (files) => _viewModel.openAttachmentsSidebar(files),
      onRegenerate: () => _viewModel.regenerateLast(context),
    );
  }

  Widget _buildEndDrawer(BuildContext context) {
    return AppSidebarRight(
      width: 320,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
              child: Row(
                children: [
                  Text(
                    'attachments.title_count'.tr(
                      namedArgs: {
                        'count': _viewModel.inspectingAttachments.length.toString(),
                      },
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'settings.close'.tr(),
                    onPressed: _viewModel.closeEndDrawer,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // List
            Expanded(
              child: _viewModel.inspectingAttachments.isEmpty
                  ? EmptyState(
                      icon: Icons.attach_file,
                      message: 'attachments.empty'.tr(),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _viewModel.inspectingAttachments.length,
                      separatorBuilder: (_, __) => const Divider(height: 12),
                      itemBuilder: (ctx, i) {
                        final path = _viewModel.inspectingAttachments[i];
                        return _attachmentTile(context, path);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _attachmentTile(BuildContext context, String path) {
    final name = path.split('/').last;
    int sizeBytes = 0;
    try {
      sizeBytes = File(path).lengthSync();
    } catch (_) {}
    final sizeText = _formatBytes(sizeBytes);
    final isImg = _isImagePath(path);

    Widget leading;
    if (isImg) {
      leading = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          color: Theme.of(context).colorScheme.surface,
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => _fallbackIcon(context),
          ),
        ),
      );
    } else {
      leading = _fallbackIcon(context);
    }

    return ListTile(
      leading: leading,
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: sizeBytes > 0 ? Text(sizeText) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      onTap: () {
        // (Optional) Preview action can be added later
      },
    );
  }

  Widget _fallbackIcon(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.insert_drive_file, color: Theme.of(context).iconTheme.color),
    );
  }

  String _formatBytes(int bytes, [int decimals = 1]) {
    if (bytes <= 0) return '0 B';
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double v = bytes.toDouble();
    while (v >= 1024 && i < sizes.length - 1) {
      v /= 1024;
      i++;
    }
    return '${v.toStringAsFixed(decimals)} ${sizes[i]}';
  }

  bool _isImagePath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.bmp');
  }
}
