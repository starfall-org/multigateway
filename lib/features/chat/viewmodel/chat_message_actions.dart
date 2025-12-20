part of 'chat_viewmodel.dart';

extension ChatViewModelMessageActions on ChatViewModel {
  Future<void> handleSubmitted(String text, BuildContext context) async {
    if (((text.trim().isEmpty) && pendingAttachments.isEmpty) ||
        currentSession == null) {
      return;
    }

    final List<String> attachments = List<String>.from(pendingAttachments);
    textController.clear();

    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.user,
      content: text,
      timestamp: DateTime.now(),
      attachments: attachments,
    );

    currentSession = currentSession!.copyWith(
      messages: [...currentSession!.messages, userMessage],
      updatedAt: DateTime.now(),
    );
    isGenerating = true;
    pendingAttachments.clear();
    notify();

    if (currentSession!.messages.length == 1) {
      final title = ChatLogicUtils.generateTitle(text, attachments);
      currentSession = currentSession!.copyWith(title: title);
    }

    await chatRepository.saveConversation(currentSession!);
    scrollToBottom();

    String modelInput = ChatLogicUtils.formatAttachmentsForPrompt(
      text,
      attachments,
    );

    // Select provider/model based on preferences
    final providerRepo = await ProviderRepository.init();
    final providersList = providerRepo.getProviders();
    final persist = shouldPersistSelections();

    final selection = ChatLogicUtils.resolveProviderAndModel(
      currentSession: currentSession,
      persistSelection: persist,
      selectedProvider: selectedProviderName,
      selectedModel: selectedModelName,
      providers: providersList,
    );

    final providerName = selection.provider;
    final modelName = selection.model;

    // If persistence is enabled and not loaded from session, store selection
    if (currentSession != null &&
        persist &&
        (currentSession!.providerName == null ||
            currentSession!.modelName == null)) {
      currentSession = currentSession!.copyWith(
        providerName: providerName,
        modelName: modelName,
        updatedAt: DateTime.now(),
      );
      await chatRepository.saveConversation(currentSession!);
    }

    // Prepare allowed tool names if persistence is enabled
    List<String>? allowedToolNames;
    if (persist) {
      if (currentSession!.enabledToolNames == null) {
        // Snapshot currently enabled MCP tools from agent for this conversation
        final profile =
            selectedProfile ??
            AIProfile(
              id: const Uuid().v4(),
              name: 'Default Profile',
              config: RequestConfig(systemPrompt: '', enableStream: true),
            );
        final names = await _snapshotEnabledToolNames(profile);
        currentSession = currentSession!.copyWith(
          enabledToolNames: names,
          updatedAt: DateTime.now(),
        );
        await chatRepository.saveConversation(currentSession!);
      }
      allowedToolNames = currentSession!.enabledToolNames;
    }

