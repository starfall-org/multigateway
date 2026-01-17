import 'package:mcp/mcp.dart';
import 'package:multigateway/core/mcp/storage/mcp_server_info_storage.dart';
import 'package:multigateway/core/profile/profile.dart';
import 'package:signals/signals.dart';

/// Controller responsible for AI profile and MCP server management
class ProfileController {
  final ChatProfileStorage aiProfileRepository;
  final McpServerInfoStorage mcpServerStorage;

  final selectedProfile = signal<ChatProfile?>(null);
  final mcpServers = listSignal<McpServer>([]);

  ProfileController({
    required this.aiProfileRepository,
    required this.mcpServerStorage,
  });

  Future<void> loadSelectedProfile() async {
    final profile = await aiProfileRepository.getOrInitSelectedProfile();
    selectedProfile.value = profile;
  }

  Future<void> updateProfile(ChatProfile profile) async {
    selectedProfile.value = profile;
    await aiProfileRepository.saveItem(profile);
  }

  Future<void> loadMcpServers() async {
    mcpServers.value = mcpServerStorage
        .getItems()
        .whereType<McpServer>()
        .toList();
  }

  Future<List<String>> snapshotEnabledToolNames(ChatProfile profile) async {
    try {
      final mcpRepo = await McpServerInfoStorage.instance;
      final servers = profile.activeMcpServerIds
          .map((id) => mcpRepo.getItem(id))
          .whereType<McpServer>()
          .toList();
      final names = <String>{};
      for (final s in servers) {
        for (final t in s.tools) {
          if (t.enabled) names.add(t.name);
        }
      }
      return names.toList();
    } catch (_) {
      return const <String>[];
    }
  }

  void dispose() {
    selectedProfile.dispose();
    mcpServers.dispose();
  }
}
