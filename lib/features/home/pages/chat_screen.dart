import 'package:flutter/material.dart';
import 'package:multigateway/app/storage/preferences_storage.dart';
import 'package:multigateway/core/chat/storage/conversation_storage.dart';
import 'package:multigateway/core/llm/storage/llm_provider_info_storage.dart';
import 'package:multigateway/core/llm/storage/llm_provider_models_storage.dart';
import 'package:multigateway/core/mcp/storage/mcp_server_info_storage.dart';
import 'package:multigateway/core/profile/storage/chat_profile_storage.dart';
import 'package:multigateway/core/speech/speech.dart';
import 'package:multigateway/features/home/controllers/chat_controller.dart';
import 'package:multigateway/features/home/ui/views/menu_view.dart';
import 'package:multigateway/features/home/ui/widgets/chat_controller_provider.dart';
import 'package:multigateway/features/home/ui/widgets/chat_screen_widgets/chat_app_bar.dart';
import 'package:multigateway/features/home/ui/widgets/chat_screen_widgets/chat_body.dart';
import 'package:multigateway/features/home/ui/widgets/conversations_drawer.dart';
import 'package:multigateway/features/home/ui/widgets/edit_message_sheet.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';

/// Màn hình chat chính cho ứng dụng
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    implements ChatNavigationInterface {
  late ChatController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      final preferencesSp = await PreferencesStorage.instance;
      final conversationRepository = ConversationStorage.instance;
      final aiProfileRepository = ChatProfileStorage.instance;
      final pInfStorage = LlmProviderInfoStorage.instance;
      final pModStorage = LlmProviderModelsStorage.instance;
      final mcpServerStorage = McpServerInfoStorage.instance;

      final speechManager = SpeechManager(
        storage: SpeechServiceStorage.instance,
      );

      _controller = ChatController(
        navigator: this,
        conversationRepository: conversationRepository,
        aiProfileRepository: aiProfileRepository,
        llmProviderInfoStorage: pInfStorage,
        llmProviderModelsStorage: pModStorage,
        preferencesSp: preferencesSp,
        mcpServerStorage: mcpServerStorage,
        speechManager: speechManager,
      );

      await _controller.initChat();
      await _controller.loadSelectedProfile();
      await _controller.refreshProviders();
    } catch (e) {
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChatControllerProvider(
      controller: _controller,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            key: _scaffoldKey,
            appBar: ChatAppBar(
              onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
              onOpenEndDrawer: () =>
                  _scaffoldKey.currentState?.openEndDrawer(),
            ),
            drawer: ConversationsDrawer(
              onSessionSelected: (sessionId) {
                Navigator.pop(context);
                _controller.loadSession(sessionId);
              },
              onNewChat: () {
                Navigator.pop(context);
                _controller.createNewSession();
              },
              onAgentChanged: () {
                _controller.loadSelectedProfile();
              },
              selectedProviderName: _controller.selectedProviderName,
              selectedModelName: _controller.selectedModelName,
              selectedProfile: _controller.selectedProfile,
            ),
            endDrawer: const MenuView(),
            body: const ChatBody(),
          );
        },
      ),
    );
  }
}
