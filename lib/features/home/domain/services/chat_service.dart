import '../../../../core/llm/provider/anthropic/anthropic.dart';
import '../../../../core/llm/provider/googleai/aistudio.dart';
import '../../../../core/llm/provider/googleai/vertexai.dart';
import '../../../../core/llm/provider/ollama/ollama.dart';
import '../../../../core/mcp/mcp_client.dart';
import '../../../../core/llm/data/provider_info_storage.dart';
import '../../../../core/llm/models/api/api.dart';
import '../../../../core/llm/models/llm_model/base.dart';
import '../../../../core/profile/models/profile.dart';
import '../../../../core/llm/models/llm_provider/provider_info.dart';
import '../models/message.dart';
import '../../../../core/mcp/data/mcpserver_store.dart';
import '../../../../core/mcp/models/mcp_server.dart';
import '../../../../core/llm/provider/openai/openai.dart';

class ChatService {
  // Thu thập MCP tools ưu tiên cache; cập nhật khi dùng.
  static Future<List<AIToolFunction>> _collectMcpTools(
    AIProfile profile,
  ) async {
    if (profile.activeMCPServers.isEmpty) {
      return const <AIToolFunction>[];
    }
    try {
      final mcpRepository = await MCPRepository.init();
      final mcpService = MCPService();

      final servers = profile.activeMCPServers
          .map((i) => mcpRepository.getItem(i.id))
          .whereType<MCPServer>()
          .toList();

      if (servers.isEmpty) return const <AIToolFunction>[];

      // Build a map of allowed tools per server for easy lookup
      final allowedToolsMap = {
        for (var s in profile.activeMCPServers) s.id: s.activeToolIds.toSet(),
      };

      List<MCPTool> filterTools(List<MCPServer> serversToFilter) {
        return serversToFilter.expand((s) {
          final allowedNames = allowedToolsMap[s.id] ?? {};
          return s.tools.where(
            (t) => t.enabled && allowedNames.contains(t.name),
          );
        }).toList();
      }

      // Dùng cache nếu có
      List<MCPTool> cachedTools = filterTools(servers);

      if (cachedTools.isEmpty) {
        // Không có cache: fetch ngay và lưu lại
        final fetchedLists = await Future.wait(
          servers.map((s) async {
            try {
              final tools = await mcpService.fetchTools(s);
              final updatedServer = s.copyWith(tools: tools);
              await mcpRepository.updateItem(updatedServer);
              return updatedServer;
            } catch (_) {
              return s;
            }
          }),
        );
        cachedTools = filterTools(fetchedLists);
      } else {
        // Có cache: làm mới ở nền khi được dùng, không chặn luồng chat
        // ignore: discarded_futures
        Future(() async {
          for (final s in servers) {
            try {
              final tools = await mcpService.fetchTools(s);
              await mcpRepository.updateItem(s.copyWith(tools: tools));
            } catch (_) {}
          }
        });
      }

      // Khử trùng lặp theo tên tool
      final map = <String, AIToolFunction>{};
      for (final t in cachedTools) {
        map[t.name] = AIToolFunction(
          name: t.name,
          description: t.description,
          parameters: t.inputSchema.toJson(),
        );
      }
      return map.values.toList();
    } catch (_) {
      return const <AIToolFunction>[];
    }
  }

  // Built-in Gemini tools toggling based on AIProfile and Model capabilities
  static List<AIToolFunction> _collectGeminiBuiltinTools(
    Provider provider,
    String modelName,
    AIProfile profile,
  ) {
    // 1. Check model capabilities (if defined)
    final lower = modelName.toLowerCase();
    AIModel? selectedModel;
    for (final m in provider.models) {
      if (m.name.toLowerCase() == lower) {
        selectedModel = m;
        break;
      }
    }

    // Default capabilities if not explicitly defined
    bool supportsSearch = lower.contains('gemini');
    bool supportsCode = lower.contains('gemini');
    bool supportsUrlContext = lower.contains('gemini');

    if (selectedModel != null && selectedModel.builtInTools != null) {
      supportsSearch = selectedModel.builtInTools!.googleSearch;
      supportsCode = selectedModel.builtInTools!.codeExecution;
      supportsUrlContext = selectedModel.builtInTools!.urlContext;
    }

    // 2. Check profile activation
    final builtin = <AIToolFunction>[];

    if (supportsSearch &&
        profile.activeBuiltInTools.contains('google_search')) {
      // Use reserved name for Google Search Grounding
      builtin.add(
        const AIToolFunction(
          name: '__google_search__',
          description: '',
          parameters: {},
        ),
      );
    }

    if (supportsCode && profile.activeBuiltInTools.contains('code_execution')) {
      // Use reserved name for Code Execution
      builtin.add(
        const AIToolFunction(
          name: '__code_execution__',
          description: '',
          parameters: {},
        ),
      );
    }

    if (supportsUrlContext &&
        profile.activeBuiltInTools.contains('url_context')) {
      // Use reserved name for URL Context
      builtin.add(
        const AIToolFunction(
          name: '__url_context__',
          description: '',
          parameters: {},
        ),
      );
    }

    return builtin;
  }

