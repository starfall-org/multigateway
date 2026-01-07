import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/speech/speech.dart';
import 'package:multigateway/features/speech/ui/edit_speech_service_screen.dart';
import 'package:multigateway/features/speech/ui/widgets/service_list_tile.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';

/// Màn hình quản lý speech services
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

  Future<void> _deleteService(String id, String name) async {
    await _repository.deleteItem(id);
    _loadServices();
    if (mounted) {
      context.showSuccessSnackBar(tl('$name deleted'));
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tl('TTS Services'),
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              tl('Manage speech services'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.5,
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
            ? const Center(child: CircularProgressIndicator())
            : _profiles.isEmpty
                ? Center(child: Text(tl('No TTS profiles configured')))
                : ReorderableListView.builder(
                    itemCount: _profiles.length,
                    onReorder: _onReorder,
                    itemBuilder: (context, index) {
                      final profile = _profiles[index];
                      return ServiceListTile(
                        key: ValueKey(profile.id),
                        service: profile,
                        onTap: () {
                          // Edit functionality could be added here
                        },
                        onDismissed: () => _deleteService(
                          profile.id,
                          profile.name,
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}