package org.starfall.multigateway.data.repository

import kotlinx.coroutines.flow.first
import org.starfall.multigateway.data.local.preferences.AppPreferencesRepository
import org.starfall.multigateway.data.model.*

/** Runs once per application process; existing records retain their persisted format. */
class DefaultDataInitializer(
    private val llmRepo: LlmRepository,
    private val mcpRepo: McpRepository,
    private val speechRepo: SpeechRepository,
    private val prefsRepo: AppPreferencesRepository,
) {
    suspend fun initialize() {
        llmRepo.allProviders.first().let { currentProviders ->
            if (currentProviders.isEmpty()) {
                initDefaultProviders()
            } else {
                val legacyGoogle = currentProviders.find { it.id == "google" }
                if (legacyGoogle?.auth?.method == AuthMethod.QUERY_PARAM && legacyGoogle.auth.key.isNullOrBlank()) {
                    llmRepo.saveProvider(legacyGoogle.copy(auth = legacyGoogle.auth.copy(key = "key")))
                }
                val legacyAnthropic = currentProviders.find { it.id == "anthropic" }
                if (legacyAnthropic?.auth?.method == AuthMethod.CUSTOM_HEADER && legacyAnthropic.auth.key.isNullOrBlank()) {
                    llmRepo.saveProvider(legacyAnthropic.copy(auth = Authorization(
                        method = AuthMethod.BEARER_TOKEN,
                        value = legacyAnthropic.auth.value.orEmpty()
                    )))
                }

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

        val prefs = prefsRepo.appPreferencesFlow.first()
        if (!prefs.mcpPresetsInitialized) {
            initDefaultMcpServers()
            prefsRepo.setMcpPresetsInitialized(true)
        }

        speechRepo.allServices.first().let { currentServices ->
            if (currentServices.isEmpty()) {
                initDefaultSpeechServices()
            }
        }
    }

    private suspend fun initDefaultProviders() {
        val openAi = LlmProviderInfo(
            id = "openai",
            name = "OpenAI",
            type = ProviderType.OPENAI,
            baseUrl = "https://api.openai.com/v1",
            auth = ProviderType.OPENAI.defaultAuthorization()
        )
        val google = LlmProviderInfo(
            id = "google",
            name = "Google Gemini",
            type = ProviderType.GOOGLE,
            baseUrl = "https://generativelanguage.googleapis.com/v1beta",
            auth = ProviderType.GOOGLE.defaultAuthorization()
        )
        val anthropic = LlmProviderInfo(
            id = "anthropic",
            name = "Anthropic",
            type = ProviderType.ANTHROPIC,
            baseUrl = "https://api.anthropic.com/v1",
            auth = ProviderType.ANTHROPIC.defaultAuthorization()
        )
        val ollama = LlmProviderInfo(
            id = "ollama",
            name = "Ollama",
            type = ProviderType.OLLAMA,
            baseUrl = "https://ollama.com/api",
            auth = ProviderType.OLLAMA.defaultAuthorization()
        )

        llmRepo.saveProvider(openAi)
        llmRepo.saveProvider(google)
        llmRepo.saveProvider(anthropic)
        llmRepo.saveProvider(ollama)

        prefsRepo.setSelectedModel("ollama", "llama3.2:latest")
    }

    private suspend fun initDefaultMcpServers() {
        listOf(
            McpInfo("preset_firecrawl", "Firecrawl", McpProtocol.STREAMABLE_HTTP, "https://mcp.firecrawl.dev/v2/mcp"),
            McpInfo("preset_tavily", "Tavily", McpProtocol.STREAMABLE_HTTP, "https://mcp.tavily.com/mcp"),
            McpInfo("preset_exa", "Exa", McpProtocol.STREAMABLE_HTTP, "https://mcp.exa.ai/mcp")
        ).forEach { preset ->
            if (mcpRepo.getById(preset.id) == null) mcpRepo.saveServer(preset)
        }
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

}
