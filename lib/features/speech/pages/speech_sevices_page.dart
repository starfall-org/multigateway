import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';

import 'package:multigateway/core/speech/speech.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';


class SpeechServicesPage extends StatefulWidget {
  const SpeechServicesPage({super.key});

  @override
  State<SpeechServicesPage> createState() => _SpeechServicesPageState();
}

class _SpeechServicesPageState extends State<SpeechServicesPage> {
  List<SpeechService> _profiles = [];
  bool _isLoading = true;
  late SpeechServiceStorage _repository;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    _repository = await SpeechServiceStorage.init();
    setState(() {
      _profiles = _repository.getItems();
      _isLoading = false;
    });
  }

  Future<void> _deleteService(String id) async {
    await _repository.deleteItem(id);
    _loadServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tl('TTS Services')),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditSpeechServiceScreen(),
                ),
              );
              if (result == true) {
                _loadServices();
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
                    _buildServiceTile(_profiles[index]),
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

  Widget _buildServiceTile(SpeechService profile) {
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
        _deleteService(profile.id);
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
