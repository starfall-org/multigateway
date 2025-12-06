import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:lmhub/src/core/storage/chat_repository.dart';
import 'package:lmhub/src/features/chat/domain/chat_models.dart';
import 'package:lmhub/src/core/storage/agent_repository.dart';
import 'package:lmhub/src/features/agents/domain/agent.dart';
import 'package:lmhub/src/features/chat/domain/chat_service.dart';
import 'widgets/chat_drawer.dart';
import 'widgets/chat_input_area.dart';
import 'widgets/chat_message_list.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lmhub/src/features/agents/presentation/agent_list_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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

  @override
  void initState() {
    super.initState();
    _initChat();
    _loadSelectedAgent();
  }

  Future<void> _initChat() async {
    _chatRepository = await ChatRepository.init();
    final sessions = _chatRepository!.getSessions();

    if (sessions.isNotEmpty) {
      setState(() {
        _currentSession = sessions.first;
        _isLoading = false;
      });
    } else {
      await _createNewSession();
    }
  }

  Future<void> _loadSelectedAgent() async {
    _agentRepository ??= await AgentRepository.init();
    final agent = await _agentRepository!.getOrInitSelectedAgent();
    if (!mounted) return;
    setState(() {
      _selectedAgent = agent;
    });
  }

  Future<void> _createNewSession() async {
    final session = await _chatRepository!.createSession();
    setState(() {
      _currentSession = session;
      _isLoading = false;
    });
  }

  Future<void> _loadSession(String sessionId) async {
    setState(() {
      _isLoading = true;
    });
    final sessions = _chatRepository!.getSessions();
    final session = sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => sessions.first,
    );
    setState(() {
      _currentSession = session;
      _isLoading = false;
    });
  }

  Future<void> _handleSubmitted(String text) async {
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

    setState(() {
      _currentSession = _currentSession!.copyWith(
        messages: [..._currentSession!.messages, userMessage],
        updatedAt: DateTime.now(),
      );
      _isGenerating = true;
      _pendingAttachments.clear();
    });

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
    _scrollToBottom();

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

    if (mounted) {
      setState(() {
        _currentSession = _currentSession!.copyWith(
          messages: [..._currentSession!.messages, modelMessage],
          updatedAt: DateTime.now(),
        );
        _isGenerating = false;
      });
      await _chatRepository!.saveSession(_currentSession!);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
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

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _tts?.stop();
    super.dispose();
  }

  Future<void> _pickAttachments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );
      final paths = result?.paths.whereType<String>().toList() ?? const [];
      if (paths.isEmpty) return;
      setState(() {
        for (final p in paths) {
          if (!_pendingAttachments.contains(p)) {
            _pendingAttachments.add(p);
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('chat.unable_pick'.tr(namedArgs: {'error': e.toString()}))),
      );
    }
  }

  void _removeAttachmentAt(int index) {
    if (index < 0 || index >= _pendingAttachments.length) return;
    setState(() {
      _pendingAttachments.removeAt(index);
    });
  }

  String _getTranscript() {
    if (_currentSession == null) return '';
    return _currentSession!.messages.map((m) {
      final who = m.role == ChatRole.user
          ? 'role.you'.tr(context: context)
          : (m.role == ChatRole.model ? (_selectedAgent?.name ?? 'AI') : 'role.system'.tr(context: context));
      return '$who: ${m.content}';
    }).join('\n\n');
  }

  Future<void> _copyTranscript() async {
    final txt = _getTranscript();
    if (txt.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: txt));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('chat.copied'.tr())),
    );
  }

  Future<void> _clearChat() async {
    if (_currentSession == null) return;
    setState(() {
      _currentSession = _currentSession!.copyWith(
        messages: [],
        updatedAt: DateTime.now(),
      );
    });
    await _chatRepository!.saveSession(_currentSession!);
  }

  Future<void> _regenerateLast() async {
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

    setState(() {
      _isGenerating = true;
    });

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

    if (!mounted) return;
    // Cắt bỏ các câu trả lời model sau lastUser (nếu có) rồi thêm câu trả lời mới
    final newMessages = [
      ...history,
      msgs[lastUserIndex],
      modelMessage,
    ];

    setState(() {
      _currentSession = _currentSession!.copyWith(
        messages: newMessages,
        updatedAt: DateTime.now(),
      );
      _isGenerating = false;
    });
    await _chatRepository!.saveSession(_currentSession!);
    _scrollToBottom();
  }

  Future<void> _speakLastModelMessage() async {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black54),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
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
              _selectedAgent?.name ?? 'Default Agent',
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
        actions: [
          InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AgentListScreen(),
                ),
              );
              if (result == true) {
                await _loadSelectedAgent();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  ((_selectedAgent?.name.isNotEmpty == true
                          ? _selectedAgent!.name[0]
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
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onSelected: (value) {
              switch (value) {
                case 'regen':
                  _regenerateLast();
                  break;
                case 'clear':
                  _clearChat();
                  break;
                case 'copy':
                  _copyTranscript();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'regen',
                child: Text('chat.regenerate'.tr()),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Text('chat.clear'.tr()),
              ),
              PopupMenuItem(
                value: 'copy',
                child: Text('chat.copy'.tr()),
              ),
            ],
          ),
        ],
      ),
      drawer: ChatDrawer(
        onSessionSelected: (sessionId) {
          Navigator.pop(context); // Close drawer
          _loadSession(sessionId);
        },
        onNewChat: () {
          Navigator.pop(context);
          _createNewSession();
        },
        onAgentChanged: () {
          _loadSelectedAgent();
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentSession!.messages.isEmpty
                ? Center(
                        child: Text(
                          'chat.start'.tr(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                : ChatMessageList(
                    messages: _currentSession!
                        .messages, // We need to update ChatMessageList to accept List<ChatMessage>
                    scrollController: _scrollController,
                  ),
          ),
          if (_isGenerating)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          ChatInputArea(
            controller: _textController,
            onSubmitted: _handleSubmitted,
            attachments: _pendingAttachments,
            onPickAttachments: _pickAttachments,
            onRemoveAttachment: _removeAttachmentAt,
            isGenerating: _isGenerating,
            onMicTap: _speakLastModelMessage,
          ),
        ],
      ),
    );
  }
}
