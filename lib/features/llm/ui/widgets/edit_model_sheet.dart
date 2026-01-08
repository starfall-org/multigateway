import 'package:flutter/material.dart';
import 'package:llm/models/llm_model/basic_model.dart';
import 'package:llm/models/llm_model/github_model.dart';
import 'package:llm/models/llm_model/googleai_model.dart';
import 'package:llm/models/llm_model/ollama_model.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/llm/controllers/edit_provider_controller.dart';
import 'package:multigateway/shared/widgets/bottom_sheet.dart';
import 'package:multigateway/shared/widgets/common_dropdown.dart';
import 'package:multigateway/shared/widgets/custom_text_field.dart';

/// Model origin/type enum
enum ModelOrigin {
  openaiAnthropic('OpenAI/Anthropic', Icons.cloud),
  ollama('Ollama', Icons.computer),
  googleAi('Google AI', Icons.public),
  github('GitHub', Icons.code),
  ;

  final String label;
  final IconData icon;
  const ModelOrigin(this.label, this.icon);
}

/// Model type for BasicModel
enum BasicModelType {
  chat,
  embedding,
  moderation,
  other,
}

/// Edit sheet for all model types using CustomBottomSheet
/// Supports editing: BasicModel, OllamaModel, GoogleAiModel, GitHubModel
class EditModelSheet extends StatefulWidget {
  final AddProviderController controller;
  final Function(dynamic) onShowCapabilities;
  final dynamic modelToEdit;

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

  // Controllers for BasicModel
  late TextEditingController _basicIdController;
  late TextEditingController _basicDisplayNameController;
  late TextEditingController _basicOwnedByController;
  BasicModelType _basicSelectedType = BasicModelType.chat;

  // Controllers for OllamaModel
  late TextEditingController _ollamaNameController;
  late TextEditingController _ollamaModelController;
  late TextEditingController _ollamaParameterSizeController;
  late TextEditingController _ollamaQuantizationController;

  // Controllers for GoogleAiModel
  late TextEditingController _googleNameController;
  late TextEditingController _googleDisplayNameController;
  late TextEditingController _googleInputTokenLimitController;
  late TextEditingController _googleOutputTokenLimitController;
  late TextEditingController _googleTemperatureController;
  late TextEditingController _googleMaxTemperatureController;
  late TextEditingController _googleTopPController;
  late TextEditingController _googleTopKController;
  bool _googleThinking = false;

  // Controllers for GitHubModel
  late TextEditingController _githubIdController;
  late TextEditingController _githubNameController;
  late TextEditingController _githubMaxInputTokensController;
  late TextEditingController _githubMaxOutputTokensController;

