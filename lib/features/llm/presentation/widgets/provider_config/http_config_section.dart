import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/llm/presentation/controllers/edit_provider_controller.dart';
import 'package:multigateway/shared/widgets/custom_text_field.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Section cấu hình HTTP (LlmProviderConfig)
class HttpConfigSection extends StatelessWidget {
  final AddProviderController controller;

  const HttpConfigSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Watch((context) {
      final responsesApi = controller.responsesApi.value;
      final supportStream = controller.supportStream.value;
      final headers = controller.headers.value;

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // API Options
          _buildSectionTitle(context, tl('API Options')),
          const SizedBox(height: 8),
          _buildSwitchTile(
            context,
            title: tl('Responses API'),
            subtitle: tl('Use OpenAI Responses API format'),
            value: responsesApi,
            onChanged: controller.updateResponsesApi,
            icon: Icons.api,
          ),
          const SizedBox(height: 8),
          _buildSwitchTile(
            context,
            title: tl('Support Stream'),
            subtitle: tl('Enable streaming responses'),
            value: supportStream,
            onChanged: controller.updateSupportStream,
            icon: Icons.stream,
          ),

          const SizedBox(height: 24),

          // Custom URLs
          _buildSectionTitle(context, tl('Custom URLs')),
          const SizedBox(height: 8),
          CustomTextField(
            controller: controller.customChatCompletionUrlController,
            label: tl('Chat Completions URL'),
            hint: tl('e.g., /chat/completions or full URL'),
            prefixIcon: Icons.chat,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: controller.customListModelsUrlController,
            label: tl('List Models URL'),
            hint: tl('e.g., /models or full URL'),
            prefixIcon: Icons.list,
          ),

          const SizedBox(height: 24),

          // HTTP Proxy
          _buildSectionTitle(context, tl('HTTP Proxy')),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomTextField(
                  controller: controller.httpProxyHostController,
                  label: tl('Host'),
                  hint: tl('e.g., proxy.example.com'),
                  prefixIcon: Icons.dns,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: controller.httpProxyPortController,
                  label: tl('Port'),
                  hint: '8080',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.numbers,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: controller.httpProxyUsernameController,
                  label: tl('Username'),
                  hint: tl('Optional'),
                  prefixIcon: Icons.person,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: controller.httpProxyPasswordController,
                  label: tl('Password'),
                  hint: tl('Optional'),
                  prefixIcon: Icons.lock,
                  obscureText: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // SOCKS Proxy
          _buildSectionTitle(context, tl('SOCKS Proxy')),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomTextField(
                  controller: controller.socksProxyHostController,
                  label: tl('Host'),
                  hint: tl('e.g., socks.example.com'),
                  prefixIcon: Icons.dns,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: controller.socksProxyPortController,
                  label: tl('Port'),
                  hint: '1080',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.numbers,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: controller.socksProxyUsernameController,
                  label: tl('Username'),
                  hint: tl('Optional'),
                  prefixIcon: Icons.person,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: controller.socksProxyPasswordController,
                  label: tl('Password'),
                  hint: tl('Optional'),
                  prefixIcon: Icons.lock,
                  obscureText: true,
                ),
              ),
            ],
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
                        controller: header.key,
                        label: tl('Key'),
                        hint: tl('e.g., X-Custom-Header'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        controller: header.value,
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

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
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
