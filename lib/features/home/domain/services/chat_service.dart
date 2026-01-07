import 'dart:async';

import 'package:llm/llm.dart';
import 'package:llm/models/llm_api/anthropic/messages.dart';
import 'package:llm/models/llm_api/googleai/generate_content.dart';
import 'package:llm/models/llm_api/ollama/chat.dart';
import 'package:llm/models/llm_api/openai/chat_completions.dart' as openai;
import 'package:mcp/mcp.dart';
import 'package:multigateway/core/core.dart' hide McpTool;
import 'package:multigateway/core/llm/models/legacy_llm_model.dart';

class ChatService {
  // Thu thập MCP tools ưu tiên cache; cập nhật khi dùng.
  static Future<List<McpTool>> _collectMcpTools(ChatProfile profile) async {
    if (profile.activeMcpServers.isEmpty) {
      return const <McpTool>[];
    }
    try {
      final mcpServerStorage = await McpServerInfoStorage.init();
      final mcpClient = McpClient();

      final servers = profile.activeMcpServers
          .map((i) => mcpServerStorage.getItem(i.id))
          .whereType<McpServer>()
          .toList();

      if (servers.isEmpty) return const <McpTool>[];

      final allowedToolsMap = {
        for (var s in profile.activeMcpServers) s.id: s.activeToolIds.toSet(),
      };

      List<McpTool> filterTools(List<McpServer> serversToFilter) {
        return serversToFilter.expand((s) {
          final allowedNames = allowedToolsMap[s.id] ?? {};
          return s.tools.where(
            (t) => t.enabled && allowedNames.contains(t.name),
          );
        }).toList();
      }

      List<McpTool> cachedTools = filterTools(servers);

      if (cachedTools.isEmpty) {
        final fetchedLists = await Future.wait(
          servers.map((s) async {
            try {
              final tools = await mcpClient.fetchTools(s);
              final updatedServer = s.copyWith(tools: tools);
              await mcpServerStorage.saveItem(updatedServer as McpServerInfo);
              return updatedServer;
            } catch (_) {
              return s;
            }
          }),
        );
        cachedTools = filterTools(fetchedLists);
      } else {
        Future(() async {
          for (final s in servers) {
            try {
              final tools = await mcpClient.fetchTools(s);
              await mcpServerStorage.saveItem(
                s.copyWith(tools: tools) as McpServerInfo,
              );
            } catch (_) {}
          }
        });
      }

      return cachedTools;
    } catch (_) {
      return const <McpTool>[];
    }
  }

