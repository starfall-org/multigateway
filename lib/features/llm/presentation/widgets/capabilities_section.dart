import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/models/llm_provider_models.dart';
import 'package:multigateway/features/llm/presentation/widgets/capability_chip.dart';

class CapabilitiesSection extends StatelessWidget {
  final String title;
  final Capabilities capabilities;
  final Function(Capabilities) onUpdate;

  const CapabilitiesSection({
    super.key,
    required this.title,
    required this.capabilities,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            CapabilityChip(
              label: tl('Text'),
              isSelected: capabilities.text,
              onTap: () => onUpdate(Capabilities(
                text: !capabilities.text,
                image: capabilities.image,
                video: capabilities.video,
                embed: capabilities.embed,
                audio: capabilities.audio,
                others: capabilities.others,
              )),
            ),
            CapabilityChip(
              label: tl('Image'),
              isSelected: capabilities.image,
              onTap: () => onUpdate(Capabilities(
                text: capabilities.text,
                image: !capabilities.image,
                video: capabilities.video,
                embed: capabilities.embed,
                audio: capabilities.audio,
                others: capabilities.others,
              )),
            ),
            CapabilityChip(
              label: tl('Video'),
              isSelected: capabilities.video,
              onTap: () => onUpdate(Capabilities(
                text: capabilities.text,
                image: capabilities.image,
                video: !capabilities.video,
                embed: capabilities.embed,
                audio: capabilities.audio,
                others: capabilities.others,
              )),
            ),
            CapabilityChip(
              label: tl('Embed'),
              isSelected: capabilities.embed,
              onTap: () => onUpdate(Capabilities(
                text: capabilities.text,
                image: capabilities.image,
                video: capabilities.video,
                embed: !capabilities.embed,
                audio: capabilities.audio,
                others: capabilities.others,
              )),
            ),
            CapabilityChip(
              label: tl('Audio'),
              isSelected: capabilities.audio,
              onTap: () => onUpdate(Capabilities(
                text: capabilities.text,
                image: capabilities.image,
                video: capabilities.video,
                embed: capabilities.embed,
                audio: !capabilities.audio,
                others: capabilities.others,
              )),
            ),
          ],
        ),
      ],
    );
  }
}
