import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../features/agents/domain/agent.dart';

class AgentRepository {
  static const String _storageKey = 'agents';
  final SharedPreferences _prefs;

  AgentRepository(this._prefs);

  static Future<AgentRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return AgentRepository(prefs);
  }

  List<Agent> getAgents() {
    final List<String>? agentsJson = _prefs.getStringList(_storageKey);
    if (agentsJson == null || agentsJson.isEmpty) {
      return [_createDefaultAgent()];
    }
    return agentsJson.map((str) => Agent.fromJsonString(str)).toList();
  }

  Future<void> addAgent(Agent agent) async {
    final agents = getAgents();
    agents.add(agent);
    await _saveAgents(agents);
  }

  Future<void> deleteAgent(String id) async {
    final agents = getAgents();
    // Don't delete if it's the last one or the default one (optional rule, but user said default exists)
    // User said "mặc định sẽ có sẵn một agent và người dùng có thể xóa agent đó", so we allow deleting default.
    // But if list becomes empty, maybe we should restore default?
    // User said "mặc định sẽ có sẵn một agent", implying initial state.

    agents.removeWhere((a) => a.id == id);
    await _saveAgents(agents);
  }

  Future<void> _saveAgents(List<Agent> agents) async {
    final List<String> agentsJson = agents
        .map((a) => a.toJsonString())
        .toList();
    await _prefs.setStringList(_storageKey, agentsJson);
  }

  Agent _createDefaultAgent() {
    return Agent(
      id: const Uuid().v4(),
      name: 'Default Agent',
      systemPrompt: '',
      // No specific settings for default agent as requested
    );
  }
}
