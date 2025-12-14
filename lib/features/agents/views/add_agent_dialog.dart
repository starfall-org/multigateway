import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:ai_gateway/core/storage/agent_repository.dart';
import '../dto/agent.dart';

class AddAgentDialog extends StatefulWidget {
  const AddAgentDialog({super.key});

  @override
  State<AddAgentDialog> createState() => _AddAgentDialogState();
}

class _AddAgentDialogState extends State<AddAgentDialog> {
  final _nameController = TextEditingController();
  final _promptController = TextEditingController();
  bool _isTopKEnabled = false;
  double _topKValue = 40.0;
  bool _isTemperatureEnabled = false;
  double _temperatureValue = 0.7;

  @override
  void dispose() {
    _nameController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _saveAgent() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an agent name')),
      );
      return;
    }

    final repository = await AgentRepository.init();
    final newAgent = Agent(
      id: const Uuid().v4(),
      name: _nameController.text,
      systemPrompt: _promptController.text,
      topK: _isTopKEnabled ? _topKValue : null,
      temperature: _isTemperatureEnabled ? _temperatureValue : null,
    );

    await repository.addAgent(newAgent);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.1, // 80% width
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thêm Agent Mới',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Avatar Section
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey.shade200,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Agent Name
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Tên Agent',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // System Prompt
                    TextField(
                      controller: _promptController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'System Prompt',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Parameters
                    const Text(
                      'Tham số nâng cao',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Top K
                    SwitchListTile(
                      title: const Text('Top K'),
                      value: _isTopKEnabled,
                      onChanged: (value) {
                        setState(() {
                          _isTopKEnabled = value;
                        });
                      },
                    ),
                    if (_isTopKEnabled)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _topKValue,
                                min: 1,
                                max: 100,
                                divisions: 99,
                                label: _topKValue.round().toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _topKValue = value;
                                  });
                                },
                              ),
                            ),
                            Text(
                              _topKValue.round().toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Temperature
                    SwitchListTile(
                      title: const Text('Temperature'),
                      value: _isTemperatureEnabled,
                      onChanged: (value) {
                        setState(() {
                          _isTemperatureEnabled = value;
                        });
                      },
                    ),
                    if (_isTemperatureEnabled)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _temperatureValue,
                                min: 0.0,
                                max: 1.0,
                                divisions: 10,
                                label: _temperatureValue.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _temperatureValue = value;
                                  });
                                },
                              ),
                            ),
                            Text(
                              _temperatureValue.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveAgent,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Lưu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
