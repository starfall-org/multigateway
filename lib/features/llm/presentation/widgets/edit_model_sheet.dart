import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/models/llm_provider_models.dart';
import 'package:multigateway/features/llm/presentation/controllers/edit_provider_controller.dart';
import 'package:multigateway/shared/widgets/custom_text_field.dart';

class EditModelSheet extends StatefulWidget {
  final AddProviderController controller;
  final LlmModel? modelToEdit;

  const EditModelSheet({super.key, required this.controller, this.modelToEdit});

  @override
  State<EditModelSheet> createState() => _EditModelSheetState();
}

class _EditModelSheetState extends State<EditModelSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _idController;
  late TextEditingController _displayNameController;
  late TextEditingController _providerNameController;
  late TextEditingController _iconController;
  LlmModelType _selectedType = LlmModelType.chat;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController();
    _displayNameController = TextEditingController();
    _providerNameController = TextEditingController();
    _iconController = TextEditingController();
    _prefill();
  }

  void _prefill() {
    final model = widget.modelToEdit;
    if (model == null) return;
    _idController.text = model.id;
    _displayNameController.text = model.displayName;
    _providerNameController.text = model.providerName ?? '';
    _iconController.text = model.icon ?? '';
    _selectedType = model.type;
  }

  @override
  void dispose() {
    _idController.dispose();
    _displayNameController.dispose();
    _providerNameController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final model = LlmModel(
      id: _idController.text.trim(),
      displayName: _displayNameController.text.trim(),
      type: _selectedType,
      icon: _iconController.text.trim().isEmpty
          ? null
          : _iconController.text.trim(),
      providerName: _providerNameController.text.trim().isEmpty
          ? null
          : _providerNameController.text.trim(),
      metadata: null,
    );

    if (widget.modelToEdit == null) {
      widget.controller.addModelDirectly(model);
    } else {
      widget.controller.updateModel(widget.modelToEdit!, model);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEditing = widget.modelToEdit != null;

    return Container(
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
                controller: _providerNameController,
                label: tl('Provider Name (optional)'),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _iconController,
                label: tl('Icon (optional)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<LlmModelType>(
                value: _selectedType,
                items: LlmModelType.values
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
                decoration: InputDecoration(
                  label: tl('Type'),
                  border: const OutlineInputBorder(),
                ),
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
    );
  }
}
