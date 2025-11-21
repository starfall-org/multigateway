import 'package:flutter/material.dart';
import 'package:lmhub/src/core/storage/provider_repository.dart';
import 'package:lmhub/src/features/settings/domain/provider.dart';
import 'add_provider_screen.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  List<LLMProvider> _providers = [];
  bool _isLoading = true;
  bool _isGridView = false;
  late ProviderRepository _repository;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    _repository = await ProviderRepository.init();
    setState(() {
      _providers = _repository.getProviders();
      _isLoading = false;
    });
  }

  Future<void> _deleteProvider(String id) async {
    await _repository.deleteProvider(id);
    _loadProviders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Providers', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProviderScreen(),
                ),
              );
              if (result == true) {
                _loadProviders();
              }
            },
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _providers.isEmpty
          ? const Center(child: Text('No providers configured'))
          : _isGridView
          ? GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: _providers.length,
              itemBuilder: (context, index) =>
                  _buildProviderCard(_providers[index]),
            )
          : ListView.separated(
              itemCount: _providers.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  _buildProviderTile(_providers[index]),
            ),
    );
  }

  Widget _buildProviderTile(LLMProvider provider) {
    return Dismissible(
      key: Key(provider.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteProvider(provider.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${provider.name} deleted')));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(_getProviderIcon(provider.type), color: Colors.blue),
        ),
        title: Text(provider.name),
        subtitle: Text('${provider.models.length} models'),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProviderScreen(provider: provider),
            ),
          );
          if (result == true) {
            _loadProviders();
          }
        },
      ),
    );
  }

  Widget _buildProviderCard(LLMProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProviderScreen(provider: provider),
            ),
          );
          if (result == true) {
            _loadProviders();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getProviderIcon(provider.type),
                size: 32,
                color: Colors.blue,
              ),
              const Spacer(),
              Text(
                provider.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${provider.models.length} models',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getProviderIcon(ProviderType type) {
    switch (type) {
      case ProviderType.google:
        return Icons.android; // Placeholder for Google
      case ProviderType.openai:
        return Icons.smart_toy; // Placeholder for OpenAI
      case ProviderType.anthropic:
        return Icons.psychology; // Placeholder for Anthropic
    }
  }
}
