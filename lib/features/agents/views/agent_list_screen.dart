import 'package:flutter/material.dart';
import '../../../core/storage/agent_repository.dart';
import 'package:ai_gateway/core/models/agent.dart';
import 'add_agent_dialog.dart';

class AgentListScreen extends StatefulWidget {
  const AgentListScreen({super.key});

  @override
  State<AgentListScreen> createState() => _AgentListScreenState();
}

class _AgentListScreenState extends State<AgentListScreen> {
  List<Agent> _agents = [];
  bool _isLoading = true;
  late AgentRepository _repository;

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    _repository = await AgentRepository.init();
    setState(() {
      _agents = _repository.getAgents();
      _isLoading = false;
    });
  }

  Future<void> _deleteAgent(String id) async {
    await _repository.deleteAgent(id);
    _loadAgents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Danh sách Agent',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (context) => const AddAgentDialog(),
              );
              if (result == true) {
                _loadAgents();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _agents.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final agent = _agents[index];
                return Dismissible(
                  key: Key(agent.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteAgent(agent.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${agent.name} deleted')),
                    );
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        agent.name.isNotEmpty
                            ? agent.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                    title: Text(agent.name),
                    subtitle: Text(
                      agent.systemPrompt.isNotEmpty
                          ? agent.systemPrompt
                          : 'No system prompt',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () async {
                      await _repository.setSelectedAgentId(agent.id);
                      if (!mounted) return;
                      Navigator.pop(context, true);
                    },
                  ),
                );
              },
            ),
    );
  }
}
