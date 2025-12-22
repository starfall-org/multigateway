import 'package:flutter/material.dart';
import '../../../../core/models/ai/ai_model.dart';
import '../../presentation/add_provider_viewmodel.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/dropdown.dart';

import '../../../../core/translate.dart';

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
                  widget.modelToEdit != null ? 'Add Model' : 'Edit Model',
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
                      label: 'ID',
                      hint: 'eg: gemini-flash',
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _displayNameController,
                      label: 'Display Name',
                      hint: 'eg: Gemini Flash',
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _iconController,
                      label: 'Icon',
                      hint: 'Icon url or path',
                    ),
                    const SizedBox(height: 16),

                    CommonDropdown<ModelType>(
                      labelText: tl('Type'),
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

                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      title: Text(tl('Reasoning')),
                      value: _reasoning,
                      onChanged: (v) => setState(() => _reasoning = v),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),

                    Text(
                      tl('Input Types'),
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
                      tl('Output Types'),
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
                    child: Text(tl('Cancel')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: Text(
                      widget.modelToEdit != null ? 'Save' : 'common.add',
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
        return Icon(Icons.text_snippet);
      case ModelType.imageGeneration:
        return Icon(Icons.image_search);
      case ModelType.audioGeneration:
        return Icon(Icons.music_video);
      case ModelType.videoGeneration:
        return Icon(Icons.local_movies);
      case ModelType.embedding:
        return Icon(Icons.compress_rounded);
      case ModelType.rerank:
        return Icon(Icons.leaderboard);
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