  ModelOrigin _selectedOrigin = ModelOrigin.openaiAnthropic;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _detectModelType();
  }

  void _initControllers() {
    // BasicModel controllers
    _basicIdController = TextEditingController();
    _basicDisplayNameController = TextEditingController();
    _basicOwnedByController = TextEditingController();

    // OllamaModel controllers
    _ollamaNameController = TextEditingController();
    _ollamaModelController = TextEditingController();
    _ollamaParameterSizeController = TextEditingController();
    _ollamaQuantizationController = TextEditingController();

    // GoogleAiModel controllers
    _googleNameController = TextEditingController();
    _googleDisplayNameController = TextEditingController();
    _googleInputTokenLimitController = TextEditingController();
    _googleOutputTokenLimitController = TextEditingController();
    _googleTemperatureController = TextEditingController();
    _googleMaxTemperatureController = TextEditingController();
    _googleTopPController = TextEditingController();
    _googleTopKController = TextEditingController();

    // GitHubModel controllers
    _githubIdController = TextEditingController();
    _githubNameController = TextEditingController();
    _githubMaxInputTokensController = TextEditingController();
    _githubMaxOutputTokensController = TextEditingController();
  }

  void _detectModelType() {
    final model = widget.modelToEdit;
    if (model == null) return;

    if (model is BasicModel) {
      _selectedOrigin = ModelOrigin.openaiAnthropic;
      _basicIdController.text = model.id;
      _basicDisplayNameController.text = model.displayName;
      _basicOwnedByController.text = model.ownedBy;
    } else if (model is OllamaModel) {
      _selectedOrigin = ModelOrigin.ollama;
      _ollamaNameController.text = model.name;
      _ollamaModelController.text = model.model;
      _ollamaParameterSizeController.text = model.parameterSize;
      _ollamaQuantizationController.text = model.quantizationLevel;
    } else if (model is GoogleAiModel) {
      _selectedOrigin = ModelOrigin.googleAi;
      _googleNameController.text = model.name;
      _googleDisplayNameController.text = model.displayName;
      _googleInputTokenLimitController.text = model.inputTokenLimit.toString();
      _googleOutputTokenLimitController.text = model.outputTokenLimit.toString();
      _googleTemperatureController.text = model.temperature.toString();
      _googleMaxTemperatureController.text = model.maxTemperature.toString();
      _googleTopPController.text = model.topP.toString();
      _googleTopKController.text = model.topK.toString();
      _googleThinking = model.thinking;
    } else if (model is GitHubModel) {
      _selectedOrigin = ModelOrigin.github;
      _githubIdController.text = model.id;
      _githubNameController.text = model.name;
      _githubMaxInputTokensController.text = model.maxInputTokens.toString();
      _githubMaxOutputTokensController.text = model.maxOutputTokens.toString();
    }
  }

  @override
  void dispose() {
    // BasicModel controllers
    _basicIdController.dispose();
    _basicDisplayNameController.dispose();
    _basicOwnedByController.dispose();

    // OllamaModel controllers
    _ollamaNameController.dispose();
    _ollamaModelController.dispose();
    _ollamaParameterSizeController.dispose();
    _ollamaQuantizationController.dispose();

    // GoogleAiModel controllers
    _googleNameController.dispose();
    _googleDisplayNameController.dispose();
    _googleInputTokenLimitController.dispose();
    _googleOutputTokenLimitController.dispose();
    _googleTemperatureController.dispose();
    _googleMaxTemperatureController.dispose();
    _googleTopPController.dispose();
    _googleTopKController.dispose();

    // GitHubModel controllers
    _githubIdController.dispose();
    _githubNameController.dispose();
    _githubMaxInputTokensController.dispose();
    _githubMaxOutputTokensController.dispose();

    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    dynamic newModel;
    switch (_selectedOrigin) {
      case ModelOrigin.openaiAnthropic:
        newModel = BasicModel(
          id: _basicIdController.text.trim(),
          displayName: _basicDisplayNameController.text.trim().isEmpty
              ? _basicIdController.text.trim()
              : _basicDisplayNameController.text.trim(),
          ownedBy: _basicOwnedByController.text.trim().isEmpty
              ? 'user'
              : _basicOwnedByController.text.trim(),
        );
        break;
      case ModelOrigin.ollama:
        newModel = OllamaModel(
          name: _ollamaNameController.text.trim(),
          model: _ollamaModelController.text.trim(),
          parameterSize: _ollamaParameterSizeController.text.trim(),
          quantizationLevel: _ollamaQuantizationController.text.trim(),
        );
        break;
      case ModelOrigin.googleAi:
        newModel = GoogleAiModel(
          name: _googleNameController.text.trim(),
          displayName: _googleDisplayNameController.text.trim().isEmpty
              ? _googleNameController.text.trim()
              : _googleDisplayNameController.text.trim(),
          inputTokenLimit: int.tryParse(_googleInputTokenLimitController.text.trim()) ?? 0,
          outputTokenLimit: int.tryParse(_googleOutputTokenLimitController.text.trim()) ?? 0,
          supportedGenerationMethods: ['generateContent'],
          thinking: _googleThinking,
          temperature: double.tryParse(_googleTemperatureController.text.trim()) ?? 1.0,
          maxTemperature: double.tryParse(_googleMaxTemperatureController.text.trim()) ?? 2.0,
          topP: double.tryParse(_googleTopPController.text.trim()) ?? 0.95,
          topK: int.tryParse(_googleTopKController.text.trim()) ?? 64,
        );
        break;
      case ModelOrigin.github:
        newModel = GitHubModel(
          id: _githubIdController.text.trim(),
          name: _githubNameController.text.trim(),
          supportedInputModalities: ['text'],
          supportedOutputModalities: ['text'],
          maxInputTokens: int.tryParse(_githubMaxInputTokensController.text.trim()) ?? 0,
          maxOutputTokens: int.tryParse(_githubMaxOutputTokensController.text.trim()) ?? 0,
        );
        break;
    }

    if (widget.modelToEdit != null) {
      widget.controller.updateModel(widget.modelToEdit!, newModel);
    } else {
      widget.controller.addModelDirectly(newModel);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      header: _buildHeader(context),
      items: _buildFormItems(),
      footer: _buildFooter(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
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
              widget.modelToEdit != null ? tl('Edit Model') : tl('Add Model'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
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
    );
  }

  List<Widget> _buildFormItems() {
    return [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Model Origin Dropdown (Expandable)
            _buildOriginSelector(),
            const SizedBox(height: 16),

            // Model-specific fields
            if (_isExpanded) ...[
              _buildBasicModelFields(),
              _buildOllamaModelFields(),
              _buildGoogleAiModelFields(),
              _buildGitHubModelFields(),
            ],
          ],
        ),
      ),
    ];
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
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
    );
  }

  Widget _buildOriginSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _selectedOrigin.icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tl('Model Origin'),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedOrigin.label,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            _buildOriginOption(ModelOrigin.openaiAnthropic),
            _buildOriginOption(ModelOrigin.ollama),
            _buildOriginOption(ModelOrigin.googleAi),
            _buildOriginOption(ModelOrigin.github),
          ],
        ],
      ),
    );
  }

  Widget _buildOriginOption(ModelOrigin origin) {
    final isSelected = _selectedOrigin == origin;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedOrigin = origin;
          _isExpanded = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        child: Row(
          children: [
            Icon(
              origin.icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              origin.label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
            ),
            if (isSelected) const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicModelFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('OpenAI/Anthropic Model'),
        CustomTextField(
          controller: _basicIdController,
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
        CustomTextField(
          controller: _basicDisplayNameController,
          label: tl('Display Name'),
          hint: tl('e.g., GPT-4 Turbo, Claude 3 Opus'),
          prefixIcon: Icons.label,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _basicOwnedByController,
          label: tl('Owned By'),
          hint: tl('e.g., openai, anthropic'),
          prefixIcon: Icons.business,
        ),
        const SizedBox(height: 16),
        CommonDropdown<BasicModelType>(
          labelText: tl('Model Type'),
          value: _basicSelectedType,
          options: BasicModelType.values.map((type) {
            return DropdownOption<BasicModelType>(
              value: type,
              label: _getModelTypeLabel(type),
              icon: _getModelTypeIcon(type),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _basicSelectedType = value);
            }
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildOllamaModelFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Ollama Model'),
        CustomTextField(
          controller: _ollamaNameController,
          label: tl('Name'),
          hint: tl('e.g., llama3.2'),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return tl('Name is required');
            }
            return null;
          },
          prefixIcon: Icons.label,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _ollamaModelController,
          label: tl('Model ID'),
          hint: tl('e.g., llama3.2:latest'),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return tl('Model ID is required');
            }
            return null;
          },
          prefixIcon: Icons.tag,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _ollamaParameterSizeController,
          label: tl('Parameter Size'),
          hint: tl('e.g., 3B, 7B, 70B'),
          prefixIcon: Icons.memory,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _ollamaQuantizationController,
          label: tl('Quantization'),
          hint: tl('e.g., Q4_0, Q5_1'),
          prefixIcon: Icons.compress,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildGoogleAiModelFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Google AI Model'),
        CustomTextField(
          controller: _googleNameController,
          label: tl('Model ID'),
          hint: tl('e.g., gemini-1.5-pro'),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return tl('Model ID is required');
            }
            return null;
          },
          prefixIcon: Icons.tag,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _googleDisplayNameController,
          label: tl('Display Name'),
          hint: tl('e.g., Gemini 1.5 Pro'),
          prefixIcon: Icons.label,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _googleInputTokenLimitController,
                label: tl('Input Tokens'),
                hint: 'e.g., 2000000',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.text_fields,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: _googleOutputTokenLimitController,
                label: tl('Output Tokens'),
                hint: 'e.g., 8192',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.text_snippet,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _googleTemperatureController,
                label: tl('Temperature'),
                hint: '0-2',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.thermostat,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: _googleMaxTemperatureController,
                label: tl('Max Temp'),
                hint: '0-2',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.thermostat,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _googleTopPController,
                label: tl('Top P'),
                hint: '0-1',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.filter_list,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: _googleTopKController,
                label: tl('Top K'),
                hint: '1-100',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.filter_list,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(tl('Thinking Mode')),
          value: _googleThinking,
          onChanged: (value) => setState(() => _googleThinking = value),
          secondary: const Icon(Icons.psychology),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildGitHubModelFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('GitHub Model'),
        CustomTextField(
          controller: _githubIdController,
          label: tl('Model ID'),
          hint: tl('e.g., gpt-4o'),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return tl('Model ID is required');
            }
            return null;
          },
          prefixIcon: Icons.tag,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _githubNameController,
          label: tl('Name'),
          hint: tl('e.g., GPT-4o'),
          prefixIcon: Icons.label,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _githubMaxInputTokensController,
                label: tl('Max Input Tokens'),
                hint: 'e.g., 128000',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.text_fields,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: _githubMaxOutputTokensController,
                label: tl('Max Output Tokens'),
                hint: 'e.g., 16384',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.text_snippet,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
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
}
