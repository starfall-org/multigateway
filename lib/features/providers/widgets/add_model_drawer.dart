import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/models/ai/ai_model.dart';
import '../presentation/add_provider_viewmodel.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/dropdown.dart';

class AddModelDrawer extends StatefulWidget {
  final AddProviderViewModel viewModel;
  final Function(AIModel) onShowCapabilities;
  final AIModel? modelToEdit;

  const AddModelDrawer({
    super.key,
    required this.viewModel,
    required this.onShowCapabilities,
    this.modelToEdit,
  });

  @override
  State<AddModelDrawer> createState() => _AddModelDrawerState();
}

class _AddModelDrawerState extends State<AddModelDrawer> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _displayNameController;
  late TextEditingController _iconController;
  late TextEditingController _contextWindowController;

  ModelType _selectedType = ModelType.textGeneration;
  List<ModelIOType> _selectedInputs = [ModelIOType.text];
  List<ModelIOType> _selectedOutputs = [ModelIOType.text];
  bool _reasoning = false;

  @override
  void initState() {
    super.initState();
    final model = widget.modelToEdit;
    _nameController = TextEditingController(text: model?.name ?? '');
    _displayNameController = TextEditingController(
      text: model?.displayName ?? '',
    );
    _iconController = TextEditingController(text: model?.icon ?? '');
    _contextWindowController = TextEditingController(
      text: model?.contextWindow?.toString() ?? '',
    );

    if (model != null) {
      _selectedType = model.type;
      _selectedInputs = List.from(model.input);
      _selectedOutputs = List.from(model.output);
      _reasoning = model.reasoning;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _displayNameController.dispose();
    _iconController.dispose();
    _contextWindowController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newModel = AIModel(
        name: _nameController.text,
        displayName: _displayNameController.text,
        icon: _iconController.text.isNotEmpty ? _iconController.text : null,
        type: _selectedType,
        input: _selectedInputs,
        output: _selectedOutputs,
        reasoning: _reasoning,
        contextWindow: int.tryParse(_contextWindowController.text),
      );

      if (widget.modelToEdit != null) {
        // Remove the old model before adding the updated one
        // Using removeModelDirectly and addModelDirectly handles the list update in ViewModel
        widget.viewModel.removeModelDirectly(widget.modelToEdit!);
      }

      widget.viewModel.addModelDirectly(newModel);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 400,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  widget.modelToEdit != null ? 'Edit Model' : 'Add Model',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      label: 'Model ID',
                      hint: 'e.g. gpt-4-turbo',
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _displayNameController,
                      label: 'Display Name',
                      hint: 'e.g. GPT-4 Turbo',
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _iconController,
                      label: 'Icon URL/Path (Optional)',
                    ),
                    const SizedBox(height: 16),

                    CommonDropdown<ModelType>(
                      labelText: 'Type',
                      value: _selectedType,
                      options: ModelType.values
                          .map(
                            (e) => DropdownOption(
                              value: e,
                              label: e.name
                                  .replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ')
                                  .capitalize(),
                              icon: _getModelTypeIcon(e),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedType = v);
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _contextWindowController,
                      label: 'Context Window',
                      hint: 'e.g. 128000',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      title: const Text('Reasoning Capability'),
                      value: _reasoning,
                      onChanged: (v) => setState(() => _reasoning = v),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Input Types',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ModelIOType.values.map((type) {
                        final isSelected = _selectedInputs.contains(type);
                        return FilterChip(
                          label: Text(type.name.capitalize()),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedInputs.add(type);
                              } else {
                                _selectedInputs.remove(type);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Output Types',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ModelIOType.values.map((type) {
                        final isSelected = _selectedOutputs.contains(type);
                        return FilterChip(
                          label: Text(type.name.capitalize()),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedOutputs.add(type);
                              } else {
                                _selectedOutputs.remove(type);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Footer Actions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: Text(
                      widget.modelToEdit != null ? 'Save Changes' : 'Add Model',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getModelTypeIcon(ModelType type) {
    switch (type) {
      case ModelType.textGeneration:
        return const Icon(Icons.chat_bubble_outline);
      case ModelType.imageGeneration:
        return const Icon(Icons.image_outlined);
      case ModelType.audioGeneration:
        return const Icon(Icons.mic_none);
      case ModelType.videoGeneration:
        return const Icon(Icons.videocam_outlined);
      case ModelType.embedding:
        return const Icon(Icons.dataset_linked_outlined);
      case ModelType.rerank:
        return const Icon(Icons.sort);
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
