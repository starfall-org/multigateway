import 'package:flutter/material.dart';
import 'package:ai_gateway/core/models/settings/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class GeminiProviderWidget extends StatelessWidget {
  final ProviderType selectedType;
  final Function(ProviderType) onTypeChanged;

  const GeminiProviderWidget({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'settings.provider_type'.tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<ProviderType>(
            initialValue: selectedType,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            items: ProviderType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onTypeChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}