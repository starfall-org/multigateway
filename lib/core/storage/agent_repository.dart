import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/agent.dart';
import 'base_repository.dart';

class AgentRepository extends BaseRepository<Agent> {
  static const String _storageKey = 'agents';
  static const String _selectedKey = 'selected_agent_id';

  AgentRepository(super.prefs);

  static Future<AgentRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return AgentRepository(prefs);
  }

  @override
  String get storageKey => _storageKey;

  @override
  Agent deserializeItem(String json) => Agent.fromJsonString(json);

  @override
  String serializeItem(Agent item) => item.toJsonString();

  @override
  String getItemId(Agent item) => item.id;

  @override
  List<Agent> getItems() {
    final items = super.getItems();
    if (items.isEmpty) {
      final defaultAgent = _createDefaultAgent();
      // Persist the default so other features see consistent state
      // Use super.saveItem wouldn't work easily here as it expects an add to generic list, 
      // but we want to initialize the list.
      // We can just use the underlying prefs since we have access to it from base.
      prefs.setStringList(storageKey, [serializeItem(defaultAgent)]);
      
      // Ensure a valid selection exists
      prefs.setString(_selectedKey, defaultAgent.id);
      return [defaultAgent];
    }
    return items;
  }

  List<Agent> getAgents() => getItems();

  Future<void> addAgent(Agent agent) async {
    await saveItem(agent);
    // If no selection yet, select the newly added agent by default
    if (getSelectedAgentId() == null) {
      await setSelectedAgentId(agent.id);
    }
  }

  Future<void> deleteAgent(String id) async {
    await deleteItem(id);

    // Maintain a valid selection after deletion
    final selectedId = getSelectedAgentId();
    if (selectedId == id) {
      final agents = getItems();
      if (agents.isNotEmpty) {
        await setSelectedAgentId(agents.first.id);
      } else {
        await prefs.remove(_selectedKey);
      }
    }
  }

  // --- Selection helpers ---

  String? getSelectedAgentId() => prefs.getString(_selectedKey);

  Future<void> setSelectedAgentId(String id) async {
    await prefs.setString(_selectedKey, id);
  }

  Future<Agent> getOrInitSelectedAgent() async {
    final agents = getItems();
    final selectedId = getSelectedAgentId();
    Agent selected;
    if (selectedId != null) {
      selected = agents.firstWhere(
        (a) => a.id == selectedId,
        orElse: () => agents.first,
      );
    } else {
      selected = agents.isNotEmpty ? agents.first : _createDefaultAgent();
      await setSelectedAgentId(selected.id);
    }
    return selected;
  }

  Agent _createDefaultAgent() {
    return Agent(
      id: const Uuid().v4(),
      name: 'Default Agent',
      systemPrompt: '',
    );
  }
}
