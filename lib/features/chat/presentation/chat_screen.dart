import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../ai_profiles/presentation/ai_profiles_screen.dart';
import '../widgets/chat_drawer.dart';
import '../widgets/menu_drawer.dart';
import '../widgets/chat_input_area.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/models_drawer.dart';
import '../widgets/edit_message_dialog.dart';
import '../viewmodel/chat_viewmodel.dart';
import '../viewmodel/chat_navigation_interface.dart';
import '../../../core/widgets/sidebar_right.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/di/app_services.dart';
import 'dart:io';

/// Màn hình chat chính cho ứng dụng
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> implements ChatNavigationInterface {
  late ChatViewModel _viewModel;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Khởi tạo viewModel và tải dữ liệu ban đầu
  @override
  void initState() {
    super.initState();
    final services = AppServices.instance;
    _viewModel = ChatViewModel(
      navigator: this,
      chatRepository: services.chatRepository,
      aiProfileRepository: services.aiProfileRepository,
      providerRepository: services.providerRepository,
      appPreferencesRepository: services.appPreferencesRepository,
      mcpRepository: services.mcpRepository,
      ttsService: services.ttsService,
    );
    _viewModel.initChat();
    _viewModel.loadSelectedProfile();
    _viewModel.refreshProviders();
  }

  @override
  void showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Future<({String content, List<String> attachments, bool resend})?> showEditMessageDialog({
    required String initialContent,
    required List<String> initialAttachments,
  }) async {
    if (!mounted) return null;
    final result = await EditMessageDialog.show(
      context,
      initialContent: initialContent,
      initialAttachments: initialAttachments,
    );
    if (result == null) return null;
    return (
      content: result.content,
      attachments: result.attachments,
      resend: result.resend,
    );
  }

  @override
  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  void openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  void closeEndDrawer() {
    _scaffoldKey.currentState?.closeEndDrawer();
  }

  @override
  String getTranslatedString(String key, {Map<String, String>? namedArgs}) {
    if (!mounted) return key;
    return key.tr(namedArgs: namedArgs);
  }

  // Dọn dẹp tài nguyên khi widget bị hủy
  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // Xây dựng giao diện chính của màn hình chat
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        // Hiển thị loading khi đang tải dữ liệu
        if (_viewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Giao diện chính của chat
        return Scaffold(
          key: _scaffoldKey,
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
                  _viewModel.selectedProfile?.name ?? 'Default',
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
            actions: [
              _buildToolsButton(),
              _buildAgentAvatar(),
              _buildPopupMenu(),
            ],
          ),
          // Drawer bên trái chứa danh sách cuộc trò chuyện
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
              _viewModel.loadSelectedProfile();
            },
          ),
          // Drawer bên phải hiển thị tệp đính kèm
          endDrawer: _buildEndDrawer(context),
          body: Column(
            children: [
              // Danh sách tin nhắn
              Expanded(
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: _buildMessageList(),
                ),
              ),
              // Thanh tiến trình khi AI đang tạo phản hồi
              if (_viewModel.isGenerating)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(),
                ),
              // Khu vực nhập liệu
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
                  onOpenMenu: () => MenuDrawer.showDrawer(context, _viewModel),
                  selectedAIModel: _viewModel.selectedAIModel,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Xây dựng avatar của agent được chọn trong thanh AppBar
  Widget _buildAgentAvatar() {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AIProfilesScreen()),
        );
        if (result == true) {
          _viewModel.loadSelectedProfile();
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
            ((_viewModel.selectedProfile?.name.isNotEmpty == true
                    ? _viewModel.selectedProfile!.name[0]
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

  // Xây dựng menu popup với các tùy chọn cho cuộc trò chuyện
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

  Widget _buildToolsButton() {
    return IconButton(
      icon: Icon(
        Icons.extension_outlined,
        color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
      ),
      tooltip: 'Tools',
      onPressed: () {
        MenuDrawer.showDrawer(context, _viewModel);
      },
    );
  }

  // Mở drawer chọn model AI
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

  // Xây dựng danh sách tin nhắn hoặc hiển thị trạng thái rỗng
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
      onOpenAttachmentsSidebar: (files) =>
          _viewModel.openAttachmentsSidebar(files),
      onRegenerate: () => _viewModel.regenerateLast(context),
    );
  }

  // Xây dựng drawer bên phải hiển thị danh sách tệp đính kèm
  Widget _buildEndDrawer(BuildContext context) {
    return AppSidebarRight(
      width: 320,
      child: SafeArea(
        child: Column(
          children: [
            // Header của drawer đính kèm
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
              child: Row(
                children: [
                  Text(
                    'attachments.title_count'.tr(
                      namedArgs: {
                        'count': _viewModel.inspectingAttachments.length
                            .toString(),
                      },
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'common.close'.tr(),
                    onPressed: _viewModel.closeEndDrawer,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Danh sách tệp đính kèm
            Expanded(
              child: _viewModel.inspectingAttachments.isEmpty
                  ? EmptyState(
                      icon: Icons.attach_file,
                      message: 'attachments.empty'.tr(),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _viewModel.inspectingAttachments.length,
                      separatorBuilder: (_, _) => const Divider(height: 12),
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

  // Xây dựng tile hiển thị thông tin tệp đính kèm
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
      // Hiển thị ảnh thumbnail cho tệp ảnh
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
      // Hiển thị icon mặc định cho tệp không phải ảnh
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

  // Icon mặc định cho các tệp không phải ảnh
  Widget _fallbackIcon(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.insert_drive_file,
        color: Theme.of(context).iconTheme.color,
      ),
    );
  }

  // Định dạng kích thước tệp từ bytes sang định dạng dễ đọc (KB, MB, GB...)
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

  // Kiểm tra xem đường dẫn tệp có phải là ảnh hay không
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
