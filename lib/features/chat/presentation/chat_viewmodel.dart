import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/models/agent.dart';
import '../../../core/models/chat/chat_message.dart';
import '../../../core/repositories/chat_service.dart';
import '../../../core/models/chat/conversation.dart';
import '../../../core/storage/agent_repository.dart';
import '../../../core/storage/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ChatRepository? _chatRepository;
  Conversation? _currentSession;
  AgentRepository? _agentRepository;
  Agent? _selectedAgent;
  bool _isLoading = true;
  bool _isGenerating = false;

  final List<String> _pendingAttachments = [];

  FlutterTts? _tts;

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;
  TextEditingController get textController => _textController;
  ScrollController get scrollController => _scrollController;
  Conversation? get currentSession => _currentSession;
  Agent? get selectedAgent => _selectedAgent;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  List<String> get pendingAttachments => _pendingAttachments;

  Future<void> initChat() async {
    _chatRepository = await ChatRepository.init();
    final sessions = _chatRepository!.getConversations();

    if (sessions.isNotEmpty) {
      _currentSession = sessions.first;
      _isLoading = false;
    } else {
      await createNewSession();
    }
    notifyListeners();
  }

  Future<void> loadSelectedAgent() async {
    _agentRepository ??= await AgentRepository.init();
    final agent = await _agentRepository!.getOrInitSelectedAgent();
    _selectedAgent = agent;
    notifyListeners();
  }

  Future<void> createNewSession() async {
    final session = await _chatRepository!.createConversation();
    _currentSession = session;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadSession(String sessionId) async {
    _isLoading = true;
    notifyListeners();

    final sessions = _chatRepository!.getConversations();
    final session = sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => sessions.first,
    );

    _currentSession = session;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> handleSubmitted(String text, BuildContext context) async {
    if (((text.trim().isEmpty) && _pendingAttachments.isEmpty) ||
        _currentSession == null) {
      return;
    }

    final List<String> attachments = List<String>.from(_pendingAttachments);
    _textController.clear();

    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.user,
      content: text,
      timestamp: DateTime.now(),
      attachments: attachments,
    );

    _currentSession = _currentSession!.copyWith(
      messages: [..._currentSession!.messages, userMessage],
      updatedAt: DateTime.now(),
    );
    _isGenerating = true;
    _pendingAttachments.clear();
    notifyListeners();

    if (_currentSession!.messages.length == 1) {
      final base = text.isNotEmpty
          ? text
          : (attachments.isNotEmpty
                ? 'attachments.title_count'.tr(
                    namedArgs: {'count': attachments.length.toString()},
                  )
                : 'drawer.new_chat'.tr());
      final title = base.length > 30 ? '${base.substring(0, 30)}...' : base;
      _currentSession = _currentSession!.copyWith(title: title);
    }

    await _chatRepository!.saveConversation(_currentSession!);
    scrollToBottom();

    String modelInput = text;
    if (attachments.isNotEmpty) {
      final names = attachments.map((p) => p.split('/').last).join(', ');
      modelInput =
          '${modelInput.isEmpty ? '' : '$modelInput\n'}[Attachments: $names]';
    }

    final reply = await ChatService.generateReply(
      userText: modelInput,
      history: _currentSession!.messages,
      agent:
          _selectedAgent ??
          Agent(id: const Uuid().v4(), name: 'Default Agent', systemPrompt: ''),
    );

    final modelMessage = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.model,
      content: reply,
      timestamp: DateTime.now(),
    );

    _currentSession = _currentSession!.copyWith(
      messages: [..._currentSession!.messages, modelMessage],
      updatedAt: DateTime.now(),
    );
    _isGenerating = false;
    notifyListeners();

    await _chatRepository!.saveConversation(_currentSession!);
    scrollToBottom();
  }

  void scrollToBottom() {
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

  Future<void> pickAttachments(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );
      final paths = result?.paths.whereType<String>().toList() ?? const [];
      if (paths.isEmpty) return;

      for (final p in paths) {
        if (!_pendingAttachments.contains(p)) {
          _pendingAttachments.add(p);
        }
      }
      notifyListeners();
    } catch (e) {
      // Check if context is still valid before using it
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'chat.unable_pick'.tr(namedArgs: {'error': e.toString()}),
            ),
          ),
        );
      }
    }
  }

  void removeAttachmentAt(int index) {
    if (index < 0 || index >= _pendingAttachments.length) return;
    _pendingAttachments.removeAt(index);
    notifyListeners();
  }

  String getTranscript() {
    if (_currentSession == null) return '';
    return _currentSession!.messages
        .map((m) {
          final who = m.role == ChatRole.user
              ? 'role.you'.tr(context: _scaffoldKey.currentContext!)
              : (m.role == ChatRole.model
                    ? (_selectedAgent?.name ?? 'AI')
                    : 'role.system'.tr(context: _scaffoldKey.currentContext!));
          return '$who: ${m.content}';
        })
        .join('\n\n');
  }

  Future<void> copyTranscript(BuildContext context) async {
    final txt = getTranscript();
    if (txt.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: txt));

    // Check if context is still valid before using it
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('chat.copied'.tr())));
    }
  }

  Future<void> clearChat() async {
    if (_currentSession == null) return;
    _currentSession = _currentSession!.copyWith(
      messages: [],
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    await _chatRepository!.saveConversation(_currentSession!);
  }

  Future<void> regenerateLast(BuildContext context) async {
    if (_currentSession == null || _currentSession!.messages.isEmpty) return;

    final msgs = _currentSession!.messages;
    int lastUserIndex = -1;
    for (int i = msgs.length - 1; i >= 0; i--) {
      if (msgs[i].role == ChatRole.user) {
        lastUserIndex = i;
        break;
      }
    }
    if (lastUserIndex == -1) {
      // Check if context is still valid before using it
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('chat.no_user_to_regen'.tr())));
      }
      return;
    }

    final userText = msgs[lastUserIndex].content;
    final history = msgs.take(lastUserIndex).toList();

    _isGenerating = true;
    notifyListeners();

    final reply = await ChatService.generateReply(
      userText: userText,
      history: history,
      agent:
          _selectedAgent ??
          Agent(id: const Uuid().v4(), name: 'Default Agent', systemPrompt: ''),
    );

    final modelMessage = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.model,
      content: reply,
      timestamp: DateTime.now(),
    );

    // Cắt bỏ các câu trả lời model sau lastUser (nếu có) rồi thêm câu trả lời mới
    final newMessages = [...history, msgs[lastUserIndex], modelMessage];

    _currentSession = _currentSession!.copyWith(
      messages: newMessages,
      updatedAt: DateTime.now(),
    );
    _isGenerating = false;
    notifyListeners();

    await _chatRepository!.saveConversation(_currentSession!);
    scrollToBottom();
  }

  Future<void> speakLastModelMessage() async {
    if (_currentSession == null || _currentSession!.messages.isEmpty) return;
    final lastModel = _currentSession!.messages.lastWhere(
      (m) => m.role == ChatRole.model,
      orElse: () => ChatMessage(
        id: '',
        role: ChatRole.model,
        content: '',
        timestamp: DateTime.now(),
      ),
    );
    if (lastModel.content.isEmpty) return;
    _tts ??= FlutterTts();
    await _tts!.speak(lastModel.content);
  }

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _tts?.stop();
  }
}
