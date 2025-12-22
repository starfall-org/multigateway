part of 'chat_viewmodel.dart';

extension ChatViewModelActions on ChatViewModel {
  Future<List<String>> _snapshotEnabledToolNames(AIProfile profile) async {
    try {
      final mcpRepo = await MCPRepository.init();
      final servers = profile.activeMCPServerIds
          .map((id) => mcpRepo.getItem(id))
          .whereType<MCPServer>()
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
