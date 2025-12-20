import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/models/ai/ai_profile.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../settings/widgets/settings_card.dart';
import '../viewmodel/add_agent_viewmodel.dart';
import 'view_profile_screen.dart';

class AddProfileScreen extends StatefulWidget {
  final AIProfile? profile;

  const AddProfileScreen({super.key, this.profile});

  @override
  State<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen> {
  late AddAgentViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddAgentViewModel();
    _viewModel.initialize(widget.profile);
    _viewModel.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _saveAgent() async {
    await _viewModel.saveAgent(widget.profile, context);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.profile != null;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEditing ? 'agents.edit_agent'.tr() : 'agents.add_new_agent'.tr(),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'General'),
              Tab(text: 'Request'),
              Tab(text: 'MCP'),
            ],
          ),
          actions: [
            if (isEditing)
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'agents.agent_details'.tr(),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ViewProfileScreen(profile: widget.profile!),
                    ),
                  );
                },
              ),
            IconButton(icon: const Icon(Icons.check), onPressed: _saveAgent),
          ],
        ),
        body: TabBarView(
          children: [
            _buildGeneralTab(),
            _buildRequestTab(),
            _buildMCPServerTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            CustomTextField(
              controller: _viewModel.nameController,
              label: 'agents.name'.tr(),
              prefixIcon: Icons.badge_outlined,
            ),
            const SizedBox(height: 24),

            // System Prompt
            CustomTextField(
              controller: _viewModel.promptController,
              label: 'agents.system_prompt'.tr(),
              maxLines: 6,
              prefixIcon: Icons.description_outlined,
            ),
            const SizedBox(height: 32),

            // Persist chat selection override
            Text(
              'agents.persist_selection'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<PersistOverride>(
                segments: [
                  ButtonSegment(
                    value: PersistOverride.on,
                    label: Text(
                      'agents.persist_on'.tr(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  ButtonSegment(
                    value: PersistOverride.off,
                    label: Text(
                      'agents.persist_off'.tr(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  ButtonSegment(
                    value: PersistOverride.disable,
                    label: Text(
                      'agents.persist_disable'.tr(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
                selected: {_viewModel.persistOverride},
                onSelectionChanged: (Set<PersistOverride> newSelection) {
                  _viewModel.setPersistOverride(newSelection.first);
                },
                showSelectedIcon: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Parameters Section
            Text(
              'agents.parameters'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            SettingsCard(
              child: Column(
                children: [
                  SwitchListTile(
                      title: Text('agents.stream'.tr()),
                      subtitle: Text('agents.stream_desc'.tr()),
                      value: _viewModel.enableStream,
                      onChanged: (value) => _viewModel.toggleStream(value),
                    ),
                    const Divider(),

                    // Top P
                    SwitchListTile(
                      title: Text('agents.top_p'.tr()),
                      value: _viewModel.isTopPEnabled,
                      onChanged: (value) => _viewModel.toggleTopP(value),
                    ),
                    if (_viewModel.isTopPEnabled)
                      _buildSlider(
                        value: _viewModel.topPValue,
                        min: 0,
                        max: 1,
                        divisions: 20,
                        label: _viewModel.topPValue.toStringAsFixed(2),
                        onChanged: (v) => _viewModel.setTopPValue(v),
                      ),

                    const Divider(),
                    // Top K
                    SwitchListTile(
                      title: Text('agents.top_k'.tr()),
                      value: _viewModel.isTopKEnabled,
                      onChanged: (value) => _viewModel.toggleTopK(value),
                    ),
                    if (_viewModel.isTopKEnabled)
                      _buildSlider(
                        value: _viewModel.topKValue,
                        min: 1,
                        max: 100,
                        divisions: 99,
                        label: _viewModel.topKValue.round().toString(),
                        onChanged: (v) => _viewModel.setTopKValue(v),
                      ),

                    const Divider(),
                    // Temperature
                    SwitchListTile(
                      title: Text('agents.temperature'.tr()),
                      value: _viewModel.isTemperatureEnabled,
                      onChanged: (value) => _viewModel.toggleTemperature(value),
                    ),
                    if (_viewModel.isTemperatureEnabled)
                      _buildSlider(
                        value: _viewModel.temperatureValue,
                        min: 0,
                        max: 2,
                        divisions: 20,
                        label: _viewModel.temperatureValue.toStringAsFixed(2),
                        onChanged: (v) => _viewModel.setTemperatureValue(v),
                      ),
                  ],
              ),
            ),
            const SizedBox(height: 24),

            // Context window etc.
            _buildNumberField(
              label: 'agents.context_window'.tr(),
              value: _viewModel.contextWindowValue,
              onChanged: (v) => _viewModel.setContextWindowValue(v),
              icon: Icons.window_outlined,
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              label: 'agents.conversation_length'.tr(),
              value: _viewModel.conversationLengthValue,
              onChanged: (v) => _viewModel.setConversationLengthValue(v),
              icon: Icons.history_outlined,
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              label: 'agents.max_tokens'.tr(),
              value: _viewModel.maxTokensValue,
              onChanged: (v) => _viewModel.setMaxTokensValue(v),
              icon: Icons.token_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMCPServerTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_viewModel.availableMCPServers.isNotEmpty) ...[
              Text(
                'agents.mcp_servers'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SettingsCard(
                child: Column(
                  children: _viewModel.availableMCPServers.map((server) {
                    return CheckboxListTile(
                      title: Text(server.name),
                      value: _viewModel.selectedMCPServerIds.contains(
                        server.id,
                      ),
                      onChanged: (bool? value) {
                        _viewModel.toggleMCPServer(server.id);
                      },
                    );
                  }).toList(),
                ),
              ),
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Text('agents.no_mcp_servers'.tr()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: label,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              label,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
    required IconData icon,
  }) {
    return CustomTextField(
      keyboardType: TextInputType.number,
      label: label,
      prefixIcon: icon,
      controller: TextEditingController(text: value.toString()),
      onChanged: (text) {
        final val = int.tryParse(text);
        if (val != null) onChanged(val);
      },
    );
  }
}
