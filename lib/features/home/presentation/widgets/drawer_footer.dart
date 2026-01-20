import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/profile/profile.dart';

/// Footer của drawer với profile button và user info
class DrawerFooter extends StatelessWidget {
  final ChatProfile? selectedProfile;
  final VoidCallback? onAgentChanged;

  const DrawerFooter({super.key, this.selectedProfile, this.onAgentChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: _ActiveProfileButton(
        selectedProfile: selectedProfile,
        onAgentChanged: onAgentChanged,
      ),
    );
  }
}

/// Button hiển thị active profile với popup menu
class _ActiveProfileButton extends StatefulWidget {
  final ChatProfile? selectedProfile;
  final VoidCallback? onAgentChanged;

  const _ActiveProfileButton({this.selectedProfile, this.onAgentChanged});

  @override
  State<_ActiveProfileButton> createState() => _ActiveProfileButtonState();
}

class _ActiveProfileButtonState extends State<_ActiveProfileButton> {
  List<ChatProfile> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final storage = await ChatProfileStorage.init();
    if (!mounted) return;
    setState(() {
      _profiles = storage.getItems();
      _isLoading = false;
    });
  }

  Future<void> _selectProfile(ChatProfile profile) async {
    final storage = await ChatProfileStorage.init();
    await storage.setSelectedProfileId(profile.id);
    widget.onAgentChanged?.call();
  }

  void _showProfileMenu(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);

    showMenu<ChatProfile>(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy - (_profiles.length * 56.0) - 16,
        buttonPosition.dx + button.size.width,
        buttonPosition.dy,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surface,
      elevation: 8,
      items: _profiles.map((profile) {
        final isSelected = profile.id == widget.selectedProfile?.id;
        return PopupMenuItem<ChatProfile>(
          value: profile,
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorScheme.tertiary, colorScheme.primary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    profile.name
                        .split(' ')
                        .map((word) => word.isNotEmpty ? word[0] : '')
                        .take(2)
                        .join()
                        .toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  profile.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
            ],
          ),
        );
      }).toList(),
    ).then((selectedProfile) {
      if (selectedProfile != null) {
        _selectProfile(selectedProfile);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final profileName = widget.selectedProfile?.name ?? tl('Standard Gateway');

    return InkWell(
      onTap: _isLoading ? null : () => _showProfileMenu(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          border: Border.all(color: colorScheme.outlineVariant, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorScheme.tertiary, colorScheme.primary],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  profileName
                      .split(' ')
                      .map((word) => word.isNotEmpty ? word[0] : '')
                      .take(2)
                      .join()
                      .toUpperCase(),
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tl('Active Profile'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                  Text(
                    profileName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.unfold_more,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
