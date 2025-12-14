import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:ai_gateway/core/storage/chat_repository.dart';
import 'package:ai_gateway/features/home/models/chat_models.dart';
import 'package:ai_gateway/core/storage/agent_repository.dart';
import 'package:ai_gateway/features/agents/dto/agent.dart';
import 'package:ai_gateway/features/home/models/chat_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatScreenViewModel extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ChatRepository? _chatRepository;
  ChatSession? _currentSession;
  AgentRepository? _agentRepository;
  Agent? _selectedAgent;
  bool _isLoading = true;
  bool _isGenerating = false;

  // Đính kèm đang chờ gửi
  final List<String> _pendingAttachments = [];

  // TTS
  FlutterTts? _tts;

  // Getters
  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;
  TextEditingController get textController => _textController;
  ScrollController get scrollController => _scrollController;
  ChatSession? get currentSession => _currentSession;
  Agent? get selectedAgent => _selectedAgent;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  List<String> get pendingAttachments => _pendingAttachments;

  Future<void> initChat() async {
    _chatRepository = await ChatRepository.init();
    final sessions = _chatRepository!.getSessions();

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
    final session = await _chatRepository!.createSession();
    _currentSession = session;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadSession(String sessionId) async {
    _isLoading = true;
    notifyListeners();

    final sessions = _chatRepository!.getSessions();
    final session = sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => sessions.first,
    );

    _currentSession = session;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> handleSubmitted(String text, BuildContext context) async {
    if (((text.trim().isEmpty) && _pendingAttachments.isEmpty) || _currentSession == null) return;

    // Chuẩn bị dữ liệu gửi
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

    // Cập nhật tiêu đề khi là tin đầu tiên
    if (_currentSession!.messages.length == 1) {
      final base = text.isNotEmpty
          ? text
          : (attachments.isNotEmpty
              ? 'attachments.title_count'.tr(namedArgs: {'count': attachments.length.toString()})
              : 'drawer.new_chat'.tr());
      final title = base.length > 30 ? '${base.substring(0, 30)}...' : base;
      _currentSession = _currentSession!.copyWith(title: title);
    }

    await _chatRepository!.saveSession(_currentSession!);
    scrollToBottom();

    // Gộp chú thích đính kèm vào prompt để nhà cung cấp biết
    String modelInput = text;
    if (attachments.isNotEmpty) {
      final names = attachments.map((p) => p.split('/').last).join(', ');
      modelInput = '${modelInput.isEmpty ? '' : '$modelInput\n'}[Attachments: $names]';
    }

    // Gọi ChatService sinh phản hồi
    final reply = await ChatService.generateReply(
      userText: modelInput,
      history: _currentSession!.messages,
      agent: _selectedAgent ?? Agent(
        id: const Uuid().v4(),
        name: 'Default Agent',
        systemPrompt: '',
      ),
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

    await _chatRepository!.saveSession(_currentSession!);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('chat.unable_pick'.tr(namedArgs: {'error': e.toString()}))),
      );
    }
  }

  void removeAttachmentAt(int index) {
    if (index < 0 || index >= _pendingAttachments.length) return;
    _pendingAttachments.removeAt(index);
    notifyListeners();
  }

  String getTranscript() {
    if (_currentSession == null) return '';
    return _currentSession!.messages.map((m) {
      final who = m.role == ChatRole.user
          ? 'role.you'.tr(context: _scaffoldKey.currentContext!)
          : (m.role == ChatRole.model ? (_selectedAgent?.name ?? 'AI') : 'role.system'.tr(context: _scaffoldKey.currentContext!));
      return '$who: ${m.content}';
    }).join('\n\n');
  }

  Future<void> copyTranscript(BuildContext context) async {
    final txt = getTranscript();
    if (txt.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: txt));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('chat.copied'.tr())),
    );
  }

  Future<void> clearChat() async {
    if (_currentSession == null) return;
    _currentSession = _currentSession!.copyWith(
      messages: [],
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    await _chatRepository!.saveSession(_currentSession!);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('chat.no_user_to_regen'.tr())),
      );
      return;
    }

    final userText = msgs[lastUserIndex].content;
    final history = msgs.take(lastUserIndex).toList();

    _isGenerating = true;
    notifyListeners();

    final reply = await ChatService.generateReply(
      userText: userText,
      history: history,
      agent: _selectedAgent ?? Agent(
        id: const Uuid().v4(),
        name: 'Default Agent',
        systemPrompt: '',
      ),
    );

    final modelMessage = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.model,
      content: reply,
      timestamp: DateTime.now(),
    );

    // Cắt bỏ các câu trả lời model sau lastUser (nếu có) rồi thêm câu trả lời mới
    final newMessages = [
      ...history,
      msgs[lastUserIndex],
      modelMessage,
    ];

    _currentSession = _currentSession!.copyWith(
      messages: newMessages,
      updatedAt: DateTime.now(),
    );
    _isGenerating = false;
    notifyListeners();

    await _chatRepository!.saveSession(_currentSession!);
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
    _textController.dispose();
    _scrollController.dispose();
    _tts?.stop();
  }
}