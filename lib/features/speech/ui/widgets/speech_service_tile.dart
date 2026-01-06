import 'package:flutter/material.dart';
import 'package:multigateway/core/speech/speech.dart';

class SpeechServiceTile extends StatelessWidget {
  final SpeechService service;
  final VoidCallback onDelete;

  const SpeechServiceTile({
    super.key,
    required this.service,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(service.id),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        leading: const Icon(Icons.drag_handle),
        title: Text(service.name),
        subtitle: Text(''),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
        onTap: () {
          // Navigate to edit page
        },
      ),
    );
  }
}
