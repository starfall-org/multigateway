import 'dart:async';

import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:dartantic_interface/dartantic_interface.dart' as dai;

import 'package:multigateway/core/core.dart' hide McpClient;

class ChatService {
  static McpClient? _buildDartanticMcpClient(McpServerInfo info) {
    switch (info.protocol) {
      case McpProtocol.stdio:
        final stdio = info.stdioConfig;
        if (stdio == null) return null;
        final command = stdio.execBinaryPath.isNotEmpty
            ? stdio.execBinaryPath
            : stdio.execFilePath;
        if (command.isEmpty) return null;
        final args = stdio.execArgs
            .split(RegExp(r'\s+'))
            .where((e) => e.isNotEmpty)
            .toList();
        return McpClient.local(
          info.name,
          command: command,
          args: args,
          workingDirectory: null,
        );
      case McpProtocol.streamableHttp:
      case McpProtocol.sse:
        if (info.url == null || info.url!.isEmpty) return null;
        final uri = Uri.tryParse(info.url!);
        if (uri == null) return null;
        return McpClient.remote(
          info.name,
          url: uri,
          headers: info.headers,
        );
    }
  }

  static Future<List<dai.Tool>> _collectMcpTools(ChatProfile profile) async {
    if (profile.activeMcpServers.isEmpty) return const <dai.Tool>[];
    final mcpServerStorage = await McpServerInfoStorage.init();
    final tools = <dai.Tool>[];

    for (final active in profile.activeMcpServers) {
      final serverInfo = mcpServerStorage.getItem(active.id);
      if (serverInfo == null) continue;

      final client = _buildDartanticMcpClient(serverInfo);
      if (client == null) continue;

      try {
        final serverTools = await client.listTools();
        tools.addAll(
          serverTools.where(
            (t) => active.activeToolIds.isEmpty ||
                active.activeToolIds.contains(t.name),
          ),
        );
      } catch (_) {
        // ignore failures to keep chat running
      } finally {
        client.dispose();
      }
    }

    return tools;
  }

  static List<dai.ChatMessage> _buildMessages({
    required String userText,
    required List<ChatMessage> history,
    required String systemPrompt,
  }) {
    final messages = <dai.ChatMessage>[];

    if (systemPrompt.isNotEmpty) {
      messages.add(dai.ChatMessage.system(systemPrompt));
    }

    for (final msg in history) {
      final content = msg.content ?? '';
      final role = _mapRole(msg.role);
      messages.add(
        dai.ChatMessage(
          role: role,
          parts: [dai.TextPart(content)],
        ),
      );
    }

    messages.add(
      dai.ChatMessage(
        role: dai.ChatMessageRole.user,
        parts: [dai.TextPart(userText)],
      ),
    );

    return messages;
  }

  static Stream<String> generateStream({
    required String userText,
    required List<ChatMessage> history,
    required ChatProfile profile,
    required String providerName,
    required String modelName,
    List<String>? allowedToolNames,
  }) async* {
    final providerRepo = await LlmProviderInfoStorage.init();
    final configRepo = await LlmProviderConfigStorage.init();

    final providers = providerRepo.getItems();
    if (providers.isEmpty) {
      throw Exception(
        'No provider configuration found. Please add a provider in Settings.',
      );
    }

    final providerInfo = providers.firstWhere(
      (p) => p.name == providerName,
      orElse: () => throw Exception('Provider "$providerName" not found.'),
    );

    final providerConfig = configRepo.getItem(providerInfo.id);

    var mcpTools = await _collectMcpTools(profile);
    if (allowedToolNames != null && allowedToolNames.isNotEmpty) {
      mcpTools =
          mcpTools.where((t) => allowedToolNames.contains(t.name)).toList();
    }

    final messages = _buildMessages(
      userText: userText,
      history: history,
      systemPrompt: profile.config.systemPrompt,
    );

    dai.ChatModel chatModel;

    switch (providerInfo.type) {
      case ProviderType.googleai:
        final provider = GoogleProvider(
          apiKey: providerInfo.auth.key,
          baseUrl: Uri.tryParse(providerInfo.baseUrl),
          headers: providerConfig?.headers?.cast<String, String>(),
        );
        chatModel = provider.createChatModel(
          name: modelName,
          tools: tools,
          temperature: profile.config.temperature,
        );
        break;
      case ProviderType.openai:
        final provider = OpenAIProvider(
          apiKey: providerInfo.auth.key,
          baseUrl: Uri.tryParse(providerInfo.baseUrl),
          headers: providerConfig?.headers?.cast<String, String>(),
        );
        chatModel = provider.createChatModel(
          name: modelName,
          tools: tools,
          temperature: profile.config.temperature,
        );
        break;
      case ProviderType.anthropic:
        final provider = AnthropicProvider(
          apiKey: providerInfo.auth.key,
          headers: providerConfig?.headers?.cast<String, String>(),
        );
        chatModel = provider.createChatModel(
          name: modelName,
          tools: tools,
          temperature: profile.config.temperature,
        );
        break;
      case ProviderType.ollama:
        final provider = OllamaProvider(
          baseUrl: Uri.tryParse(providerInfo.baseUrl),
          headers: providerConfig?.headers?.cast<String, String>(),
        );
        chatModel = provider.createChatModel(
          name: modelName,
          tools: tools,
          temperature: profile.config.temperature,
        );
        break;
    }

    try {
      await for (final resp in chatModel.sendStream(messages)) {
        final text = resp.output.parts
            .whereType<dai.TextPart>()
            .map((p) => p.text)
            .join();
        if (text.isNotEmpty) yield text;
      }
    } finally {
      chatModel.dispose();
    }
  }

  static Future<String> generateReply({
    required String userText,
    required List<ChatMessage> history,
    required ChatProfile profile,
    required String providerName,
    required String modelName,
    List<String>? allowedToolNames,
  }) async {
    final buffer = StringBuffer();
    await for (final chunk in generateStream(
      userText: userText,
      history: history,
      profile: profile,
      providerName: providerName,
      modelName: modelName,
      allowedToolNames: allowedToolNames,
    )) {
      buffer.write(chunk);
    }
    return buffer.toString();
  }

  static dai.ChatMessageRole _mapRole(ChatRole role) {
    switch (role) {
      case ChatRole.user:
        return dai.ChatMessageRole.user;
      case ChatRole.model:
        return dai.ChatMessageRole.model;
      case ChatRole.system:
        return dai.ChatMessageRole.system;
      case ChatRole.tool:
      case ChatRole.developer:
        return dai.ChatMessageRole.user;
    }
  }
}