  static Stream<String> generateStream({
    required String userText,
    required List<ChatMessage> history,
    required AIProfile profile,
    required String providerName,
    required String modelName,
    List<String>? allowedToolNames,
  }) async* {
    final providerRepo = await ProviderInfoStorage.init();
    final providers = providerRepo.getProviders();
    if (providers.isEmpty) {
      throw Exception(
        'No provider configuration found. Please add a provider in Settings.',
      );
    }

    final provider = providers.firstWhere(
      (p) => p.name == providerName,
      orElse: () => throw Exception('Provider "$providerName" not found.'),
    );

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

    switch (provider.type) {
      case ProviderType.google:
        final builtinTools = _collectGeminiBuiltinTools(
          provider,
          modelName,
          profile,
        );
        final allTools = [...mcpTools, ...builtinTools];

        final aiMessages = messagesWithCurrent
            .map(
              (m) => AIMessage(
                role: _mapRole(m.role, ProviderType.google),
                content: [AIContent(type: AIContentType.text, text: m.content)],
              ),
            )
            .toList();

        if (systemInstruction.isNotEmpty && aiMessages.isNotEmpty) {
          final firstUserMsg = aiMessages.firstWhere(
            (m) => m.role == 'user',
            orElse: () => aiMessages.first,
          );
          final idx = aiMessages.indexOf(firstUserMsg);
          aiMessages[idx] = AIMessage(
            role: firstUserMsg.role,
            content: [
              AIContent(
                type: AIContentType.text,
                text:
                    '$systemInstruction\n\n${firstUserMsg.content.first.text}',
              ),
            ],
          );
        }

        final vx = provider.vertexAIConfig;
        if (vx != null && vx.projectId.isNotEmpty) {
          final vertex = GoogleVertexAI(
            defaultModel: modelName,
            provider: provider,
            projectId: vx.projectId,
            location: vx.location,
          );
          final aiRequest = AIRequest(
            model: modelName,
            messages: aiMessages,
            tools: allTools,
            stream: true,
          );
          await for (final resp in vertex.generateStream(aiRequest)) {
            yield resp.text;
          }
        } else {
          final studio = GoogleAIStudio(
            defaultModel: modelName,
            provider: provider,
          );
          final aiRequest = AIRequest(
            model: modelName,
            messages: aiMessages,
            tools: allTools,
            stream: true,
          );
          await for (final resp in studio.generateStream(aiRequest)) {
            yield resp.text;
          }
        }
        break;

      case ProviderType.openai:
        final routes = provider.openAIRoutes;
        final service = OpenAI(
          baseUrl: provider.baseUrl,
          apiKey: provider.apiKey!,
          chatPath: routes.chatCompletion,
          modelsPath: routes.modelsRouteOrUrl,
          headers: provider.headers,
        );

        final aiMessages = messagesWithCurrent
            .map(
              (m) => AIMessage(
                role: _mapRole(m.role, ProviderType.openai),
                content: [AIContent(type: AIContentType.text, text: m.content)],
              ),
            )
            .toList();

        if (systemInstruction.isNotEmpty) {
          aiMessages.insert(
            0,
            AIMessage(
              role: 'system',
              content: [
                AIContent(type: AIContentType.text, text: systemInstruction),
              ],
            ),
          );
        }

        final aiRequest = AIRequest(
          model: modelName,
          messages: aiMessages,
          tools: mcpTools,
          stream: true,
        );

        final stream = service.generateStream(aiRequest);
        await for (final resp in stream) {
          yield resp.text;
        }
        break;

      case ProviderType.anthropic:
        final service = Anthropic(
          baseUrl: provider.baseUrl,
          apiKey: provider.apiKey!,
          headers: provider.headers,
        );

        final aiMessages = messagesWithCurrent
            .map(
              (m) => AIMessage(
                role: _mapRole(m.role, ProviderType.anthropic),
                content: [AIContent(type: AIContentType.text, text: m.content)],
              ),
            )
            .toList();

        final aiRequest = AIRequest(
          model: modelName,
          messages: aiMessages,
          tools: mcpTools,
          stream: true,
          extra: systemInstruction.isNotEmpty
              ? {'system': systemInstruction}
              : {},
        );
        final stream = service.generateStream(aiRequest);
        await for (final resp in stream) {
          yield resp.text;
        }
        break;

      case ProviderType.ollama:
        final service = Ollama(
          baseUrl: provider.baseUrl,
          apiKey: provider.apiKey!,
          headers: provider.headers,
        );

        final aiMessages = messagesWithCurrent
            .map(
              (m) => AIMessage(
                role: _mapRole(m.role, ProviderType.ollama),
                content: [AIContent(type: AIContentType.text, text: m.content)],
              ),
            )
            .toList();

        final aiRequest = AIRequest(
          model: modelName,
          messages: aiMessages,
          tools: mcpTools,
          stream: true,
        );
        final stream = service.generateStream(aiRequest);
        await for (final resp in stream) {
          yield resp.text;
        }
        break;
    }
  }

  static Future<String> generateReply({
    required String userText,
    required List<ChatMessage> history,
    required AIProfile profile,
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
        if (providerType == ProviderType.google) return 'model';
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
