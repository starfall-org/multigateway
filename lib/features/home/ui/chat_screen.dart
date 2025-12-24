import 'package:flutter/material.dart';

import 'dart:io';

import '../../../core/config/services.dart';
import '../../../shared/translate/tl.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../controllers/chat_controller.dart';
import '../controllers/chat_controller_parts/chat_navigation_interface.dart';
import 'views/menu_view.dart';
import 'widgets/chat_messages_display.dart';
import 'widgets/conversations_drawer.dart';
import 'widgets/edit_message_sheet.dart';
import 'widgets/model_picker_sheet.dart';
import 'widgets/quick_actions_sheet.dart';
import 'widgets/user_input_area.dart';

/// Màn hình chat chính cho ứng dụng
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    implements ChatNavigationInterface {
  late ChatController _viewModel;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Khởi tạo viewModel và tải dữ liệu ban đầu
  @override
  void initState() {
    super.initState();
    final services = AppServices.instance;
    _viewModel = ChatController(
      navigator: this,
      chatRepository: services.chatRepository,
      aiProfileRepository: services.aiProfileRepository,
      providerRepository: services.providerRepository,
      preferencesSp: services.preferencesSp,
      mcpRepository: services.mcpRepository,
      ttsService: services.ttsService,
    );
    // Call async initialization without blocking initState
    _initializeViewModel();
  }

  // Properly initialize async operations
  Future<void> _initializeViewModel() async {
    try {
      // Wait for all initialization to complete
      await _viewModel.initChat();
      await _viewModel.loadSelectedProfile();
      await _viewModel.refreshProviders();
    } catch (e) {
      // Ensure loading state is cleared even on error
      _viewModel.clearLoadingState();
      if (mounted) {
        showSnackBar('Error initializing chat: $e');
      }
    }
  }

  @override
  void showSnackBar(String message) {
    if (!mounted) return;
    context.showInfoSnackBar(message);
  }

  @override
  Future<({String content, List<String> attachments, bool resend})?>
  showEditMessageDialog({
    required String initialContent,
    required List<String> initialAttachments,
  }) async {
    if (!mounted) return null;
    final result = await EditMessageSheet.show(
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
    return key;
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
                Icons.history,
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
                  _viewModel.currentSession?.title ?? 'New Chat',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _viewModel.selectedModelName ?? '',
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
            actions: [_buildAgentAvatar(context)],
          ),
          // Drawer bên trái chứa danh sách cuộc trò chuyện
          drawer: ConversationsDrawer(
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
            selectedProviderName: _viewModel.selectedProviderName,
            selectedModelName: _viewModel.selectedModelName,
          ),
          // Drawer bên phải hiển thị tệp đính kèm
          endDrawer: MenuView(),
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
                child: UserInputArea(
                  controller: _viewModel.textController,
                  onSubmitted: (text) =>
                      _viewModel.handleSubmitted(text, context),
                  attachments: _viewModel.pendingAttachments,
                  onPickAttachments: () => _viewModel.pickAttachments(context),
                  onPickFromGallery: () =>
                      _viewModel.pickAttachmentsFromGallery(context),
                  onRemoveAttachment: _viewModel.removeAttachmentAt,
                  isGenerating: _viewModel.isGenerating,
                  onOpenModelPicker: () => _openModelPicker(context),
                  onOpenMenu: () => QuickActionsSheet.show(context, _viewModel),
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
  Widget _buildAgentAvatar(BuildContext context) {
    return InkWell(
      onTap: () {
        Scaffold.of(context).openEndDrawer();
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

  // Mở drawer chọn model AI
  void _openModelPicker(BuildContext context) {
    ModelPickerSheet.show(
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
        message: 'Start a conversation!',
      );
    }

    return ChatMessagesDisplay(
      messages: _viewModel.currentSession!.messages,
      scrollController: _viewModel.scrollController,
      onCopy: (m) => _viewModel.copyMessage(context, m),
      onEdit: (m) => _viewModel.openEditMessageDialog(context, m),
      onDelete: (m) => _viewModel.deleteMessage(m),
      onOpenAttachmentsSidebar: (files) => {
        _viewModel.openAttachmentsSidebar(files),
        _buildAttachmentViewDialog(context),
      },
      onRegenerate: () => _viewModel.regenerateLast(context),
      onRead: (m) => _viewModel.ttsService.speak(m.content),
    );
  }

  // Xây dựng drawer bên phải hiển thị danh sách tệp đính kèm
  Widget _buildAttachmentViewDialog(BuildContext context) {
    return AppDialog(
      title: Text(tl('Attachments')),
      content: SafeArea(
        child: Column(
          children: [
            // Header của drawer đính kèm
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
              child: Row(
                children: [
                  Text(
                    tl(
                      'Attachments (${_viewModel.inspectingAttachments.length})',
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: tl('Close'),
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
                      message: 'No attachments',
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
