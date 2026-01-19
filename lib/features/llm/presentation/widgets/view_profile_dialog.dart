import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/profile/profile.dart';
import 'package:multigateway/features/profiles/presentation/ui/edit_profile_screen.dart';

class ViewProfileDialog extends StatelessWidget {
  final ChatProfile profile;

  const ViewProfileDialog({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tl('AI Profile Details')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: tl('Edit'),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProfileScreen(profile: profile),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Theme.of(context).colorScheme.error,
            tooltip: tl('Delete'),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Avatar and Name
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Text(
                      profile.name.isNotEmpty
                          ? profile.name[0].toUpperCase()
                          : 'A',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tl('ID: ${profile.id.substring(0, 8)}...'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // System Prompt Section
              _buildSectionHeader(
                context,
                'System Prompt',
                Icons.psychology_outlined,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Text(
                  profile.config.systemPrompt.isNotEmpty
                      ? profile.config.systemPrompt
                      : 'No system prompt configured.',
                  style: const TextStyle(height: 1.5),
                ),
              ),
              const SizedBox(height: 32),

              // Parameters Grid
              _buildSectionHeader(context, 'Parameters', Icons.tune),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: [
                  _buildInfoCard(
                    context,
                    'Temperature',
                    profile.config.temperature?.toString() ?? 'Default',
                  ),
                  _buildInfoCard(
                    context,
                    'Top P',
                    profile.config.topP?.toString() ?? 'Default',
                  ),
                  _buildInfoCard(
                    context,
                    'Top K',
                    profile.config.topK?.toString() ?? 'Default',
                  ),
                  _buildInfoCard(
                    context,
                    'Stream',
                    profile.config.enableStream ? 'ON' : 'OFF',
                  ),
                  _buildInfoCard(
                    context,
                    'Context Window',
                    profile.config.contextWindow.toString(),
                  ),
                  _buildInfoCard(
                    context,
                    'Max Tokens',
                    profile.config.maxTokens.toString(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoCard(
                context,
                'Conversation Length',
                profile.config.conversationLength.toString(),
              ),

              // MCP Servers
              if (profile.activeMcpName.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  'agents.active_mcp_servers',
                  Icons.hub_outlined,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.activeMcpName
                      .map(
                        (id) => Chip(
                          label: Text(
                            id.substring(0, 8),
                          ), // Ideally show server name
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                        ),
                      )
                      .toList(),
                ),
              ],

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tl('Delete')),
        content: Text(tl('Are you sure you want to delete ${profile.name}?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tl('agents.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(tl('Delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = await ChatProfileStorage.init();
      await repo.deleteItem(profile.id);
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    }
  }
}
