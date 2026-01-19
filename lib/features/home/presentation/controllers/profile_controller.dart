import 'package:multigateway/core/core.dart';
import 'package:signals/signals.dart';

/// Controller responsible for AI profile and MCP server management
class ProfileController {
  final ChatProfileStorage chatProfileRepository;
  final McpInfoStorage mcpStorage;

  final selectedProfile = signal<ChatProfile?>(null);
  final mcpItems = listSignal<McpInfo>([]);
  final mcpTools = listSignal<McpToolsList>([]);
  final modelTools = listSignal<ModelTool>([]);

  ProfileController({
    required this.chatProfileRepository,
    required this.mcpStorage,
  });

  Future<void> loadSelectedProfile() async {
    final profile = await chatProfileRepository.getOrInitSelectedProfile();
    selectedProfile.value = profile;
  }

  Future<void> updateProfile(ChatProfile profile) async {
    selectedProfile.value = profile;
    await chatProfileRepository.saveItem(profile);
  }

  Future<void> loadMcpClients() async {
    mcpItems.value = mcpStorage.getItems().whereType<McpInfo>().toList();
    mcpTools.value = mcpStorage.getItems().whereType<McpToolsList>().toList();
  }

  Future<void> loadModelTools() async {
    modelTools.value = mcpStorage.getItems().whereType<ModelTool>().toList();
  }

  Future<List<String>> snapshotEnabledToolNames(ChatProfile profile) async {
    try {
      final mcps = profile.activeMcp;
      final names = <String>{};
      for (final mcp in mcps) {
        for (final t in mcp.activeToolNames) {
          names.add(t);
        }
      }
      return names.toList();
    } catch (_) {
      return const <String>[];
    }
  }

  void dispose() {
    selectedProfile.dispose();
    mcpItems.dispose();
    mcpTools.dispose();
    modelTools.dispose();
  }
}
