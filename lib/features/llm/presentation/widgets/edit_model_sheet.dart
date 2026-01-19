import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/models/llm_provider_models.dart';
import 'package:multigateway/features/llm/presentation/controllers/edit_provider_controller.dart';
import 'package:multigateway/features/llm/presentation/widgets/capabilities_section.dart';
import 'package:multigateway/shared/widgets/custom_text_field.dart';

class EditModelSheet extends StatefulWidget {
  final EditProviderController controller;
  final LlmModel? modelToEdit;

  const EditModelSheet({super.key, required this.controller, this.modelToEdit});

  @override
  State<EditModelSheet> createState() => _EditModelSheetState();
}

class _EditModelSheetState extends State<EditModelSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _idController;
  late TextEditingController _displayNameController;
  late TextEditingController _iconController;
  Capabilities _inputCapabilities = Capabilities();
  Capabilities _outputCapabilities = Capabilities();

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController();
    _displayNameController = TextEditingController();
    _iconController = TextEditingController();
    _prefill();
  }

  void _prefill() {
    final model = widget.modelToEdit;
    if (model == null) return;
    _idController.text = model.id;
    _displayNameController.text = model.displayName;
    _iconController.text = model.icon ?? '';
    _inputCapabilities = model.inputCapabilities;
    _outputCapabilities = model.outputCapabilities;
  }

  @override
  void dispose() {
    _idController.dispose();
    _displayNameController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (widget.modelToEdit == null) {
      widget.controller.addCustomModel(
        modelId: _idController.text.trim(),
        modelIcon: _iconController.text.trim().isEmpty
            ? null
            : _iconController.text.trim(),
        modelDisplayName: _displayNameController.text.trim(),
        inputCapabilities: _inputCapabilities,
        outputCapabilities: _outputCapabilities,
        modelInfo: {},
      );
    } else {
      final model = LlmModel(
        id: _idController.text.trim(),
        displayName: _displayNameController.text.trim(),
        providerId: widget.controller.id.value,
        inputCapabilities: _inputCapabilities,
        outputCapabilities: _outputCapabilities,
        modelInfo: {},
      );
      widget.controller.updateModel(widget.modelToEdit!, model);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEditing = widget.modelToEdit != null;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? tl('Edit Model') : tl('Add Model'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _idController,
                  label: tl('Model ID'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? tl('Required') : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _displayNameController,
                  label: tl('Display Name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? tl('Required') : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _iconController,
                  label: tl('Icon (optional)'),
                ),
                const SizedBox(height: 16),
                CapabilitiesSection(
                  title: tl('Input Capabilities'),
                  capabilities: _inputCapabilities,
                  onUpdate: (cap) => setState(() => _inputCapabilities = cap),
                ),
                const SizedBox(height: 16),
                CapabilitiesSection(
                  title: tl('Output Capabilities'),
                  capabilities: _outputCapabilities,
                  onUpdate: (cap) => setState(() => _outputCapabilities = cap),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: Text(isEditing ? tl('Save') : tl('Add')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
