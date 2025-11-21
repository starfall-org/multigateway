import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:lmhub/src/core/storage/chat_repository.dart';
import 'package:lmhub/src/features/chat/domain/chat_models.dart';
import 'widgets/chat_drawer.dart';
import 'widgets/chat_input_area.dart';
import 'widgets/chat_message_list.dart';

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
  bool _isLoading = true;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _initChat();
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
    if (text.trim().isEmpty || _currentSession == null) return;

    _textController.clear();

    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.user,
      content: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _currentSession = _currentSession!.copyWith(
        messages: [..._currentSession!.messages, userMessage],
        updatedAt: DateTime.now(),
      );
      _isGenerating = true;
    });

    // Update title if it's the first message
    if (_currentSession!.messages.length == 1) {
      final title = text.length > 30 ? '${text.substring(0, 30)}...' : text;
      _currentSession = _currentSession!.copyWith(title: title);
    }

    await _chatRepository!.saveSession(_currentSession!);
    _scrollToBottom();

    // Mock AI Response
    await Future.delayed(const Duration(seconds: 1));

    final modelMessage = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.model,
      content:
          'This is a mock response to: "$text". Real integration coming soon!',
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chào Hỏi Và Hỗ Trợ',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Gemini Pro', // TODO: Bind to selected agent
              style: TextStyle(
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
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () {},
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
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentSession!.messages.isEmpty
                ? const Center(
                    child: Text(
                      'Start a conversation!',
                      style: TextStyle(color: Colors.grey),
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
          ),
        ],
      ),
    );
  }
}
