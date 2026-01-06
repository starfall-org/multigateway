import 'package:flutter/material.dart';
import '../../../../core/profile/profile.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/item_card.dart';
import '../views/edit_profile_screen.dart';
import '../widgets/view_profile_dialog.dart';

class AIProfilesScreen extends StatefulWidget {
  const AIProfilesScreen({super.key});

  @override
  State<AIProfilesScreen> createState() => _AIProfilesScreenState();
}

class _AIProfilesScreenState extends State<AIProfilesScreen> {
  List<AIProfile> _profiles = [];
  bool _isLoading = true;
  bool _isGridView = true;
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
        title: Text(tl('AI Profiles')),
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
          ViewToggleAction(
            isGrid: _isGridView,
            onChanged: (val) {
              setState(() {
                _isGridView = val;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _profiles.isEmpty
            ? EmptyState(
                message: 'No AI Profiles found',
                actionLabel: 'Add AI Profile',
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
            : _isGridView
            ? GridView.builder(
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
              )
            : ReorderableListView.builder(
                itemCount: _profiles.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  final profile = _profiles[index];
                  return ListTile(
                    key: ValueKey(profile.id),
                    title: Text(profile.name),
                    subtitle: Text(
                      profile.config.systemPrompt,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Text(
                        profile.name.isNotEmpty
                            ? profile.name[0].toUpperCase()
                            : 'A',
                      ),
                    ),
                    trailing: const Icon(Icons.drag_handle),
                    onTap: () async {
                      await _repository.setSelectedProfileId(profile.id);
                      if (!context.mounted) return;
                      Navigator.pop(context, true);
                    },
                  );
                },
              ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final AIProfile item = _profiles.removeAt(oldIndex);
      _profiles.insert(newIndex, item);
    });
    _repository.saveOrder(_profiles.map((e) => e.id).toList());
  }

  void _viewProfile(AIProfile profile) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewProfileDialog(profile: profile),
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
      title: 'Delete',
      content: 'Are you sure you want to delete ${profile.name}?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirm == true) {
      await _deleteProfile(profile.id);
      if (!mounted) return;
      context.showSuccessSnackBar(
        tl('AI Profile ${profile.name} has been deleted'),
      );
    }
  }
}