  static List<GeminiTool> _collectGeminiBuiltinTools(
    LlmProviderModels? providerModels,
    String modelName,
    ChatProfile profile,
  ) {
    if (providerModels == null) return const <GeminiTool>[];

    final aiModels = providerModels.toAiModels();
    final lower = modelName.toLowerCase();
    LegacyAiModel? selectedModel;
    for (final m in aiModels) {
      if (m.name.toLowerCase() == lower) {
        selectedModel = m;
        break;
      }
    }

    bool supportsSearch = lower.contains('gemini');
    bool supportsCode = lower.contains('gemini');
    bool supportsUrlContext = lower.contains('gemini');

    if (selectedModel != null && selectedModel.builtInTools != null) {
      supportsSearch = selectedModel.builtInTools!.googleSearch;
      supportsCode = selectedModel.builtInTools!.codeExecution;
      supportsUrlContext = selectedModel.builtInTools!.urlContext;
    }

    final builtin = <GeminiTool>[];

    if (supportsSearch &&
        profile.activeBuiltInTools.contains('google_search')) {
      builtin.add(
        GeminiTool(
          functionDeclarations: [
            GeminiFunctionDeclaration(
              name: '__google_search__',
              description: 'Google Search tool',
              parameters: const {'type': 'object', 'properties': {}},
            ),
          ],
        ),
      );
    }

    if (supportsCode && profile.activeBuiltInTools.contains('code_execution')) {
      builtin.add(GeminiTool(codeExecution: const GeminiCodeExecution()));
    }

    if (supportsUrlContext &&
        profile.activeBuiltInTools.contains('url_context')) {
      builtin.add(
        GeminiTool(
          functionDeclarations: [
            GeminiFunctionDeclaration(
              name: '__url_context__',
              description: 'URL Context tool',
              parameters: const {'type': 'object', 'properties': {}},
            ),
          ],
        ),
      );
    }

    return builtin;
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
    final modelsRepo = await LlmProviderModelsStorage.init();

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
    final providerModels = modelsRepo.getItem(providerInfo.id);

    final messagesWithCurrent = [
      ...history,
      ChatMessage(
        id: 'temp-user',
        role: ChatRole.user,
        content: userText,
        timestamp: DateTime.now(),
      ),
    ];

    var mcpTools = await _collectMcpTools(profile);
    if (allowedToolNames != null && allowedToolNames.isNotEmpty) {
      mcpTools = mcpTools
          .where((t) => allowedToolNames.contains(t.name))
          .toList();
    }

    final systemInstruction = profile.config.systemPrompt;
    final apiKey = providerInfo.auth.key ?? '';

    switch (providerInfo.type) {
      case ProviderType.googleai:
        final builtinTools = _collectGeminiBuiltinTools(
          providerModels,
          modelName,
          profile,
        );

        final geminiMcpTools = mcpTools
            .map(
              (t) => GeminiTool(
                functionDeclarations: [
                  GeminiFunctionDeclaration(
                    name: t.name,
                    description: t.description,
                    parameters: t.inputSchema.toJson(),
                  ),
                ],
              ),
            )
            .toList();
        final allTools = [...geminiMcpTools, ...builtinTools];

        final aiMessages = messagesWithCurrent.map((m) {
          return GeminiContent(
            role: _mapRole(m.role, ProviderType.googleai),
            parts: [GeminiPart(text: m.content)],
          );
        }).toList();

        final studio = GoogleAiStudio(
          apiKey: apiKey,
          baseUrl: providerInfo.baseUrl,
        );

        final aiRequest = GeminiGenerateContentRequest(
          contents: aiMessages,
          tools: allTools.isNotEmpty ? allTools : null,
          systemInstruction: systemInstruction.isNotEmpty
              ? GeminiContent(
                  role: 'system',
                  parts: [GeminiPart(text: systemInstruction)],
                )
              : null,
        );

        await for (final resp in studio.generateContentStream(
          model: modelName,
          request: aiRequest,
        )) {
          final text =
              resp.candidates?.firstOrNull?.content?.parts?.firstOrNull?.text;
          if (text != null) yield text;
        }
        break;

      case ProviderType.openai:
        final service = OpenAiProvider(
          baseUrl: providerInfo.baseUrl,
          apiKey: apiKey,
          chatPath:
              providerConfig?.customChatCompletionUrl ?? '/chat/completions',
          modelsPath: providerConfig?.customListModelsUrl ?? '/models',
          headers: providerConfig?.headers?.cast<String, String>() ?? const {},
        );

        final aiMessages = messagesWithCurrent.map((m) {
          return openai.RequestMessage(
            role: _mapRole(m.role, ProviderType.openai),
            content: m.content,
          );
        }).toList();

        if (systemInstruction.isNotEmpty) {
          aiMessages.insert(
            0,
            openai.RequestMessage(role: 'system', content: systemInstruction),
          );
        }

        final openaiTools = mcpTools
            .map(
              (t) => openai.Tool(
                type: 'function',
                function: openai.FunctionDefinition(
                  name: t.name,
                  description: t.description,
                  parameters: t.inputSchema.toJson(),
                ),
              ),
            )
            .toList();

        final aiRequest = openai.OpenAiChatCompletionsRequest(
          model: modelName,
          messages: aiMessages,
          tools: openaiTools.isNotEmpty ? openaiTools : null,
          stream: true,
        );

        await for (final resp in service.chatCompletionsStream(aiRequest)) {
          final text = resp.choices?.firstOrNull?.delta?.content;
          if (text != null) yield text;
        }
        break;

      case ProviderType.anthropic:
        final service = AnthropicProvider(
          baseUrl: providerInfo.baseUrl,
          apiKey: apiKey,
          headers: providerConfig?.headers?.cast<String, String>() ?? const {},
        );

        final aiMessages = messagesWithCurrent.map((m) {
          return AnthropicMessage(
            role: _mapRole(m.role, ProviderType.anthropic),
            content: m.content,
          );
        }).toList();

        final anthropicTools = mcpTools
            .map(
              (t) => AnthropicTool(
                name: t.name,
                description: t.description,
                inputSchema: t.inputSchema.toJson(),
              ),
            )
            .toList();

        final aiRequest = AnthropicMessagesRequest(
          model: modelName,
          messages: aiMessages,
          maxTokens: 4096, // Default or from config
          system: systemInstruction.isNotEmpty ? systemInstruction : null,
          tools: anthropicTools.isNotEmpty ? anthropicTools : null,
          stream: true,
        );

        await for (final resp in service.messagesStream(aiRequest)) {
          final text = resp.content.firstOrNull?.text;
          if (text != null) yield text;
        }
        break;

      case ProviderType.ollama:
        final service = OllamaProvider(
          baseUrl: providerInfo.baseUrl,
          apiKey: apiKey,
          headers: providerConfig?.headers?.cast<String, String>() ?? const {},
        );

        final aiMessages = messagesWithCurrent.map((m) {
          return OllamaMessage(
            role: _mapRole(m.role, ProviderType.ollama),
            content: m.content,
          );
        }).toList();

        if (systemInstruction.isNotEmpty) {
          aiMessages.insert(
            0,
            OllamaMessage(role: 'system', content: systemInstruction),
          );
        }

        final ollamaTools = mcpTools
            .map(
              (t) => OllamaTool(
                function: OllamaFunction(
                  name: t.name,
                  description: t.description,
                  parameters: t.inputSchema.toJson(),
                ),
              ),
            )
            .toList();

        final aiRequest = OllamaChatRequest(
          model: modelName,
          messages: aiMessages,
          tools: ollamaTools.isNotEmpty ? ollamaTools : null,
          stream: true,
        );

        await for (final resp in service.chatStream(aiRequest)) {
          final text = resp.message?.content;
          if (text != null) yield text;
        }
        break;
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

  static String _mapRole(ChatRole role, ProviderType providerType) {
    switch (role) {
      case ChatRole.user:
        return 'user';
      case ChatRole.model:
        if (providerType == ProviderType.googleai) return 'model';
        return 'assistant';
      case ChatRole.system:
        return 'system';
      case ChatRole.tool:
        return 'tool';
      case ChatRole.developer:
        return 'developer';
    }
  }
}
