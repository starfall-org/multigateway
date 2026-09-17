package org.starfall.multigateway.ui.chat

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import org.starfall.multigateway.data.local.preferences.AppPreferences
import org.starfall.multigateway.data.local.preferences.AppPreferencesRepository
import org.starfall.multigateway.data.model.*
import org.starfall.multigateway.data.repository.*
import org.starfall.multigateway.data.service.TtsHelper
import java.util.UUID
import org.starfall.multigateway.data.tools.*

class ChatViewModel(
    private val conversationRepo: ConversationRepository,
    private val profileRepo: ProfileRepository,
    private val llmRepo: LlmRepository,
    private val mcpRepo: McpRepository,
    private val prefsRepo: AppPreferencesRepository,
    private val toolChat: ToolChat,
    private val toolStore: ToolSettingsStore,
    private val ttsHelper: TtsHelper,
) : ViewModel() {

    val toolSettings = toolStore.settings.stateIn(viewModelScope, SharingStarted.Eagerly, ToolSettings())
    fun setSystemTool(name: String, config: SystemToolConfig) { viewModelScope.launch { toolStore.update { it.copy(system = it.system + (name to config)) } } }
    fun setQuickMcp(id: String, enabled: Boolean) { viewModelScope.launch { toolStore.update { it.copy(quickMcp = it.quickMcp + (id to enabled)) } } }
    private fun toolEvents(provider: LlmProviderInfo, model: String, messages: List<StoredMessage>, profile: ChatProfile?, prompt: String) =
        toolChat.generate(provider, model, messages, prompt, mcpServers.value, providers.value,
            access = { profiles.value.find { it.id == profile?.id }?.config?.mcpAccess ?: emptyMap() },
            settings = { toolSettings.value })

    val conversations: StateFlow<List<Conversation>> = conversationRepo.allConversations
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val profiles: StateFlow<List<ChatProfile>> = profileRepo.allProfiles
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val providers: StateFlow<List<LlmProviderInfo>> = llmRepo.allProviders
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val mcpServers: StateFlow<List<McpInfo>> = mcpRepo.allServers
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    private val appPreferences: StateFlow<AppPreferences> = prefsRepo.appPreferencesFlow
        .stateIn(viewModelScope, SharingStarted.Eagerly, AppPreferences())

    private val _currentConversation = MutableStateFlow<Conversation?>(null)
    val currentConversation: StateFlow<Conversation?> = _currentConversation.asStateFlow()

    private val generation = ChatGeneration(viewModelScope, conversationRepo::saveConversation) { updated ->
        if (_currentConversation.value?.id == updated.id) _currentConversation.value = updated
    }
    val isGenerating = generation.busy
    val chatError = generation.error
    val generatingConversationId = generation.conversationId
    private var pendingConversationWrites = 0

    private fun writeConversation(block: suspend () -> Unit) {
        pendingConversationWrites++
        viewModelScope.launch {
            try { block() } finally { pendingConversationWrites-- }
        }
    }

    fun selectConversation(conversation: Conversation) {
        _currentConversation.value = generation.snapshot?.takeIf { it.id == conversation.id } ?: conversation
    }

    fun startNewChat() {
        _currentConversation.value = null
    }

    fun deleteConversation(id: String) {
        writeConversation {
            if (generation.snapshot?.id == id) generation.stopAndJoin()
            conversationRepo.deleteConversation(id)
            if (_currentConversation.value?.id == id) {
                _currentConversation.value = null
            }
        }
    }

    fun renameConversation(id: String, newTitle: String) {
        writeConversation {
            if (generation.snapshot?.id == id) generation.stopAndJoin()
            val conv = conversationRepo.getById(id) ?: return@writeConversation
            val updated = conv.copy(title = newTitle, updatedAt = System.currentTimeMillis())
            conversationRepo.saveConversation(updated)
            if (_currentConversation.value?.id == id) {
                _currentConversation.value = updated
            }
        }
    }

    fun clearAllConversations() {
        writeConversation {
            generation.stopAndJoin()
            conversationRepo.deleteAll()
            _currentConversation.value = null
        }
    }

    fun deleteAllUserData() {
        writeConversation {
            generation.stopAndJoin()
            conversationRepo.deleteAll()
            _currentConversation.value = null
            // Also reset active profile to default
            prefsRepo.setSelectedProfileId(null)
        }
    }

    fun cleanCache() {
        // Clear cached responses and stopped streams
        stopGeneration()
        stopSpeaking()
    }

    fun selectProfile(profileId: String?) {
        viewModelScope.launch {
            prefsRepo.setSelectedProfileId(profileId)
        }
    }

    fun selectModel(providerId: String, modelId: String) {
        viewModelScope.launch {
            val provider = llmRepo.getProviderById(providerId)
            if (provider?.config?.modelIds != null && modelId !in provider.config.modelIds) {
                llmRepo.saveProvider(provider.copy(config = provider.config.copy(
                    modelIds = provider.config.modelIds + modelId,
                    modelConfigs = provider.config.modelConfigs + (modelId to ModelConfiguration())
                )))
            }
            prefsRepo.setSelectedModel(providerId, modelId)
        }
    }

    fun speakText(text: String) {
        ttsHelper.speak(text)
    }

    fun testVoice(text: String, speed: Float, pitch: Float) = ttsHelper.speak(text, speed, pitch)

    fun stopSpeaking() {
        ttsHelper.stop()
    }

    fun sendMessage(userText: String, fileAttachments: List<String> = emptyList()): Boolean {
        if (userText.isBlank() || isGenerating.value || pendingConversationWrites > 0 || fileAttachments.isNotEmpty()) return false
        val prefs = appPreferences.value
        val provider = providers.value.find { it.id == prefs.selectedProviderId } ?: return false
        val modelId = prefs.selectedModelId.takeIf { it.isNotBlank() } ?: return false
        val profile = profiles.value.find { it.id == prefs.selectedProfileId }
        val now = System.currentTimeMillis()
        val user = StoredMessage(UUID.randomUUID().toString(), ChatRole.USER,
            listOf(MessageVersion(content = userText, timestamp = now.toString())))
        val assistant = StoredMessage(UUID.randomUUID().toString(), ChatRole.MODEL,
            listOf(MessageVersion(timestamp = now.toString())))
        val existing = _currentConversation.value
        val conv = (existing ?: Conversation(
            id = UUID.randomUUID().toString(),
            title = userText.take(30) + if (userText.length > 30) "..." else "",
            createdAt = now, updatedAt = now
        )).copy(
            messages = (existing?.messages ?: emptyList()) + user + assistant,
            updatedAt = now, providerId = provider.id, modelId = modelId, profileId = profile?.id
        )
        _currentConversation.value = conv
        return generation.startEvents(conv, assistant.id, toolEvents(provider, modelId, conv.messages.dropLast(1), profile,
            profile?.config?.systemPrompt ?: prefs.defaultSystemPrompt))
    }

    fun stopGeneration() { generation.stop() }

    fun editMessage(messageId: String, newContent: String) {
        if (isGenerating.value || pendingConversationWrites > 0) return
        val conv = _currentConversation.value ?: return
        val currentMsgs = conv.messages.toMutableList()
        val idx = currentMsgs.indexOfFirst { it.id == messageId }
        if (idx != -1) {
            val oldMsg = currentMsgs[idx]
            val newVersions = oldMsg.versions.toMutableList()
            newVersions.add(MessageVersion(content = newContent, timestamp = System.currentTimeMillis().toString()))
            currentMsgs[idx] = oldMsg.copy(
                versions = newVersions,
                activeVersionIndex = newVersions.size - 1
            )
            val updated = conv.copy(messages = currentMsgs, updatedAt = System.currentTimeMillis())
            _currentConversation.value = updated
            writeConversation { conversationRepo.saveConversation(updated) }
        }
    }

    fun deleteMessage(messageId: String) {
        if (isGenerating.value || pendingConversationWrites > 0) return
        val conv = _currentConversation.value ?: return
        val currentMsgs = conv.messages.filter { it.id != messageId }
        val updated = conv.copy(messages = currentMsgs, updatedAt = System.currentTimeMillis())
        _currentConversation.value = updated
        writeConversation { conversationRepo.saveConversation(updated) }
    }

    fun switchMessageVersion(messageId: String, versionIndex: Int) {
        if (isGenerating.value || pendingConversationWrites > 0) return
        val conv = _currentConversation.value ?: return
        val currentMsgs = conv.messages.toMutableList()
        val idx = currentMsgs.indexOfFirst { it.id == messageId }
        if (idx != -1) {
            val oldMsg = currentMsgs[idx]
            if (versionIndex in oldMsg.versions.indices) {
                currentMsgs[idx] = oldMsg.copy(activeVersionIndex = versionIndex)
                val updated = conv.copy(messages = currentMsgs)
                _currentConversation.value = updated
                writeConversation { conversationRepo.saveConversation(updated) }
            }
        }
    }

    fun regenerateMessage(messageId: String) {
        if (isGenerating.value || pendingConversationWrites > 0) return
        val current = _currentConversation.value ?: return
        val prefs = appPreferences.value
        val provider = providers.value.find { it.id == prefs.selectedProviderId } ?: return
        val model = prefs.selectedModelId.takeIf { it.isNotBlank() } ?: return
        val profile = profiles.value.find { it.id == prefs.selectedProfileId }
        val conv = prepareRegeneration(current, messageId)?.copy(
            providerId = provider.id, modelId = model, profileId = profile?.id
        ) ?: return
        generation.startEvents(conv, messageId, toolEvents(provider, model, conv.messages.dropLast(1), profile,
            profile?.config?.systemPrompt ?: prefs.defaultSystemPrompt))
    }

    override fun onCleared() {
        super.onCleared()
        ttsHelper.shutdown()
    }
}
