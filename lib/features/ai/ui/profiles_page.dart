import 'package:flutter/material.dart';
import '../../../core/storage/ai_profile_repository.dart';
import '../../../core/models/ai/ai_profile.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/item_card.dart';
import 'add_profile_screen.dart';
import '../ai/presentation/view_profile_screen.dart';

import '../../../core/translate.dart';

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
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
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
      title: 'Delete',
      content: 'Are you sure you want to delete ${profile.name}?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirm == true) {
      await _deleteProfile(profile.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tl('AI Profile ${profile.name} has been deleted')),
        ),
      );
    }
  }
}