    final doStream = selectedProfile?.config.enableStream ?? true;
    if (doStream) {
      final stream = ChatService.generateStream(
        userText: modelInput,
        history: currentSession!.messages
            .take(currentSession!.messages.length - 1)
            .toList(),
        profile:
            selectedProfile ??
            AIProfile(
              id: const Uuid().v4(),
              name: 'Default Profile',
              config: RequestConfig(systemPrompt: '', enableStream: true),
            ),
        providerName: providerName,
        modelName: modelName,
        allowedToolNames: allowedToolNames,
      );

      final modelId = const Uuid().v4();
      var acc = '';
      final placeholder = ChatMessage(
        id: modelId,
        role: ChatRole.model,
        content: '',
        timestamp: DateTime.now(),
      );

      currentSession = currentSession!.copyWith(
        messages: [...currentSession!.messages, placeholder],
        updatedAt: DateTime.now(),
      );
      notify();

      try {
        // Track the last time we updated the UI to avoid flickering (throttling)
        DateTime lastUpdate = DateTime.now();
        const throttleDuration = Duration(milliseconds: 100);

        await for (final chunk in stream) {
          if (chunk.isEmpty) continue;
          acc += chunk;
          
          final now = DateTime.now();
          if (now.difference(lastUpdate) < throttleDuration) {
            // Just accumulate the text, don't update UI yet unless it's a large chunk?
            // For smoother typing effect, we might want consistent updates, but 100ms is ~10fps which is good for reading.
            continue;
          }

          final wasAtBottom = isNearBottom();
          
          final msgs = List<ChatMessage>.from(currentSession!.messages);
          final idx = msgs.indexWhere((m) => m.id == modelId);
          if (idx != -1) {
            final old = msgs[idx];
            msgs[idx] = ChatMessage(
              id: old.id,
              role: old.role,
              content: acc,
              timestamp: old.timestamp,
              attachments: old.attachments,
              reasoningContent: old.reasoningContent,
              aiMedia: old.aiMedia,
            );
            currentSession = currentSession!.copyWith(
              messages: msgs,
              updatedAt: DateTime.now(),
            );
            notify();
            
            if (wasAtBottom) {
              scrollToBottom();
            }
            lastUpdate = now;
          }
        }

        // Final update after stream ends to ensure all text is shown
        final msgs = List<ChatMessage>.from(currentSession!.messages);
        final idx = msgs.indexWhere((m) => m.id == modelId);
        if (idx != -1) {
          final old = msgs[idx];
          // Update one last time if acc has more content than currently shown
          if (old.content != acc) {
             msgs[idx] = ChatMessage(
              id: old.id,
              role: old.role,
              content: acc,
              timestamp: old.timestamp,
              attachments: old.attachments,
              reasoningContent: old.reasoningContent,
              aiMedia: old.aiMedia,
            );
            currentSession = currentSession!.copyWith(
              messages: msgs,
              updatedAt: DateTime.now(),
            );
          }
        }

      } finally {
        isGenerating = false;
        notify();
        // Force scroll to bottom when done if the user was following along
        if (isNearBottom()) {
          scrollToBottom();
        }
        await chatRepository.saveConversation(currentSession!);
      }
    } else {
      final reply = await ChatService.generateReply(
        userText: modelInput,
        history: currentSession!.messages
            .take(currentSession!.messages.length - 1)
            .toList(),
        profile:
            selectedProfile ??
            AIProfile(
              id: const Uuid().v4(),
              name: 'Default Profile',
              config: RequestConfig(systemPrompt: '', enableStream: true),
            ),
        providerName: providerName,
        modelName: modelName,
        allowedToolNames: allowedToolNames,
      );

      final modelMessage = ChatMessage(
        id: const Uuid().v4(),
        role: ChatRole.model,
        content: reply,
        timestamp: DateTime.now(),
      );

      currentSession = currentSession!.copyWith(
        messages: [...currentSession!.messages, modelMessage],
        updatedAt: DateTime.now(),
      );
      isGenerating = false;
      notify();

      await chatRepository.saveConversation(currentSession!);
      scrollToBottom();
    }
  }

  Future<void> regenerateLast(BuildContext context) async {
    if (currentSession == null || currentSession!.messages.isEmpty) return;

    final msgs = currentSession!.messages;
    int lastUserIndex = -1;
    for (int i = msgs.length - 1; i >= 0; i--) {
      if (msgs[i].role == ChatRole.user) {
        lastUserIndex = i;
        break;
      }
    }
    if (lastUserIndex == -1) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('chat.no_user_to_regen'.tr())));
      }
      return;
    }

    final userText = msgs[lastUserIndex].content;
    final history = msgs.take(lastUserIndex).toList();

    isGenerating = true;
    notify();

    final providerRepo = await ProviderRepository.init();
    final providersList = providerRepo.getProviders();
    final persist = shouldPersistSelections();

    final selection = ChatLogicUtils.resolveProviderAndModel(
      currentSession: currentSession,
      persistSelection: persist,
      selectedProvider: selectedProviderName,
      selectedModel: selectedModelName,
      providers: providersList,
    );

    final providerName = selection.provider;
    final modelName = selection.model;

    if (currentSession != null &&
        persist &&
        (currentSession!.providerName == null ||
            currentSession!.modelName == null)) {
      currentSession = currentSession!.copyWith(
        providerName: providerName,
        modelName: modelName,
        updatedAt: DateTime.now(),
      );
      await chatRepository.saveConversation(currentSession!);
    }

    List<String>? allowedToolNames;
    if (persist) {
      if (currentSession!.enabledToolNames == null) {
        final profile =
            selectedProfile ??
            AIProfile(
              id: const Uuid().v4(),
              name: 'Default Profile',
              config: RequestConfig(systemPrompt: '', enableStream: true),
            );
        final names = await _snapshotEnabledToolNames(profile);
        currentSession = currentSession!.copyWith(
          enabledToolNames: names,
          updatedAt: DateTime.now(),
        );
        await chatRepository.saveConversation(currentSession!);
      }
      allowedToolNames = currentSession!.enabledToolNames;
    }

    final doStream = selectedProfile?.config.enableStream ?? true;
    if (doStream) {
      final stream = ChatService.generateStream(
        userText: userText,
        history: history,
        profile:
            selectedProfile ??
            AIProfile(
              id: const Uuid().v4(),
              name: 'Default Profile',
              config: RequestConfig(systemPrompt: '', enableStream: true),
            ),
        providerName: providerName,
        modelName: modelName,
        allowedToolNames: allowedToolNames,
      );

      final modelId = const Uuid().v4();
      var acc = '';
      final placeholder = ChatMessage(
        id: modelId,
        role: ChatRole.model,
        content: '',
        timestamp: DateTime.now(),
      );

      final baseMessages = [...history, msgs[lastUserIndex]];
      currentSession = currentSession!.copyWith(
        messages: [...baseMessages, placeholder],
        updatedAt: DateTime.now(),
      );
      notify();

      try {
        DateTime lastUpdate = DateTime.now();
        const throttleDuration = Duration(milliseconds: 100);

        await for (final chunk in stream) {
          if (chunk.isEmpty) continue;
          acc += chunk;

          final now = DateTime.now();
          if (now.difference(lastUpdate) < throttleDuration) {
            continue;
          }

          final wasAtBottom = isNearBottom();

          final msgs2 = List<ChatMessage>.from(currentSession!.messages);
          final idx = msgs2.indexWhere((m) => m.id == modelId);
          if (idx != -1) {
            final old = msgs2[idx];
            msgs2[idx] = ChatMessage(
              id: old.id,
              role: old.role,
              content: acc,
              timestamp: old.timestamp,
              attachments: old.attachments,
              reasoningContent: old.reasoningContent,
              aiMedia: old.aiMedia,
            );
            currentSession = currentSession!.copyWith(
              messages: msgs2,
              updatedAt: DateTime.now(),
            );
            notify();
            
            if (wasAtBottom) {
              scrollToBottom();
            }
            lastUpdate = now;
          }
        }
        
        // Final update
        final msgs2 = List<ChatMessage>.from(currentSession!.messages);
        final idx = msgs2.indexWhere((m) => m.id == modelId);
        if (idx != -1) {
          final old = msgs2[idx];
          if (old.content != acc) {
             msgs2[idx] = ChatMessage(
              id: old.id,
              role: old.role,
              content: acc,
              timestamp: old.timestamp,
              attachments: old.attachments,
              reasoningContent: old.reasoningContent,
              aiMedia: old.aiMedia,
            );
            currentSession = currentSession!.copyWith(
              messages: msgs2,
              updatedAt: DateTime.now(),
            );
          }
        }

      } finally {
        isGenerating = false;
        notify();
        if (isNearBottom()) {
          scrollToBottom();
        }
        await chatRepository.saveConversation(currentSession!);
      }
    } else {
      final reply = await ChatService.generateReply(
        userText: userText,
        history: history,
        profile:
            selectedProfile ??
            AIProfile(
              id: const Uuid().v4(),
              name: 'Default Profile',
              config: RequestConfig(systemPrompt: '', enableStream: true),
            ),
        providerName: providerName,
        modelName: modelName,
        allowedToolNames: allowedToolNames,
      );

      final modelMessage = ChatMessage(
        id: const Uuid().v4(),
        role: ChatRole.model,
        content: reply,
        timestamp: DateTime.now(),
      );

      final newMessages = [...history, msgs[lastUserIndex], modelMessage];

      currentSession = currentSession!.copyWith(
        messages: newMessages,
        updatedAt: DateTime.now(),
      );
      isGenerating = false;
      notify();

      await chatRepository.saveConversation(currentSession!);
      scrollToBottom();
    }
  }
}
