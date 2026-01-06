import 'package:flutter/material.dart';
import 'package:llm/llm.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/llm/controllers/edit_provider_controller.dart';
import 'package:multigateway/shared/widgets/common_dropdown.dart';
import 'package:multigateway/shared/widgets/custom_text_field.dart';

class EditModelSheet extends StatefulWidget {
  final AddProviderViewModel viewModel;
  final Function(AIModel) onShowCapabilities;
  final AIModel? modelToEdit;

  const EditModelSheet({
    super.key,
    required this.viewModel,
    required this.onShowCapabilities,
    this.modelToEdit,
  });

  @override
  State<EditModelSheet> createState() => _EditModelSheetState();
}

class _EditModelSheetState extends State<EditModelSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _displayNameController;
  late TextEditingController _iconController;
  late TextEditingController _contextWindowController;

  ModelType _selectedType = ModelType.chat;
  AIModelIO _selectedInputs = AIModelIO(text: true, image: false, audio: false);
  AIModelIO _selectedOutputs = AIModelIO(
    text: true,
    image: false,
    audio: false,
  );
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
      _selectedInputs =
          model.input ?? AIModelIO(text: true, image: false, audio: false);
      _selectedOutputs =
          model.output ?? AIModelIO(text: true, image: false, audio: false);
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
      child: SafeArea(
        child: Column(
          children: [
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
                        label: tl('ID'),
                        hint: tl('eg: gemini-flash'),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _displayNameController,
                        label: tl('Display Name'),
                        hint: tl('eg: Gemini Flash'),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _iconController,
                        label: tl('Icon'),
                        hint: tl('Icon url'),
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
                        children: [
                          FilterChip(
                            label: Icon(Icons.text_fields_rounded),
                            selected: _selectedInputs.text,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedInputs.text = true;
                                } else {
                                  _selectedInputs.text = false;
                                }
                              });
                            },
                          ),
                          FilterChip(
                            label: Icon(Icons.image_rounded),
                            selected: _selectedInputs.image,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedInputs.image = true;
                                } else {
                                  _selectedInputs.image = false;
                                }
                              });
                            },
                          ),
                          FilterChip(
                            label: Icon(Icons.audio_file_rounded),
                            selected: _selectedInputs.audio,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedInputs.audio = true;
                                } else {
                                  _selectedInputs.audio = false;
                                }
                              });
                            },
                          ),
                          FilterChip(
                            label: Icon(Icons.video_file_rounded),
                            selected: _selectedInputs.video,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedInputs.video = true;
                                } else {
                                  _selectedInputs.video = false;
                                }
                              });
                            },
                          ),
                        ],

                        //AIModelIO.values.map((type) {
                      ),
                      const SizedBox(height: 16),

                      Text(
                        tl('Output Types'),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilterChip(
                            label: Icon(Icons.text_fields_rounded),
                            selected: _selectedOutputs.text,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedOutputs.text = true;
                                } else {
                                  _selectedOutputs.text = false;
                                }
                              });
                            },
                          ),
                          FilterChip(
                            label: Icon(Icons.image_rounded),
                            selected: _selectedOutputs.image,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedOutputs.image = true;
                                } else {
                                  _selectedOutputs.image = false;
                                }
                              });
                            },
                          ),
                          FilterChip(
                            label: Icon(Icons.audio_file_rounded),
                            selected: _selectedOutputs.audio,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedOutputs.audio = true;
                                } else {
                                  _selectedOutputs.audio = false;
                                }
                              });
                            },
                          ),
                          FilterChip(
                            label: Icon(Icons.video_file_rounded),
                            selected: _selectedOutputs.video,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedOutputs.video = true;
                                } else {
                                  _selectedOutputs.video = false;
                                }
                              });
                            },
                          ),
                        ],
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
                        widget.modelToEdit != null ? tl("Save") : tl("Add"),
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

  Widget _getModelTypeIcon(ModelType type) {
    switch (type) {
      case ModelType.chat:
        return Icon(Icons.chat_rounded);
      case ModelType.image:
        return Icon(Icons.image_rounded);
      case ModelType.audio:
        return Icon(Icons.music_video_rounded);
      case ModelType.video:
        return Icon(Icons.movie_creation_rounded);
      case ModelType.embed:
        return Icon(Icons.code_rounded);
      case ModelType.rerank:
        return Icon(Icons.leaderboard_rounded);
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
