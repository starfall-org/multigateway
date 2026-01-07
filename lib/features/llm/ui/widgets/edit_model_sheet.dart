import 'package:flutter/material.dart';
import 'package:llm/models/llm_model/basic_model.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/llm/controllers/edit_provider_controller.dart';
import 'package:multigateway/shared/widgets/common_dropdown.dart';
import 'package:multigateway/shared/widgets/custom_text_field.dart';

/// Model type for BasicModel
enum BasicModelType {
  chat,
  embedding,
  moderation,
  other,
}

/// Edit sheet for BasicModel (OpenAI, Anthropic)
/// Only edits: id, displayName, ownedBy, type
class EditModelSheet extends StatefulWidget {
  final AddProviderController controller;
  final Function(BasicModel) onShowCapabilities;
  final BasicModel? modelToEdit;

  const EditModelSheet({
    super.key,
    required this.controller,
    required this.onShowCapabilities,
    this.modelToEdit,
  });

  @override
  State<EditModelSheet> createState() => _EditModelSheetState();
}

class _EditModelSheetState extends State<EditModelSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _idController;
  late TextEditingController _displayNameController;
  late TextEditingController _ownedByController;
  BasicModelType _selectedType = BasicModelType.chat;

  @override
  void initState() {
    super.initState();
    final model = widget.modelToEdit;
    _idController = TextEditingController(text: model?.id ?? '');
    _displayNameController = TextEditingController(
      text: model?.displayName ?? '',
    );
    _ownedByController = TextEditingController(text: model?.ownedBy ?? '');
  }

  @override
  void dispose() {
    _idController.dispose();
    _displayNameController.dispose();
    _ownedByController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newModel = BasicModel(
        id: _idController.text.trim(),
        displayName: _displayNameController.text.trim().isEmpty
            ? _idController.text.trim()
            : _displayNameController.text.trim(),
        ownedBy: _ownedByController.text.trim().isEmpty
            ? 'user'
            : _ownedByController.text.trim(),
      );

      if (widget.modelToEdit != null) {
        // Update existing model
        widget.controller.updateModel(widget.modelToEdit!, newModel);
      } else {
        // Add new model
        widget.controller.addModelDirectly(newModel);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 400,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.modelToEdit != null
                          ? tl('Edit Model')
                          : tl('Add Model'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tl('Edit BasicModel for OpenAI/Anthropic'),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Model ID
                      CustomTextField(
                        controller: _idController,
                        label: tl('Model ID'),
                        hint: tl('e.g., gpt-4-turbo, claude-3-opus'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return tl('Model ID is required');
                          }
                          return null;
                        },
                        prefixIcon: Icons.tag,
                      ),
                      const SizedBox(height: 16),

                      // Display Name
                      CustomTextField(
                        controller: _displayNameController,
                        label: tl('Display Name'),
                        hint: tl('e.g., GPT-4 Turbo, Claude 3 Opus'),
                        prefixIcon: Icons.label,
                      ),
                      const SizedBox(height: 16),

                      // Owned By
                      CustomTextField(
                        controller: _ownedByController,
                        label: tl('Owned By'),
                        hint: tl('e.g., openai, anthropic'),
                        prefixIcon: Icons.business,
                      ),
                      const SizedBox(height: 16),

                      // Model Type Dropdown
                      CommonDropdown<BasicModelType>(
                        labelText: tl('Model Type'),
                        value: _selectedType,
                        options: BasicModelType.values.map((type) {
                          return DropdownOption<BasicModelType>(
                            value: type,
                            label: _getModelTypeLabel(type),
                            icon: _getModelTypeIcon(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // Example section
                      Text(
                        tl('Examples'),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _buildExampleCard(
                        context,
                        'OpenAI Chat',
                        'gpt-4-turbo',
                        'GPT-4 Turbo',
                        'openai',
                      ),
                      const SizedBox(height: 8),
                      _buildExampleCard(
                        context,
                        'Anthropic Chat',
                        'claude-3-opus-20240229',
                        'Claude 3 Opus',
                        'anthropic',
                      ),
                      const SizedBox(height: 8),
                      _buildExampleCard(
                        context,
                        'OpenAI Embedding',
                        'text-embedding-3-large',
                        'Text Embedding 3 Large',
                        'openai',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 18),
                      label: Text(tl('Cancel')),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: Icon(
                        widget.modelToEdit != null ? Icons.save : Icons.add,
                        size: 18,
                      ),
                      label: Text(
                        widget.modelToEdit != null ? tl('Save') : tl('Add'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getModelTypeLabel(BasicModelType type) {
    switch (type) {
      case BasicModelType.chat:
        return tl('Chat');
      case BasicModelType.embedding:
        return tl('Embedding');
      case BasicModelType.moderation:
        return tl('Moderation');
      case BasicModelType.other:
        return tl('Other');
    }
  }

  Icon _getModelTypeIcon(BasicModelType type) {
    switch (type) {
      case BasicModelType.chat:
        return const Icon(Icons.chat);
      case BasicModelType.embedding:
        return const Icon(Icons.code);
      case BasicModelType.moderation:
        return const Icon(Icons.shield);
      case BasicModelType.other:
        return const Icon(Icons.more_horiz);
    }
  }

  Widget _buildExampleCard(
    BuildContext context,
    String provider,
    String id,
    String displayName,
    String ownedBy,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'ID: $id',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
          Text(
            'Display: $displayName',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            'Owner: $ownedBy',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}