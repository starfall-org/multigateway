import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/shared/utils/icon_builder.dart';
import 'package:multigateway/shared/widgets/resource_tile.dart';

/// Widget hiển thị provider dạng tile trong list view
class ProviderTile extends StatelessWidget {
  final LlmProviderInfo provider;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProviderTile({
    super.key,
    required this.provider,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ResourceTile(
      key: ValueKey(provider.id),
      title: provider.name,
      subtitle: tl('${provider.type.name} Provider'),
      leadingIcon: buildIcon(provider.name),
      onTap: onTap,
      onDelete: onDelete,
      onEdit: onEdit,
    );
  }
}