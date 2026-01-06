import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/profile/profile.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../settings/ui/widgets/settings_card.dart';
import '../controllers/edit_profile_controller.dart';
import '../widgets/view_profile_dialog.dart';

/// Helper để tạo theme-aware image cho edit profile screen
Widget _buildThemeAwareImageForProfile(BuildContext context, Widget child) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return ColorFiltered(
    colorFilter: ColorFilter.mode(
      isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.1),
      BlendMode.overlay,
    ),
    child: child,
  );
}

class AddProfileScreen extends StatefulWidget {
  final AIProfile? profile;

  const AddProfileScreen({super.key, this.profile});

  @override
  State<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen>
    with SingleTickerProviderStateMixin {
  late AddAgentViewModel _viewModel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to show/hide FAB based on tab
    });
    _viewModel = AddAgentViewModel();
    _viewModel.initialize(widget.profile);
    _viewModel.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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

    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isEditing)
            FloatingActionButton(
              heroTag: "info",
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ViewProfileDialog(profile: widget.profile!),
                  ),
                );
              },
              child: const Icon(Icons.info_outline),
            ),
          if (isEditing) const SizedBox(width: 16),
          FloatingActionButton.extended(
            heroTag: "save",
            onPressed: _saveAgent,
            label: Text(tl('Save')),
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.person), text: 'Info'),
            Tab(icon: Icon(Icons.settings), text: 'Config'),
            Tab(icon: Icon(Icons.build), text: 'Tools'),
          ],
        ),
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: TabBarView(
          controller: _tabController,
          children: [_buildGeneralTab(), _buildRequestTab(), _buildToolsTab()],
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
                  GestureDetector(
                    onTap: () {
                      _viewModel.pickImage(context);
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: _viewModel.avatarController.text.isNotEmpty
                          ? _buildThemeAwareImageForProfile(
                              context,
                              Image.file(
                                File(_viewModel.avatarController.text),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 50,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
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
              label: 'AI Profile Name',
              prefixIcon: Icons.badge_outlined,
            ),
            const SizedBox(height: 24),

            // System Prompt
            CustomTextField(
              controller: _viewModel.promptController,
              label: 'System Prompt',
              maxLines: 6,
              prefixIcon: Icons.description_outlined,
            ),
            const SizedBox(height: 32),

            // Persist chat selection override
            Text(
              tl('Persist Selection'),
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
                      tl('Always On'),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  ButtonSegment(
                    value: PersistOverride.off,
                    label: Text(
                      tl('Always Off'),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  ButtonSegment(
                    value: PersistOverride.disable,
                    label: Text(
                      tl('Follow Global'),
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
              tl('Parameters'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            SettingsCard(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(tl('Stream')),
                    subtitle: Text(tl('Enable streaming responses')),
                    value: _viewModel.enableStream,
                    onChanged: (value) => _viewModel.toggleStream(value),
                  ),
                  const Divider(),

                  // Top P
                  SwitchListTile(
                    title: Text(tl('Top P')),
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
                    title: Text(tl('Top K')),
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
                    title: Text(tl('Temperature')),
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
              label: 'Context Window',
              value: _viewModel.contextWindowValue,
              onChanged: (v) => _viewModel.setContextWindowValue(v),
              icon: Icons.window_outlined,
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              label: 'Conversation Length',
              value: _viewModel.conversationLengthValue,
              onChanged: (v) => _viewModel.setConversationLengthValue(v),
              icon: Icons.history_outlined,
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              label: 'Max Tokens',
              value: _viewModel.maxTokensValue,
              onChanged: (v) => _viewModel.setMaxTokensValue(v),
              icon: Icons.token_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_viewModel.availableMCPServers.isNotEmpty) ...[
              Text(
                tl('MCP Servers'),
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
                  child: Text(tl('No MCP servers available')),
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
