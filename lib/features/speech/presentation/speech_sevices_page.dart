import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/speech/speech.dart';
import 'package:multigateway/features/speech/presentation/ui/edit_speech_service_screen.dart';
import 'package:multigateway/features/speech/presentation/widgets/service_list_tile.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';

/// Màn hình quản lý speech services
class SpeechServicesPage extends StatefulWidget {
  const SpeechServicesPage({super.key});

  @override
  State<SpeechServicesPage> createState() => _SpeechServicesPageState();
}

class _SpeechServicesPageState extends State<SpeechServicesPage> {
  SpeechServiceStorage? _repository;
  Stream<List<SpeechService>>? _serviceStream;
  List<SpeechService> _services = [];

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    _repository = await SpeechServiceStorage.init();
    if (mounted) {
      setState(() {
        _serviceStream = _repository!.itemsStream;
        _services = _repository!.getItems();
      });
    }
  }

  Future<void> _deleteService(String id, String name) async {
    await _repository?.deleteItem(id);
    if (mounted) {
      context.showSuccessSnackBar(tl('$name deleted'));
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final SpeechService item = _services.removeAt(oldIndex);
    _services.insert(newIndex, item);
    _repository?.saveOrder(_services.map((e) => e.id).toList());
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
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditSpeechServiceScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: _serviceStream == null
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<List<SpeechService>>(
                stream: _serviceStream,
                initialData: _services,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      snapshot.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data ?? [];
                  _services = data;

                  if (data.isEmpty) {
                    return Center(
                      child: Text(tl('No TTS profiles configured')),
                    );
                  }

                  return ReorderableListView.builder(
                    itemCount: data.length,
                    onReorder: _onReorder,
                    itemBuilder: (context, index) {
                      final profile = data[index];
                      return ServiceListTile(
                        key: ValueKey(profile.id),
                        service: profile,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditSpeechServiceScreen(service: profile),
                            ),
                          );
                        },
                        onDismissed: () =>
                            _deleteService(profile.id, profile.name),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
