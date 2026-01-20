import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/profile/profile.dart';
import 'package:multigateway/features/profiles/presentation/ui/edit_profile_screen.dart';
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
  bool _isGridView = true;
  ChatProfileStorage? _repository;
  Stream<List<ChatProfile>>? _profilesStream;
  String? _selectedProfileId;

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    _repository = await ChatProfileStorage.init();
    if (mounted) {
      setState(() {
        _profilesStream = _repository!.itemsStream;
        _selectedProfileId = _repository!.getSelectedProfileId();
      });
    }
  }

  Future<void> _deleteProfile(String id) async {
    await _repository?.deleteItem(id);
  }

  Future<void> _setAsDefault(ChatProfile profile) async {
    await _repository?.setSelectedProfileId(profile.id);
    if (mounted) {
      context.showSuccessSnackBar(tl('${profile.name} set as default profile'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tl('Chat Profiles'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              tl('Manage chat profiles'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.5,
        actions: [
          AddAction(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProfileScreen(),
                ),
              );
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
        child: _profilesStream == null
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<List<ChatProfile>>(
                stream: _profilesStream,
                initialData: _profiles,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      snapshot.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final profiles = snapshot.data ?? [];
                  _profiles = profiles;
                  // Update selected ID whenever stream emits
                  _selectedProfileId = _repository?.getSelectedProfileId();

                  if (profiles.isEmpty) {
                    return EmptyState(
                      message: 'No AI Profiles found',
                      actionLabel: 'Add AI Profile',
                      onAction: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddProfileScreen(),
                          ),
                        );
                      },
                    );
                  }

                  return _isGridView
                      ? _buildGridView(colorScheme)
                      : _buildListView(colorScheme);
                },
              ),
      ),
    );
  }

  Widget _buildGridView(ColorScheme colorScheme) {
    return GridView.builder(
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
        final isDefault = profile.id == _selectedProfileId;

        return ItemCard(
          title: profile.name,
          subtitle: profile.config.systemPrompt,
          icon: Stack(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'A',
                ),
              ),
              if (isDefault)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 8,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () => _editProfile(profile),
          menuItems: _buildMenuItems(profile, isDefault),
        );
      },
    );
  }

  Widget _buildListView(ColorScheme colorScheme) {
    return ReorderableListView.builder(
      itemCount: _profiles.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      onReorder: _onReorder,
      itemBuilder: (context, index) {
        final profile = _profiles[index];
        final isDefault = profile.id == _selectedProfileId;

        return ListTile(
          key: ValueKey(profile.id),
          title: Row(
            children: [
              Expanded(child: Text(profile.name)),
              if (isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tl('Default'),
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Text(
            profile.config.systemPrompt,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'A',
                ),
              ),
              if (isDefault)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 8,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) => _handleMenuAction(value, profile),
                itemBuilder: (context) =>
                    _buildPopupMenuItems(profile, isDefault),
              ),
              const Icon(Icons.drag_handle),
            ],
          ),
          onTap: () => _editProfile(profile),
        );
      },
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(
    ChatProfile profile,
    bool isDefault,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return [
      if (!isDefault)
        PopupMenuItem<String>(
          value: 'set_default',
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: colorScheme.primary),
              const SizedBox(width: 12),
              Text(tl('Set as Default')),
            ],
          ),
        ),
      PopupMenuItem<String>(
        value: 'edit',
        child: Row(
          children: [
            Icon(Icons.edit, color: colorScheme.onSurface),
            const SizedBox(width: 12),
            Text(tl('Edit')),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, color: colorScheme.error),
            const SizedBox(width: 12),
            Text(tl('Delete'), style: TextStyle(color: colorScheme.error)),
          ],
        ),
      ),
    ];
  }

  List<ItemCardMenuItem> _buildMenuItems(ChatProfile profile, bool isDefault) {
    return [
      if (!isDefault)
        ItemCardMenuItem(
          icon: Icons.check_circle_outline,
          label: tl('Set as Default'),
          onTap: () => _setAsDefault(profile),
        ),
      ItemCardMenuItem(
        icon: Icons.edit,
        label: tl('Edit'),
        onTap: () => _editProfile(profile),
      ),
      ItemCardMenuItem(
        icon: Icons.delete,
        label: tl('Delete'),
        onTap: () => _confirmDelete(profile),
        isDestructive: true,
      ),
    ];
  }

  void _handleMenuAction(String action, ChatProfile profile) {
    switch (action) {
      case 'set_default':
        _setAsDefault(profile);
        break;
      case 'edit':
        _editProfile(profile);
        break;
      case 'delete':
        _confirmDelete(profile);
        break;
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final ChatProfile item = _profiles.removeAt(oldIndex);
      _profiles.insert(newIndex, item);
    });
    _repository?.saveOrder(_profiles.map((e) => e.id).toList());
  }

  void _editProfile(ChatProfile profile) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProfileScreen(profile: profile),
      ),
    );
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
