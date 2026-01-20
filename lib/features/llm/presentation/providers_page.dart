import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/core/llm/storage/llm_provider_info_storage.dart';
import 'package:multigateway/features/llm/presentation/ui/edit_provider_screen.dart';
import 'package:multigateway/features/llm/presentation/widgets/provider_card.dart';
import 'package:multigateway/features/llm/presentation/widgets/provider_tile.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:multigateway/shared/widgets/confirm_dialog.dart';
import 'package:multigateway/shared/widgets/empty_state.dart';
import 'package:multigateway/shared/widgets/item_card.dart';

class AiProvidersPage extends StatefulWidget {
  const AiProvidersPage({super.key});

  @override
  State<AiProvidersPage> createState() => _AiProvidersPageState();
}

class _AiProvidersPageState extends State<AiProvidersPage> {
  List<LlmProviderInfo> _providers = [];
  bool _isGridView = false;
  LlmProviderInfoStorage? _repository;
  Stream<List<LlmProviderInfo>>? _providersStream;

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    try {
      _repository = await LlmProviderInfoStorage.init().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException(
            'Timeout initializing provider repository',
            const Duration(seconds: 10),
          );
        },
      );
      if (mounted) {
        setState(() {
          _providersStream = _repository!.itemsStream;
        });
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(
          tl('Error loading providers: $e'),
          onAction: () => _initStorage(),
          actionLabel: tl('Retry'),
        );
      }
    }
  }

  Future<void> _deleteProvider(String id) async {
    try {
      await _repository?.deleteItem(id);
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tl('Providers'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              tl('Manage AI providers'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.5,
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
        child: _providersStream == null
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<List<LlmProviderInfo>>(
                stream: _providersStream,
                initialData: _providers,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      snapshot.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final providers = snapshot.data ?? [];
                  _providers = providers; // Keep local ref for reordering logic

                  if (providers.isEmpty) {
                    return EmptyState(
                      message: tl('No providers found'),
                      actionLabel: tl('Add Provider'),
                      onAction: () => _navigateToEdit(null),
                    );
                  }

                  if (_isGridView) {
                    return ReorderableBuilder(
                      onReorder: _onReorderGrid,
                      builder: (children) => GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: children,
                      ),
                      children: providers.map((provider) {
                        return ProviderCard(
                          key: ValueKey(provider.id),
                          provider: provider,
                          layout: ItemCardLayout.grid,
                          onTap: () => _navigateToEdit(provider),
                          onEdit: () => _navigateToEdit(provider),
                          onDelete: () => _confirmDelete(provider),
                        );
                      }).toList(),
                    );
                  }

                  return ReorderableListView.builder(
                    itemCount: providers.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    onReorder: _onReorder,
                    itemBuilder: (context, index) {
                      final provider = providers[index];
                      return ProviderTile(
                        key: ValueKey(provider.id),
                        provider: provider,
                        onTap: () => _navigateToEdit(provider),
                        onEdit: () => _navigateToEdit(provider),
                        onDelete: () => _confirmDelete(provider),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final LlmProviderInfo item = _providers.removeAt(oldIndex);
    _providers.insert(newIndex, item);
    // Optimistic update handled by local list mod, then save calls stream update
    _repository?.saveOrder(_providers.map((e) => e.id).toList());
  }

  void _onReorderGrid(ReorderedListFunction reorderedList) {
    final newOrder = reorderedList(_providers);
    _providers = newOrder.cast<LlmProviderInfo>();
    _repository?.saveOrder(_providers.map((e) => e.id).toList());
  }

  Future<void> _navigateToEdit(LlmProviderInfo? provider) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProviderScreen(providerInfo: provider),
      ),
    );
    // No need to reload manually, stream will update
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
