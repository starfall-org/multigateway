import 'package:flutter/material.dart';
import '../../../../core/llm/models/llm_model/base.dart';
import '../../../../shared/utils/icon_builder.dart';
import '../../../../shared/widgets/item_card.dart';

class ModelCard extends StatelessWidget {
  final AIModel model;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ModelCard({super.key, required this.model, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ItemCard(
      layout: ItemCardLayout.list,
      title: model.name,
      icon: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: _getModelIcon(),
      ),
      subtitleWidget: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            ..._buildIOTags(context),
            if (model.parameters != null)
              _buildTextTag(
                context,
                _formatParameters(model.parameters!),
                Theme.of(context).colorScheme.tertiary,
              ),
          ],
        ),
      ),
      leading: _buildTag(
        context,
        _getModelTypeLabel(),
        Theme.of(context).colorScheme.primary,
      ),
      trailing: trailing,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _getModelIcon() {
    return buildIcon(model.name);
  }

  Widget _getModelTypeLabel() {
    switch (model.type) {
      case ModelType.chat:
        if (model.reasoning == true) {
          return Icon(Icons.chat_rounded);
        }
        return Icon(Icons.chat_bubble_rounded);
      case ModelType.image:
        return Icon(Icons.image_search_rounded);
      case ModelType.audio:
        return Icon(Icons.music_video);
      case ModelType.video:
        return Icon(Icons.movie_creation_rounded);
      case ModelType.embed:
        return Icon(Icons.code_rounded);
      case ModelType.rerank:
        return Icon(Icons.leaderboard_rounded);
    }
  }

  List<Widget> _buildIOTags(BuildContext context) {
    final List<Widget> tags = [];

    // Input tags
    if (model.input != null) {
      final inputIcons = _getIOIcons(model.input!);
      if (inputIcons.isNotEmpty) {
        tags.add(
          _buildTag(
            context,
            Row(mainAxisSize: MainAxisSize.min, children: inputIcons),
            Theme.of(context).colorScheme.tertiary,
          ),
        );
      }
    }

    // Output tags
    if (model.output != null) {
      final outputIcons = _getIOIcons(model.output!);
      if (outputIcons.isNotEmpty) {
        tags.add(
          _buildTag(
            context,
            Row(mainAxisSize: MainAxisSize.min, children: outputIcons),
            Theme.of(context).colorScheme.secondary,
          ),
        );
      }
    }

    return tags;
  }

  List<Icon> _getIOIcons(AIModelIO io) {
    final List<Icon> icons = [];
    if (io.text) icons.add(const Icon(Icons.text_fields_rounded, size: 16));
    if (io.image) icons.add(const Icon(Icons.image_rounded, size: 16));
    if (io.audio) icons.add(const Icon(Icons.audio_file_rounded, size: 16));
    if (io.video) icons.add(const Icon(Icons.video_file_rounded, size: 16));
    return icons;
  }

  String _formatParameters(int params) {
    if (params >= 1000000000) {
      return '${(params / 1000000000).toStringAsFixed(0)}B';
    } else if (params >= 1000000) {
      return '${(params / 1000000).toStringAsFixed(0)}M';
    } else if (params >= 1000) {
      return '${(params / 1000).toStringAsFixed(0)}K';
    }
    return params.toString();
  }

  Widget _buildTag(BuildContext context, Widget label, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Sử dụng color scheme để tạo boxColor thay vì hardcode white/black
    final boxColor = isDark
        ? Color.lerp(color, theme.colorScheme.surface, 0.7)!
        : Color.lerp(color, theme.colorScheme.onSurface, 0.5)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: boxColor.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.4 : 0.3)),
      ),
      // color: color, // Bỏ thuộc tính color bị thừa ở đây nếu Container đã có decoration
      child: label,
    );
  }

  Widget _buildTextTag(BuildContext context, String label, Color color) {
    return _buildTag(context, Text(label), color);
  }
}
