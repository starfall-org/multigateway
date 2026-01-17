import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcp/mcp.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/core/llm/models/llm_provider_models.dart';
import 'package:multigateway/core/llm/storage/llm_provider_info_storage.dart';
import 'package:multigateway/core/llm/storage/llm_provider_models_storage.dart';
import 'package:multigateway/core/mcp/storage/mcp_server_info_storage.dart';
import 'package:multigateway/core/profile/profile.dart';
import 'package:multigateway/features/home/services/file_pick_service.dart';
import 'package:multigateway/features/home/services/gallery_pick_service.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:signals/signals.dart';

/// Controller hợp nhất xử lý UI state, attachment, model selection và profile
class UiStateController {
  // === Attachment Management ===
  final pendingFiles = signal<List<String>>([]);
  final inspectingFiles = signal<List<String>>([]);

  // === Model Selection ===
  final LlmProviderInfoStorage pInfStorage;
  final LlmProviderModelsStorage pModStorage;

  StreamSubscription? _providerSubscription;
  final providers = signal<List<LlmProviderInfo>>([]);
  final providerModels = signal<Map<String, List<LlmModel>>>({});
  final providerCollapsed = signal<Map<String, bool>>({});
  final selectedProviderName = signal<String?>(null);
  final selectedModelName = signal<String?>(null);

  // === Profile Management ===
  final ChatProfileStorage aiProfileRepository;
  final McpServerInfoStorage mcpServerStorage;

  final selectedProfile = signal<ChatProfile?>(null);
  final mcpServers = signal<List<McpServer>>([]);

  UiStateController({
    required this.pInfStorage,
    required this.pModStorage,
    required this.aiProfileRepository,
    required this.mcpServerStorage,
  }) {
    _providerSubscription = pInfStorage.changes.listen((_) {
      refreshProviders();
    });
  }

  // === Attachment Methods ===
  Future<void> pickFromFiles(BuildContext context) async {
    try {
      final files = List<String>.from(pendingFiles.value);
      filePickService(files);
      pendingFiles.value = files;
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(tl('Unable to pick files: ${e.toString()}'));
      }
    }
  }

  Future<void> pickFromGallery(BuildContext context) async {
    try {
      final files = List<String>.from(pendingFiles.value);
      galleryPickService(files);
      pendingFiles.value = files;
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(tl('Unable to pick files: ${e.toString()}'));
      }
    }
  }

  void removeAttachmentAt(int index) {
    final files = List<String>.from(pendingFiles.value);
    if (index < 0 || index >= files.length) return;
    files.removeAt(index);
    pendingFiles.value = files;
  }

  void clearPendingAttachments() {
    pendingFiles.value = [];
  }

  void setInspectingAttachments(List<String> attachments) {
    inspectingFiles.value = List<String>.from(attachments);
  }

  void openFilesDialog(List<String> attachments) {
    setInspectingAttachments(attachments);
  }

  void clearInspectingAttachments() {
    inspectingFiles.value = [];
  }

  // === Model Selection Methods ===
  LlmModel? get selectedLlmModel {
    if (selectedProviderName.value == null || selectedModelName.value == null) {
      return null;
    }
    try {
      final provider = providers.value.firstWhere(
        (p) => p.name == selectedProviderName.value,
      );
      final models = providerModels.value[provider.id];
      if (models == null) return null;
      return models.firstWhere((m) => m.id == selectedModelName.value);
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshProviders() async {
    providers.value = pInfStorage.getItems();
    final newProviderModels = <String, List<LlmModel>>{};
    final newCollapsed = Map<String, bool>.from(providerCollapsed.value);

    for (final p in providers.value) {
      newCollapsed.putIfAbsent(p.name, () => false);
      final modelsObj = pModStorage.getItem(p.id);
      if (modelsObj != null) {
        newProviderModels[p.id] = modelsObj.models
            .whereType<LlmModel>()
            .toList();
      } else {
        newProviderModels[p.id] = [];
      }
    }

    providerModels.value = newProviderModels;
    providerCollapsed.value = newCollapsed;
  }

  void setProviderCollapsed(String providerName, bool collapsed) {
    final newCollapsed = Map<String, bool>.from(providerCollapsed.value);
    newCollapsed[providerName] = collapsed;
    providerCollapsed.value = newCollapsed;
  }

  void selectModel(String providerName, String modelName) {
    selectedProviderName.value = providerName;
    selectedModelName.value = modelName;
  }

  void loadSelectionFromSession({String? providerName, String? modelName}) {
    if (providerName != null && modelName != null) {
      selectedProviderName.value = providerName;
      selectedModelName.value = modelName;
    }
  }

  // === Profile Methods ===
  Future<void> loadSelectedProfile() async {
    final profile = await aiProfileRepository.getOrInitSelectedProfile();
    selectedProfile.value = profile;
  }

  Future<void> updateProfile(ChatProfile profile) async {
    selectedProfile.value = profile;
    await aiProfileRepository.saveItem(profile);
  }

  Future<void> loadMcpServers() async {
    mcpServers.value = mcpServerStorage
        .getItems()
        .whereType<McpServer>()
        .toList();
  }

  Future<List<String>> snapshotEnabledToolNames(ChatProfile profile) async {
    try {
      final mcpRepo = await McpServerInfoStorage.instance;
      final servers = profile.activeMcpServerIds
          .map((id) => mcpRepo.getItem(id))
          .whereType<McpServer>()
          .toList();
      final names = <String>{};
      for (final s in servers) {
        for (final t in s.tools) {
          if (t.enabled) names.add(t.name);
        }
      }
      return names.toList();
    } catch (_) {
      return const <String>[];
    }
  }

  void dispose() {
    _providerSubscription?.cancel();
    pendingFiles.dispose();
    inspectingFiles.dispose();
    providers.dispose();
    providerModels.dispose();
    providerCollapsed.dispose();
    selectedProviderName.dispose();
    selectedModelName.dispose();
    selectedProfile.dispose();
    mcpServers.dispose();
  }
}
