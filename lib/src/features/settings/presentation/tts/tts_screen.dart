import 'package:flutter/material.dart';
import 'package:lmhub/src/core/storage/tts_repository.dart';
import 'package:lmhub/src/features/settings/domain/tts_profile.dart';
import 'add_tts_profile_screen.dart';

class TTSScreen extends StatefulWidget {
  const TTSScreen({super.key});

  @override
  State<TTSScreen> createState() => _TTSScreenState();
}

class _TTSScreenState extends State<TTSScreen> {
  List<TTSProfile> _profiles = [];
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
        title: const Text(
          'TTS Profiles',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profiles.isEmpty
          ? const Center(child: Text('No TTS profiles configured'))
          : ListView.separated(
              itemCount: _profiles.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  _buildProfileTile(_profiles[index]),
            ),
    );
  }

  Widget _buildProfileTile(TTSProfile profile) {
    return Dismissible(
      key: Key(profile.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteProfile(profile.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${profile.name} deleted')));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.shade50,
          child: Icon(_getServiceIcon(profile.type), color: Colors.purple),
        ),
        title: Text(profile.name),
        subtitle: Text(profile.type.name.toUpperCase()),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
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
      case TTSServiceType.elevenLabs:
        return Icons.graphic_eq;
    }
  }
}
