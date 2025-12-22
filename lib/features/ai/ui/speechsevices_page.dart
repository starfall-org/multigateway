import 'package:flutter/material.dart';
import '../../core/storage/tts_repository.dart';
import '../../core/models/speech_service.dart';
import 'sub_screens/add_tts_profile_screen.dart';

import '../../core/translate.dart';

class TTSScreen extends StatefulWidget {
  const TTSScreen({super.key});

  @override
  State<TTSScreen> createState() => _TTSScreenState();
}

class _TTSScreenState extends State<TTSScreen> {
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
                : ListView.separated(
                    itemCount: _profiles.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) =>
                        _buildProfileTile(_profiles[index]),
                  ),
      ),
    );
  }

  Widget _buildProfileTile(SpeechService profile) {
    return Dismissible(
      key: Key(profile.id),
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteProfile(profile.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(tl('${profile.name} deleted'))));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(
            _getServiceIcon(profile.type),
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(profile.name),
        subtitle: Text(profile.type.name.toUpperCase()),
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

  IconData _getServiceIcon(TTSServiceType type) {
    switch (type) {
      case TTSServiceType.system:
        return Icons.settings_voice;
      case TTSServiceType.provider:
        return Icons.cloud;
    }
  }
}
