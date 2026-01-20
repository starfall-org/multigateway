import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/core/llm/models/llm_provider_models.dart';
import 'package:multigateway/core/profile/profile.dart';
import 'package:multigateway/features/home/presentation/controllers/home_controller.dart';
import 'package:multigateway/features/home/presentation/widgets/mcp_item_tile.dart';
import 'package:multigateway/features/home/presentation/widgets/section_header.dart';
import 'package:multigateway/shared/utils/model_tools.dart';
import 'package:multigateway/shared/widgets/bottom_sheet.dart';
import 'package:signals_flutter/signals_flutter.dart';

class QuickActionsSheet extends StatefulWidget {
  final ChatController controller;
  final ScrollController scrollController;

  const QuickActionsSheet({
    super.key,
    required this.controller,
    required this.scrollController,
  });

  @override
  State<QuickActionsSheet> createState() => _QuickActionsSheetState();

  static void show(BuildContext context, ChatController controller) {
    CustomBottomSheet.show(
      context,
      initialChildSize: 0.7,
      minChildSize: 0.45,
      maxChildSize: 0.9,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      builder: (ctx, scrollController) => QuickActionsSheet(
        controller: controller,
        scrollController: scrollController,
      ),
    );
  }
}

class _QuickActionsSheetState extends State<QuickActionsSheet> {
  late ChatProfile _profile;

  @override
  void initState() {
    super.initState();
    widget.controller.loadMcpClients();
    _profile = widget.controller.profile.selectedProfile.value!;
  }

  void _updateProfile() {
    widget.controller.updateProfile(_profile);
    setState(() {});
  }

  void _applyProfileUpdate(ChatProfile profile) {
    _profile = profile;
    _updateProfile();
  }

  void _toggleMcpItem(String mcpId, bool enabled) {
    final currentMcp = List<ActiveMcp>.from(_profile.activeMcp);

    if (enabled) {
      if (!currentMcp.any((s) => s.id == mcpId)) {
        final mcpTools = widget.controller.profile.mcpTools.value.firstWhere(
          (s) => s.id == mcpId,
        );

        final allToolNames = mcpTools.tools
            .map((t) => t['name'] as String)
            .toList();

        currentMcp.add(ActiveMcp(id: mcpId, activeToolNames: allToolNames));
      }
    } else {
      currentMcp.removeWhere((s) => s.id == mcpId);
    }

    _applyProfileUpdate(_profile.copyWith(activeMcp: currentMcp));
  }

  void _toggleMcpTool(String mcpId, String toolName, bool enabled) {
    final currentMcp = List<ActiveMcp>.from(_profile.activeMcp);
    final index = currentMcp.indexWhere((s) => s.id == mcpId);

    if (index != -1) {
      final server = currentMcp[index];
      final currentTools = List<String>.from(server.activeToolNames);

      if (enabled) {
        if (!currentTools.contains(toolName)) currentTools.add(toolName);
      } else {
        currentTools.remove(toolName);
      }

      currentMcp[index] = ActiveMcp(
        id: server.id,
        activeToolNames: currentTools,
      );

      _applyProfileUpdate(_profile.copyWith(activeMcp: currentMcp));
    }
  }

  bool _isModelToolEnabled(
    String providerId,
    String modelId,
    String toolName,
  ) {
    return _profile.activeModelTools.any(
      (tool) =>
          tool.providerId == providerId &&
          tool.modelId == modelId &&
          toolNameMatches(tool.toolName, toolName),
    );
  }

  void _toggleModelTool(
    String providerId,
    String modelId,
    String toolName,
    bool enabled,
  ) {
    final currentTools = List<ModelTool>.from(_profile.activeModelTools);
    final index = currentTools.indexWhere(
      (tool) =>
          tool.providerId == providerId &&
          tool.modelId == modelId &&
          toolNameMatches(tool.toolName, toolName),
    );

    if (enabled) {
      if (index == -1) {
        currentTools.add(
          ModelTool(
            providerId: providerId,
            modelId: modelId,
            toolName: toolName,
          ),
        );
      }
    } else if (index != -1) {
      currentTools.removeAt(index);
    }

    _applyProfileUpdate(_profile.copyWith(activeModelTools: currentTools));
  }

  ({LlmProviderInfo? provider, LlmModel? model}) _resolveProviderAndModel({
    required List<LlmProviderInfo> providers,
    required Map<String, List<LlmModel>> providerModels,
    required String? selectedProviderName,
    required String? selectedModelName,
  }) {
    if (providers.isEmpty) return (provider: null, model: null);

    final provider = providers.firstWhere(
      (p) => p.name == selectedProviderName,
      orElse: () => providers.first,
    );
    final models = providerModels[provider.id] ?? const <LlmModel>[];
    if (models.isEmpty) return (provider: provider, model: null);

    final model = models.firstWhere(
      (m) => m.id == selectedModelName,
      orElse: () => models.first,
    );
    return (provider: provider, model: model);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            tl('Tools Configuration'),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(),
        Expanded(
          child: Watch((context) {
            final selectedProfile =
                widget.controller.profile.selectedProfile.value;
            if (selectedProfile != null) {
              _profile = selectedProfile;
            }

            final mcpItems = widget.controller.profile.mcpItems.value;
            final providers = widget.controller.model.providers.value;
            final providerModels =
                widget.controller.model.providerModels.value;
            final selectedProviderName =
                widget.controller.model.selectedProviderName.value;
            final selectedModelName =
                widget.controller.model.selectedModelName.value;

            final selection = _resolveProviderAndModel(
              providers: providers,
              providerModels: providerModels,
              selectedProviderName: selectedProviderName,
              selectedModelName: selectedModelName,
            );
            final provider = selection.provider;
            final model = selection.model;
            final modelToolOptions =
                provider != null ? modelToolsForProvider(provider) : const [];

            return ListView(
              controller: widget.scrollController,
              children: [
                const SectionHeader(title: 'Model Tools'),
                if (provider == null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      tl('No providers configured'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  )
                else if (model == null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      tl('No models available'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  )
                else if (modelToolOptions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      tl('No server-side tools for this provider.'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Text(
                      '${provider.name} · ${model.displayName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ),
                  ...modelToolOptions.map((option) {
                    final enabled = _isModelToolEnabled(
                      provider.id,
                      model.id,
                      option.name,
                    );
                    return SwitchListTile(
                      title: Text(tl(option.title)),
                      subtitle: Text(tl(option.description)),
                      value: enabled,
                      onChanged: (value) => _toggleModelTool(
                        provider.id,
                        model.id,
                        option.name,
                        value,
                      ),
                    );
                  }),
                ],
                const SectionHeader(title: 'MCP Servers'),
                if (mcpItems.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      tl('No MCP servers configured.'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ),
                ...mcpItems.map((client) {
                  return McpItemTile(
                    client: client,
                    toolsList: widget.controller.profile.mcpTools.value
                        .firstWhere((t) => t.id == client.id),
                    profile: _profile,
                    onServerToggle: _toggleMcpItem,
                    onToolToggle: _toggleMcpTool,
                  );
                }),
              ],
            );
          }),
        ),
      ],
    );
  }
}
