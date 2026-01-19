import 'package:flutter/material.dart';
import 'package:multigateway/core/llm/models/llm_provider_models.dart';
import 'package:multigateway/shared/utils/icon_builder.dart';
import 'package:multigateway/shared/widgets/item_card.dart';

class ModelCard extends StatelessWidget {
  final LlmModel model;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ModelCard({super.key, required this.model, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ItemCard(
      layout: ItemCardLayout.list,
      title: model.displayName,
      subtitle: model.id,
      icon: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: model.icon != null
            ? buildIcon(model.icon!)
            : buildIcon(model.id),
      ),
      subtitleWidget: _buildOriginSpecificInfo(context),
      leading: null,
      trailing: trailing,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget? _buildOriginSpecificInfo(BuildContext context) {
    return null;
  }
}
