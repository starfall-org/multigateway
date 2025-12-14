import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ai_gateway/core/storage/provider_repository.dart';
import 'package:ai_gateway/core/models/settings/provider.dart';
import 'add_provider_screen.dart';

import '../../settings/widgets/settings_tile.dart';
import '../../settings/widgets/settings_card.dart';

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
    final provider = _providers.firstWhere((p) => p.id == id);
    await _repository.deleteProvider(id);
    _loadProviders();
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'settings.provider_deleted'.tr(args: [provider.name]),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'settings.providers'.tr(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
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
          ? Center(child: Text('settings.no_providers'.tr()))
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
      },
      child: SettingsTile(
        icon: _getProviderIcon(provider.type),
        iconColor: Colors.blue,
        title: provider.name,
        subtitle: 'settings.models_count'
            .tr(namedArgs: {'count': provider.models.length.toString()}),
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
    return SettingsCard(
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
              'settings.models_count'.tr(
                namedArgs: {'count': provider.models.length.toString()},
              ),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getProviderIcon(ProviderType type) {
    switch (type) {
      case ProviderType.gemini:
        return Icons.android; // Placeholder for Google
      case ProviderType.openai:
        return Icons.smart_toy; // Placeholder for OpenAI
      case ProviderType.anthropic:
        return Icons.psychology; // Placeholder for Anthropic
      case ProviderType.ollama:
        return Icons.pets; // Placeholder for Ollama
    }
  }
}
