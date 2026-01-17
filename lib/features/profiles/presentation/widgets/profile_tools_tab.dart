import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/profiles/presentation/widgets/profile_controller_provider.dart';
import 'package:multigateway/features/settings/presentation/widgets/settings_card.dart';
import 'package:signals/signals_flutter.dart';

/// Tab công cụ (MCP servers) của profile
class ProfileToolsTab extends StatelessWidget {
  const ProfileToolsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileControllerProvider.of(context);

    return Watch((context) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.availableMcpServers.value.isNotEmpty) ...[
                Text(
                  tl('MCP Servers'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SettingsCard(
                  child: Column(
                    children: controller.availableMcpServers.value.map((
                      server,
                    ) {
                      return CheckboxListTile(
                        title: Text(server.name),
                        value: controller.selectedMcpServerIds.value.contains(
                          server.id,
                        ),
                        onChanged: (bool? value) {
                          controller.toggleMcpServer(server.id);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ] else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 32.0),
                    child: Text(tl('No MCP servers available')),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
