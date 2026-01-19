import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/llm/presentation/controllers/edit_provider_controller.dart';
import 'package:multigateway/shared/widgets/custom_text_field.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Section cấu hình HTTP (LlmProviderConfig)
class HttpConfigSection extends StatelessWidget {
  final EditProviderController controller;

  const HttpConfigSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Watch((context) {
      final headers = controller.headers.value;

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Custom URLs
          _buildSectionTitle(context, tl('Custom URLs')),
          const SizedBox(height: 8),
          CustomTextField(
            signal: controller.customListModelsUrl,
            label: tl('List Models URL'),
            hint: tl('e.g., /models or full URL'),
            prefixIcon: Icons.list,
          ),

          const SizedBox(height: 24),

          // Headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle(context, tl('Custom Headers')),
              IconButton(
                icon: Icon(Icons.add_circle, color: colorScheme.primary),
                onPressed: controller.addHeader,
                tooltip: tl('Add Header'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (headers.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tl('No custom headers. Tap + to add.'),
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...headers.asMap().entries.map((entry) {
              final index = entry.key;
              final header = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        initialValue: header.key,
                        onChanged: (v) =>
                            controller.updateHeader(index, key: v),
                        label: tl('Key'),
                        hint: tl('e.g., X-Custom-Header'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        initialValue: header.value,
                        onChanged: (v) =>
                            controller.updateHeader(index, value: v),
                        label: tl('Value'),
                        hint: tl('Header value'),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle, color: colorScheme.error),
                      onPressed: () => controller.removeHeader(index),
                      tooltip: tl('Remove'),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 80), // Space for FAB
        ],
      );
    });
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;

  const SwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: colorScheme.primary),
      ),
    );
  }
}
