import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/profile/profile.dart';
import 'package:multigateway/features/llm/ui/widgets/view_profile_dialog.dart';
import 'package:multigateway/features/profiles/ui/edit_profile_screen.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:multigateway/shared/widgets/confirm_dialog.dart';
import 'package:multigateway/shared/widgets/empty_state.dart';
import 'package:multigateway/shared/widgets/item_card.dart';

class ChatProfilesScreen extends StatefulWidget {
  const ChatProfilesScreen({super.key});

  @override
  State<ChatProfilesScreen> createState() => _ChatProfilesScreenState();
}

class _ChatProfilesScreenState extends State<ChatProfilesScreen> {
  List<ChatProfile> _profiles = [];
  bool _isLoading = true;
  bool _isGridView = true;
  late ChatProfileStorage _repository;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    _repository = await ChatProfileStorage.init();
    if (!mounted) return;
    setState(() {
      _profiles = _repository.getItems();
      _isLoading = false;
    });
  }

  Future<void> _deleteProfile(String id) async {
    await _repository.deleteItem(id);
    _loadProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tl('Chat Profiles')),
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
      final ChatProfile item = _profiles.removeAt(oldIndex);
      _profiles.insert(newIndex, item);
    });
    _repository.saveOrder(_profiles.map((e) => e.id).toList());
  }

  void _viewProfile(ChatProfile profile) async {
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

  void _editProfile(ChatProfile profile) async {
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

  Future<void> _confirmDelete(ChatProfile profile) async {
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
        tl('Profile ${profile.name} has been deleted'),
      );
    }
  }
}
