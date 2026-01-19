import 'package:flutter/material.dart';
import 'package:multigateway/app/storage/preferences_storage.dart';
import 'package:multigateway/core/chat/storage/conversation_storage.dart';
import 'package:multigateway/core/llm/storage/llm_provider_info_storage.dart';
import 'package:multigateway/core/llm/storage/llm_provider_models_storage.dart';
import 'package:multigateway/core/mcp/storage/mcp_server_info_storage.dart';
import 'package:multigateway/core/profile/storage/chat_profile_storage.dart';
import 'package:multigateway/core/speech/speech.dart';
import 'package:multigateway/features/home/presentation/controllers/home_controller.dart';
import 'package:multigateway/features/home/presentation/ui/menu_view.dart';
import 'package:multigateway/features/home/presentation/widgets/chat_controller_provider.dart';
import 'package:multigateway/features/home/presentation/widgets/chat_screen_widgets/chat_app_bar.dart';
import 'package:multigateway/features/home/presentation/widgets/chat_screen_widgets/chat_body.dart';
import 'package:multigateway/features/home/presentation/widgets/conversations_drawer.dart';
import 'package:multigateway/features/home/presentation/widgets/edit_message_sheet.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    implements ChatNavigationInterface {
  ChatController? _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      final preferencesSp = await PreferencesStorage.instance;
      final conversationRepository = await ConversationStorage.instance;
      final chatProfileRepository = await ChatProfileStorage.instance;
      final pInfStorage = await LlmProviderInfoStorage.instance;
      final pModStorage = await LlmProviderModelsStorage.instance;
      final mcpStorage = await McpInfoStorage.instance;

      final speechManager = SpeechManager(
        storage: await SpeechServiceStorage.instance,
      );

      final continueLastConversation =
          preferencesSp.currentPreferences.continueLastConversation;

      _controller = ChatController(
        navigator: this,
        conversationRepository: conversationRepository,
        chatProfileRepository: chatProfileRepository,
        llmProviderInfoStorage: pInfStorage,
        llmProviderModelsStorage: pModStorage,
        preferencesSp: preferencesSp,
        mcpStorage: mcpStorage,
        speechManager: speechManager,
        continueLastConversation: continueLastConversation,
      );

      await _controller!.initChat();
      await _controller!.loadSelectedProfile();
      await _controller!.refreshProviders();

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        showSnackBar('Error initializing chat: $e');
        setState(() {});
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
  void openDrawer() => _scaffoldKey.currentState?.openDrawer();

  @override
  void openEndDrawer() => _scaffoldKey.currentState?.openEndDrawer();

  @override
  void closeEndDrawer() => _scaffoldKey.currentState?.closeEndDrawer();

  @override
  String getTranslatedString(String key, {Map<String, String>? namedArgs}) =>
      key;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _controller;
    if (ctrl == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ChatControllerProvider(
      controller: ctrl,
      child: Watch((context) {
        final isLoading = ctrl.session.isLoading.value;

        if (isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          appBar: ChatAppBar(
            onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
            onOpenEndDrawer: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          drawer: ConversationsDrawer(
            onSessionSelected: (sessionId) {
              Navigator.pop(context);
              ctrl.loadSession(sessionId);
            },
            onNewChat: () {
              Navigator.pop(context);
              ctrl.createNewSession();
            },
            onAgentChanged: () {
              ctrl.loadSelectedProfile();
            },
            selectedProviderName: ctrl.model.selectedProviderName.value,
            selectedModelName: ctrl.model.selectedModelName.value,
            selectedProfile: ctrl.profile.selectedProfile.value,
          ),
          endDrawer: const MenuView(),
          body: const ChatBody(),
        );
      }),
    );
  }
}
