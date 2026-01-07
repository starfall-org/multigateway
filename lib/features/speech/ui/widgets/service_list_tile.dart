import 'package:flutter/material.dart';
import 'package:multigateway/core/speech/speech.dart';

/// Widget hiển thị một speech service trong list
class ServiceListTile extends StatelessWidget {
  final SpeechService service;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const ServiceListTile({
    super.key,
    required this.service,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(service.id),
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(
            _getServiceIcon(service.tts.type),
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(service.name),
        subtitle: Text(service.tts.type.name.toUpperCase()),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).disabledColor,
        ),
        onTap: onTap,
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