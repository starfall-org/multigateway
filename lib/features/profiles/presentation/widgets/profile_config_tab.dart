import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/profiles/presentation/widgets/profile_controller_provider.dart';
import 'package:multigateway/features/settings/presentation/widgets/settings_card.dart';
import 'package:multigateway/shared/widgets/custom_text_field.dart';
import 'package:signals/signals_flutter.dart';

/// Tab cấu hình request của profile
class ProfileConfigTab extends StatelessWidget {
  const ProfileConfigTab({super.key});

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
              // Parameters Section
              Text(
                tl('Parameters'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              SettingsCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(tl('Stream')),
                      subtitle: Text(tl('Enable streaming responses')),
                      value: controller.enableStream.value,
                      onChanged: (value) => controller.toggleStream(value),
                    ),
                    const Divider(),

                    // Top P
                    SwitchListTile(
                      title: Text(tl('Top P')),
                      value: controller.isTopPEnabled.value,
                      onChanged: (value) => controller.toggleTopP(value),
                    ),
                    if (controller.isTopPEnabled.value)
                      _ParameterSlider(
                        value: controller.topPValue.value,
                        min: 0,
                        max: 1,
                        divisions: 20,
                        label: controller.topPValue.value.toStringAsFixed(2),
                        onChanged: (v) => controller.setTopPValue(v),
                      ),

                    const Divider(),
                    // Top K
                    SwitchListTile(
                      title: Text(tl('Top K')),
                      value: controller.isTopKEnabled.value,
                      onChanged: (value) => controller.toggleTopK(value),
                    ),
                    if (controller.isTopKEnabled.value)
                      _ParameterSlider(
                        value: controller.topKValue.value,
                        min: 1,
                        max: 100,
                        divisions: 99,
                        label: controller.topKValue.value.round().toString(),
                        onChanged: (v) => controller.setTopKValue(v),
                      ),

                    const Divider(),
                    // Temperature
                    SwitchListTile(
                      title: Text(tl('Temperature')),
                      value: controller.isTemperatureEnabled.value,
                      onChanged: (value) => controller.toggleTemperature(value),
                    ),
                    if (controller.isTemperatureEnabled.value)
                      _ParameterSlider(
                        value: controller.temperatureValue.value,
                        min: 0,
                        max: 2,
                        divisions: 20,
                        label: controller.temperatureValue.value
                            .toStringAsFixed(2),
                        onChanged: (v) => controller.setTemperatureValue(v),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Context window etc.
              _NumberField(
                label: tl('Context Window'),
                value: controller.contextWindowValue.value,
                onChanged: (v) => controller.setContextWindowValue(v),
                icon: Icons.window_outlined,
              ),
              const SizedBox(height: 16),
              _NumberField(
                label: tl('Conversation Length'),
                value: controller.conversationLengthValue.value,
                onChanged: (v) => controller.setConversationLengthValue(v),
                icon: Icons.history_outlined,
              ),
              const SizedBox(height: 16),
              _NumberField(
                label: tl('Max Tokens'),
                value: controller.maxTokensValue.value,
                onChanged: (v) => controller.setMaxTokensValue(v),
                icon: Icons.token_outlined,
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Widget slider cho parameters
class _ParameterSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String label;
  final ValueChanged<double> onChanged;

  const _ParameterSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: label,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              label,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget number field
class _NumberField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final IconData icon;

  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      keyboardType: TextInputType.number,
      label: label,
      prefixIcon: icon,
      controller: TextEditingController(text: value.toString()),
      onChanged: (text) {
        final val = int.tryParse(text);
        if (val != null) onChanged(val);
      },
    );
  }
}
