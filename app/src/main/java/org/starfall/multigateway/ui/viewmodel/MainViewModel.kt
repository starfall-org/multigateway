package org.starfall.multigateway.ui.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import org.starfall.multigateway.data.local.db.AppDatabase
import org.starfall.multigateway.data.local.preferences.AppPreferences
import org.starfall.multigateway.data.local.preferences.AppPreferencesRepository
import org.starfall.multigateway.data.model.*
import org.starfall.multigateway.data.repository.*
import org.starfall.multigateway.data.service.LlmService
import org.starfall.multigateway.data.service.McpService
import org.starfall.multigateway.data.service.TtsHelper
import java.util.UUID

class MainViewModel(application: Application) : AndroidViewModel(application) {

    private val db = AppDatabase.getInstance(application)
    val conversationRepo = ConversationRepository(db)
    val profileRepo = ProfileRepository(db)
    val llmRepo = LlmRepository(db)
    val mcpRepo = McpRepository(db)
    val speechRepo = SpeechRepository(db)
    val prefsRepo = AppPreferencesRepository(application)
    val llmService = LlmService()
    val mcpService = McpService()
    val ttsHelper = TtsHelper(application)

    val conversations: StateFlow<List<Conversation>> = conversationRepo.allConversations
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val profiles: StateFlow<List<ChatProfile>> = profileRepo.allProfiles
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val providers: StateFlow<List<LlmProviderInfo>> = llmRepo.allProviders
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val mcpServers: StateFlow<List<McpInfo>> = mcpRepo.allServers
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val speechServices: StateFlow<List<SpeechService>> = speechRepo.allServices
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val appPreferences: StateFlow<AppPreferences> = prefsRepo.appPreferencesFlow
        .stateIn(viewModelScope, SharingStarted.Lazily, AppPreferences())

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

    init {
        viewModelScope.launch {
            llmRepo.allProviders.first().let { currentProviders ->
                if (currentProviders.isEmpty()) {
                    initDefaultProviders()
                } else {
                    val existingOllama = currentProviders.find { it.type == ProviderType.OLLAMA }
                    if (existingOllama != null && (
                            existingOllama.baseUrl.contains("108.181.196.208") ||
                            existingOllama.baseUrl.contains("10.0.2.2") ||
                            existingOllama.baseUrl.contains("localhost")
                        )) {
                        llmRepo.saveProvider(
                            existingOllama.copy(
                                name = "Ollama",
                                baseUrl = "https://ollama.com/api"
                            )
                        )
                    }
                }
            }

            profileRepo.allProfiles.first().let { currentProfiles ->
                if (currentProfiles.isEmpty()) {
                    initDefaultProfiles()
                }
            }

            speechRepo.allServices.first().let { currentServices ->
                if (currentServices.isEmpty()) {
                    initDefaultSpeechServices()
                }
            }
        }
    }

    private suspend fun initDefaultProviders() {
        val openAi = LlmProviderInfo(
            id = "openai",
            name = "OpenAI",
            type = ProviderType.OPENAI,
            baseUrl = "https://api.openai.com/v1",
            auth = Authorization(method = AuthMethod.BEARER_TOKEN, key = "")
        )
        val google = LlmProviderInfo(
            id = "google",
            name = "Google Gemini",
            type = ProviderType.GOOGLE,
            baseUrl = "https://generativelanguage.googleapis.com/v1beta",
            auth = Authorization(method = AuthMethod.QUERY_PARAM, key = "")
        )
        val anthropic = LlmProviderInfo(
            id = "anthropic",
            name = "Anthropic",
            type = ProviderType.ANTHROPIC,
            baseUrl = "https://api.anthropic.com/v1",
            auth = Authorization(method = AuthMethod.CUSTOM_HEADER, key = "")
        )
        val ollama = LlmProviderInfo(
            id = "ollama",
            name = "Ollama",
            type = ProviderType.OLLAMA,
            baseUrl = "https://ollama.com/api",
            auth = Authorization(method = AuthMethod.OTHER, key = "")
        )

        llmRepo.saveProvider(openAi)
        llmRepo.saveProvider(google)
        llmRepo.saveProvider(anthropic)
        llmRepo.saveProvider(ollama)

        prefsRepo.setSelectedModel("ollama", "llama3.2:latest")
    }

