import 'package:flutter/material.dart';

import '../../../../core/speech/speech.dart';
import '../views/edit_speechservice_screen.dart';

class SpeechServicesPage extends StatefulWidget {
  const SpeechServicesPage({super.key});

  @override
  State<SpeechServicesPage> createState() => _SpeechServicesPageState();
}

class _SpeechServicesPageState extends State<SpeechServicesPage> {
  List<SpeechService> _profiles = [];
  bool _isLoading = true;
  late TTSRepository _repository;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    _repository = await TTSRepository.init();
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
        title: Text(tl('TTS Profiles')),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTTSProfileScreen(),
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
            ? Center(child: Text(tl('No TTS profiles configured')))
            : ReorderableListView.builder(
                itemCount: _profiles.length,
                onReorder: _onReorder,
                itemBuilder: (context, index) =>
                    _buildProfileTile(_profiles[index]),
              ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final SpeechService item = _profiles.removeAt(oldIndex);
      _profiles.insert(newIndex, item);
    });
    _repository.saveOrder(_profiles.map((e) => e.id).toList());
  }

  Widget _buildProfileTile(SpeechService profile) {
    return Dismissible(
      key: ValueKey(profile.id),
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteProfile(profile.id);
        context.showSuccessSnackBar(tl('${profile.name} deleted'));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(
            _getServiceIcon(profile.tts.type),
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(profile.name),
        subtitle: Text(profile.tts.type.name.toUpperCase()),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).disabledColor,
        ),
        onTap: () async {
          // Edit functionality could be added here
        },
      ),
    );
  }

  IconData _getServiceIcon(ServiceType type) {
    switch (type) {
      case ServiceType.system:
        return Icons.settings_voice;
      case ServiceType.provider:
        return Icons.cloud;
    }
  }
}
