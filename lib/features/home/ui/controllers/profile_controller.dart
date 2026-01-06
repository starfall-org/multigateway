import 'package:flutter/material.dart';
import 'package:mcp/mcp.dart';
import 'package:multigateway/core/mcp/storage/mcp_server_repository.dart';
import 'package:multigateway/core/profile/profile.dart';

/// Controller responsible for AI profile and MCP server management
class ProfileController extends ChangeNotifier {
  final ChatProfileStorage aiProfileRepository;
  final McpServerStorage mcpServerStorage;

  ChatProfile? selectedProfile;
  List<McpServer> mcpServers = [];

  ProfileController({
    required this.aiProfileRepository,
    required this.mcpServerStorage,
  });

  Future<void> loadSelectedProfile() async {
    final profile = await aiProfileRepository.getOrInitSelectedProfile();
    selectedProfile = profile;
    notifyListeners();
  }

  Future<void> updateProfile(ChatProfile profile) async {
    selectedProfile = profile;
    await aiProfileRepository.saveItem(profile);
    notifyListeners();
  }

  Future<void> loadMcpServers() async {
    mcpServers = mcpServerStorage.getItems().whereType<McpServer>().toList();
    notifyListeners();
  }

  Future<List<String>> snapshotEnabledToolNames(ChatProfile profile) async {
    try {
      final mcpRepo = await McpServerStorage.init();
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
}
