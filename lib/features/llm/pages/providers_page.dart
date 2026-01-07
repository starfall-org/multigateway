import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/core/llm/storage/llm_provider_info_storage.dart';
import 'package:multigateway/features/llm/ui/edit_provider_screen.dart';
import 'package:multigateway/features/llm/ui/widgets/provider_card.dart';
import 'package:multigateway/features/llm/ui/widgets/provider_tile.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:multigateway/shared/widgets/confirm_dialog.dart';
import 'package:multigateway/shared/widgets/empty_state.dart';

class AiProvidersPage extends StatefulWidget {
  const AiProvidersPage({super.key});

  @override
  State<AiProvidersPage> createState() => _AiProvidersPageState();
}

class _AiProvidersPageState extends State<AiProvidersPage> {
  List<LlmProviderInfo> _providers = [];
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

      final providers = _repository.getItems();

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

  Future<void> _deleteProvider(String id) async {
    try {
      await _repository.deleteItem(id);
      await _loadProviders();
      if (mounted) {
        context.showSuccessSnackBar(tl('Provider has been deleted'));
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
          // Add button
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: tl('Add Provider'),
            onPressed: () => _navigateToEdit(null),
          ),
          // View toggle button
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            tooltip: _isGridView ? tl('List View') : tl('Grid View'),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
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
                itemBuilder: (context, index) {
                  final provider = _providers[index];
                  return ProviderCard(
                    provider: provider,
                    onTap: () => _navigateToEdit(provider),
                    onEdit: () => _navigateToEdit(provider),
                    onDelete: () => _confirmDelete(provider),
                  );
                },
              )
            : ReorderableListView.builder(
                itemCount: _providers.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  final provider = _providers[index];
                  return ProviderTile(
                    key: ValueKey(provider.id),
                    provider: provider,
                    onTap: () => _navigateToEdit(provider),
                    onEdit: () => _navigateToEdit(provider),
                    onDelete: () => _confirmDelete(provider),
                  );
                },
              ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final LlmProviderInfo item = _providers.removeAt(oldIndex);
      _providers.insert(newIndex, item);
    });
    _repository.saveOrder(_providers.map((e) => e.id).toList());
  }

  Future<void> _navigateToEdit(LlmProviderInfo? provider) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProviderScreen(providerInfo: provider),
      ),
    );
    if (result == true) {
      _loadProviders();
    }
  }

  Future<void> _confirmDelete(LlmProviderInfo provider) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: tl('Delete'),
      content: tl('Are you sure you want to delete ${provider.name}'),
      confirmLabel: tl('Delete'),
      isDestructive: true,
    );

    if (confirm == true) {
      _deleteProvider(provider.id);
    }
  }
}
