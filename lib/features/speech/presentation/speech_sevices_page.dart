import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/speech/speech.dart';
import 'package:multigateway/features/speech/presentation/ui/edit_speech_service_screen.dart';
import 'package:multigateway/features/speech/presentation/widgets/service_list_tile.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:signals/signals_flutter.dart';

/// Màn hình quản lý speech services
class SpeechServicesPage extends StatefulWidget {
  const SpeechServicesPage({super.key});

  @override
  State<SpeechServicesPage> createState() => _SpeechServicesPageState();
}

class _SpeechServicesPageState extends State<SpeechServicesPage> {
  final profiles = signal<List<SpeechService>>([]);
  final isLoading = signal<bool>(true);
  late SpeechServiceStorage _repository;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    profiles.dispose();
    isLoading.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    _repository = await SpeechServiceStorage.init();
    // Wait for box to be ready
    await Future.delayed(const Duration(milliseconds: 100));
    profiles.value = _repository.getItems();
    isLoading.value = false;
  }

  Future<void> _deleteService(String id, String name) async {
    await _repository.deleteItem(id);
    _loadServices();
    if (mounted) {
      context.showSuccessSnackBar(tl('$name deleted'));
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    final currentProfiles = List<SpeechService>.from(profiles.value);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final SpeechService item = currentProfiles.removeAt(oldIndex);
    currentProfiles.insert(newIndex, item);
    profiles.value = currentProfiles;
    _repository.saveOrder(currentProfiles.map((e) => e.id).toList());
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
              tl('TTS Services'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              tl('Manage speech services'),
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
        child: Watch((context) {
          if (isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profiles.value.isEmpty) {
            return Center(child: Text(tl('No TTS profiles configured')));
          }

          return ReorderableListView.builder(
            itemCount: profiles.value.length,
            onReorder: _onReorder,
            itemBuilder: (context, index) {
              final profile = profiles.value[index];
              return ServiceListTile(
                key: ValueKey(profile.id),
                service: profile,
                onTap: () {
                  // Edit functionality could be added here
                },
                onDismissed: () => _deleteService(profile.id, profile.name),
              );
            },
          );
        }),
      ),
    );
  }
}
