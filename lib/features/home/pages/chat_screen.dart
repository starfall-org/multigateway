import 'package:flutter/material.dart';
import 'package:multigateway/app/storage/preferences_storage.dart';
import 'package:multigateway/core/chat/storage/conversation_storage.dart';
import 'package:multigateway/core/llm/storage/llm_provider_info_storage.dart';
import 'package:multigateway/core/llm/storage/llm_provider_models_storage.dart';
import 'package:multigateway/core/mcp/storage/mcp_server_info_storage.dart';
import 'package:multigateway/core/profile/storage/chat_profile_storage.dart';
import 'package:multigateway/core/speech/speech.dart';
import 'package:multigateway/features/home/controllers/chat_controller.dart';
import 'package:multigateway/features/home/controllers/chat_navigation_interface.dart';
import 'package:multigateway/features/home/ui/views/menu_view.dart';
import 'package:multigateway/features/home/ui/widgets/chat_messages_display.dart';
import 'package:multigateway/features/home/ui/widgets/chat_screen_widgets/agent_avatar_button.dart';
import 'package:multigateway/features/home/ui/widgets/conversations_drawer.dart';
import 'package:multigateway/features/home/ui/widgets/edit_message_sheet.dart';
import 'package:multigateway/features/home/ui/widgets/model_picker_sheet.dart';
import 'package:multigateway/features/home/ui/widgets/quick_actions_sheet.dart';
import 'package:multigateway/features/home/ui/widgets/user_input_area.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:multigateway/shared/widgets/empty_state.dart';

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
    // Call async initialization without blocking initState
    _initializeViewModel();
  }

  // Properly initialize async operations
  Future<void> _initializeViewModel() async {
    try {
      // Wait for all storage to initialize
      final preferencesSp = await PreferencesStorage.instance;
      final conversationRepository = ConversationStorage.instance;
      final aiProfileRepository = ChatProfileStorage.instance;
      final pInfStorage = LlmProviderInfoStorage.instance;
      final pModStorage = LlmProviderModelsStorage.instance;
      final mcpServerStorage = McpServerInfoStorage.instance;

      // Create SpeechManager instance
      final speechManager = SpeechManager(
        storage: SpeechServiceStorage.instance,
      );

      // Initialize controller
      _viewModel = ChatController(
        navigator: this,
        conversationRepository: conversationRepository,
        aiProfileRepository: aiProfileRepository,
        llmProviderInfoStorage: pInfStorage,
        llmProviderModelsStorage: pModStorage,
        preferencesSp: preferencesSp,
        mcpServerStorage: mcpServerStorage,
        speechManager: speechManager,
      );

      // Wait for all initialization to complete
      await _viewModel.initChat();
      await _viewModel.loadSelectedProfile();
      await _viewModel.refreshProviders();
    } catch (e) {
      // Ensure loading state is cleared even on error
      if (mounted) {
        showSnackBar('Error initializing chat: $e');
      }
    }

    // Không restore sidebar state - để sidebar đóng mỗi khi khởi động
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
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
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
            actions: [
              AgentAvatarButton(
                profileName: _viewModel.selectedProfile?.name,
                onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ],
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
            selectedProfile: _viewModel.selectedProfile,
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
                  child: (_viewModel.currentSession?.messages.isEmpty ?? true)
                      ? EmptyState(
                          icon: Icons.chat_bubble_outline,
                          message: 'Start a conversation!',
                        )
                      : ChatMessagesDisplay(
                          messages: _viewModel.currentSession!.messages,
                          scrollController: _viewModel.scrollController,
                          onCopy: (m) => _viewModel.copyMessage(context, m),
                          onEdit: (m) => _viewModel.openEditMessageDialog(context, m),
                          onDelete: (m) => _viewModel.deleteMessage(m),
                          onOpenAttachmentsSidebar: (files) {
                            _viewModel.openAttachmentsSidebar(files);
                            // TODO: Show attachment dialog
                          },
                          onRegenerate: () => _viewModel.regenerateLast(context),
                          onRead: (m) => _viewModel.speechManager.speak(m.content ?? ''),
                          onSwitchVersion: (m, idx) => _viewModel.switchMessageVersion(m, idx),
                        ),
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

  // Mở drawer chọn model AI
  void _openModelPicker(BuildContext context) {
    ModelPickerSheet.show(
      context,
      providers: _viewModel.providers,
      providerCollapsed: _viewModel.providerCollapsed,
      providerModels: _viewModel.modelSelectionController.providerModels,
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
}