    private suspend fun initDefaultProfiles() {
        val general = ChatProfile(
            id = "profile_general",
            name = "General Assistant",
            config = LlmChatConfig(
                systemPrompt = "You are a helpful, capable, and thoughtful AI assistant. Respond clearly and accurately."
            )
        )
        val coding = ChatProfile(
            id = "profile_coding",
            name = "Code Architect",
            config = LlmChatConfig(
                systemPrompt = "You are an expert software engineer and system architect. Provide clean, modular, and idiomatic code with explanations."
            )
        )
        val writer = ChatProfile(
            id = "profile_creative",
            name = "Creative Writer",
            config = LlmChatConfig(
                systemPrompt = "You are an imaginative creative writer, editor, and storyteller. Help users craft engaging stories, prose, and content."
            )
        )

        profileRepo.saveProfile(general)
        profileRepo.saveProfile(coding)
        profileRepo.saveProfile(writer)

        prefsRepo.setSelectedProfileId("profile_general")
    }

    private suspend fun initDefaultSpeechServices() {
        val systemTts = SpeechService(
            id = "system_tts",
            name = "Android System TTS",
            provider = "system",
            voice = "Default",
            speed = 1.0f,
            pitch = 1.0f
        )
        speechRepo.saveService(systemTts)
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
        return generation.start(conv, assistant.id, flow { emitAll(llmService.generateStream(
            provider = provider, modelName = modelId, messages = conv.messages.dropLast(1),
            systemPrompt = profile?.config?.systemPrompt ?: prefs.defaultSystemPrompt
        )) })
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
        generation.start(conv, messageId, flow { emitAll(llmService.generateStream(
            provider = provider, modelName = model, messages = conv.messages.dropLast(1),
            systemPrompt = profile?.config?.systemPrompt ?: prefs.defaultSystemPrompt
        )) })
    }

    fun saveProfile(profile: ChatProfile) {
        viewModelScope.launch {
            profileRepo.saveProfile(profile)
        }
    }

    fun deleteProfile(profileId: String) {
        viewModelScope.launch {
            profileRepo.deleteProfile(profileId)
            if (appPreferences.value.selectedProfileId == profileId) {
                selectProfile(null)
            }
        }
    }

    fun saveModelConfiguration(providerId: String, modelId: String, config: ModelConfiguration) {
        viewModelScope.launch {
            val provider = llmRepo.getProviderById(providerId) ?: return@launch
            llmRepo.saveProvider(provider.copy(config = provider.config.copy(
                modelConfigs = provider.config.modelConfigs + (modelId to config)
            )))
        }
    }

    fun saveProvider(provider: LlmProviderInfo) {
        viewModelScope.launch {
            llmRepo.saveProvider(provider)
            val prefs = appPreferences.value
            val modelIds = provider.config.modelIds
            if (prefs.selectedProviderId == provider.id && modelIds != null && prefs.selectedModelId !in modelIds) {
                prefsRepo.setSelectedModel(provider.id, modelIds.firstOrNull().orEmpty())
            }
        }
    }

    fun deleteProvider(providerId: String) {
        viewModelScope.launch {
            llmRepo.deleteProvider(providerId)
        }
    }

    suspend fun testConnection(provider: LlmProviderInfo): Result<String> {
        return llmService.testConnection(provider)
    }

    suspend fun fetchProviderModels(provider: LlmProviderInfo): List<String> =
        llmService.fetchProviderModels(provider)

    suspend fun fetchOllamaModels(baseUrl: String): List<String> {
        return llmService.fetchOllamaModels(baseUrl)
    }

    fun saveMcpServer(server: McpInfo) {
        viewModelScope.launch {
            mcpRepo.saveServer(server)
        }
    }

    fun deleteMcpServer(serverId: String) {
        viewModelScope.launch {
            mcpRepo.deleteServer(serverId)
        }
    }

    fun saveSpeechService(service: SpeechService) {
        viewModelScope.launch {
            speechRepo.saveService(service)
        }
    }

    fun deleteSpeechService(serviceId: String) {
        viewModelScope.launch {
            speechRepo.deleteService(serviceId)
        }
    }

    override fun onCleared() {
        super.onCleared()
        ttsHelper.shutdown()
    }
}
