import 'dart:async';
import 'package:flutter/material.dart';

import 'package:llm/llm.dart';
import '../../../../core/llm/data/provider_info_storage.dart';
import '../../../../app/translate/tl.dart';
import '../../../../shared/widgets/resource_tile.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/item_card.dart';
import '../../../../shared/utils/icon_builder.dart';
import '../views/edit_provider_screen.dart';

class AiProvidersPage extends StatefulWidget {
  const AiProvidersPage({super.key});

  @override
  State<AiProvidersPage> createState() => _AiProvidersPageState();
}

class _AiProvidersPageState extends State<AiProvidersPage> {
  List<Provider> _providers = [];
  bool _isLoading = true;
  bool _isGridView = false;
  late LlmProviderInfoStorage _repository;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    // Only prevent if already loading (not the initial state)
    if (_isLoading && _providers.isNotEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Add timeout to prevent infinite loading
      _repository = await LlmProviderInfoStorage.init().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException(
            'Timeout initializing provider repository',
            const Duration(seconds: 10),
          );
        },
      );

      final providers = _repository.getProviders();

      if (mounted) {
        setState(() {
          _providers = providers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        context.showErrorSnackBar(
          tl('Error loading providers: $e'),
          onAction: () => _loadProviders(),
          actionLabel: tl('Retry'),
        );
      }
    }
  }

  Future<void> _deleteProvider(String name) async {
    try {
      await _repository.deleteProvider(name);
      await _loadProviders(); // Use await to ensure proper sequencing
      if (mounted) {
        context.showSuccessSnackBar(tl('Provider $name has been deleted'));
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(tl('Error deleting provider: $e'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tl('Providers')),
        actions: [
          AddAction(
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
          ViewToggleAction(
            isGrid: _isGridView,
            onChanged: (val) {
              setState(() {
                _isGridView = val;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _providers.isEmpty
            ? EmptyState(
                message: tl('No providers found'),
                actionLabel: tl('Add Provider'),
                onAction: () async {
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
              )
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
            : ReorderableListView.builder(
                itemCount: _providers.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                onReorder: _onReorder,
                itemBuilder: (context, index) =>
                    _buildProviderTile(_providers[index], index),
              ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final Provider item = _providers.removeAt(oldIndex);
      _providers.insert(newIndex, item);
    });
    _repository.saveOrder(_providers.map((e) => e.name).toList());
  }

  Widget _buildProviderTile(Provider provider, int index) {
    return ResourceTile(
      key: ValueKey(provider.name),
      title: provider.name,
      subtitle: '${provider.models.length} models',
      leadingIcon: buildIcon(provider.name),
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
      onDelete: () => _confirmDelete(provider),
      onEdit: () async {
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
    );
  }

  Widget _buildProviderCard(Provider provider) {
    return ItemCard(
      icon: buildIcon(provider.name),
      title: provider.name,
      subtitle: tl('${provider.type.name} Compatible'),
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
      onEdit: () async {
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
      onDelete: () => _confirmDelete(provider),
    );
  }

  Future<void> _confirmDelete(Provider provider) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: tl('Delete'),
      content: tl('Are you sure you want to delete ${provider.name}'),
      confirmLabel: tl('Delete'),
      isDestructive: true,
    );

    if (confirm == true) {
      _deleteProvider(
        provider.name,
      ); // Using name as ID based on repo implementation
    }
  }
}
