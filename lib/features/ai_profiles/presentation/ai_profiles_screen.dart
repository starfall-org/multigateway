import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/storage/ai_profile_repository.dart';
import '../../../core/models/ai/ai_profile.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/item_card.dart';
import 'add_profile_screen.dart';
import 'view_profile_screen.dart';

class AIProfilesScreen extends StatefulWidget {
  const AIProfilesScreen({super.key});

  @override
  State<AIProfilesScreen> createState() => _AIProfilesScreenState();
}

class _AIProfilesScreenState extends State<AIProfilesScreen> {
  List<AIProfile> _profiles = [];
  bool _isLoading = true;
  late AIProfileRepository _repository;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    _repository = await AIProfileRepository.init();
    if (!mounted) return;
    setState(() {
      _profiles = _repository.getProfiles();
      _isLoading = false;
    });
  }

  Future<void> _deleteProfile(String id) async {
    await _repository.deleteProfile(id);
    _loadProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('agents.title'.tr()),
        actions: [
          AddAction(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProfileScreen(),
                ),
              );
              if (result == true) {
                _loadProfiles();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profiles.isEmpty
          ? EmptyState(
              message: 'agents.no_agents'.tr(),
              actionLabel: 'agents.add_new_agent'.tr(),
              onAction: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddProfileScreen(),
                  ),
                );
                if (result == true) {
                  _loadProfiles();
                }
              },
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _profiles.length,
              itemBuilder: (context, index) {
                final profile = _profiles[index];
                return ItemCard(
                  title: profile.name,
                  subtitle: profile.config.systemPrompt,
                  icon: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Text(
                      profile.name.isNotEmpty
                          ? profile.name[0].toUpperCase()
                          : 'A',
                    ),
                  ),
                  onTap: () async {
                    // In "Agent list" selection mode: set as selected and pop
                    await _repository.setSelectedProfileId(profile.id);
                    if (!context.mounted) return;
                    Navigator.pop(context, true);
                  },
                  onView: () => _viewProfile(profile),
                  onEdit: () => _editProfile(profile),
                  onDelete: () => _confirmDelete(profile),
                );
              },
            ),
    );
  }

  void _viewProfile(AIProfile profile) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewProfileScreen(profile: profile),
      ),
    );
    if (result == true) {
      _loadProfiles();
    }
  }

  void _editProfile(AIProfile profile) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProfileScreen(profile: profile),
      ),
    );
    if (result == true) {
      _loadProfiles();
    }
  }

  Future<void> _confirmDelete(AIProfile profile) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: 'common.delete'.tr(),
      content: 'agents.delete_confirm'.tr(args: [profile.name]),
      confirmLabel: 'common.delete'.tr(),
      isDestructive: true,
    );
    if (confirm == true) {
      await _deleteProfile(profile.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('agents.agent_deleted'.tr(args: [profile.name])),
        ),
      );
    }
  }
}
