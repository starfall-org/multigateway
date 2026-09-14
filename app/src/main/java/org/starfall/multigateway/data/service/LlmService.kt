package org.starfall.multigateway.data.service

import io.ktor.client.*
import io.ktor.client.engine.cio.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.utils.io.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.emitAll
import kotlinx.serialization.json.*
import org.starfall.multigateway.data.model.*

class LlmService {

    private val sdk = OfficialLlmSdk()

    private val json = Json {
        ignoreUnknownKeys = true
        encodeDefaults = true
        isLenient = true
    }

    private val httpClient = HttpClient(CIO) {
        install(ContentNegotiation) {
            json(json)
        }
    }

    fun resolveOllamaChatUrl(baseUrl: String): String {
        var clean = baseUrl.trim().trimEnd('/')
        if (clean.endsWith("/tags")) {
            clean = clean.removeSuffix("/tags").trimEnd('/')
        }
        if (clean.endsWith("/chat")) {
            clean = clean.removeSuffix("/chat").trimEnd('/')
        }
        if (clean.endsWith("/generate")) {
            clean = clean.removeSuffix("/generate").trimEnd('/')
        }
        return if (clean.endsWith("/api")) "$clean/chat" else "$clean/api/chat"
    }

    fun resolveOllamaTagsUrl(baseUrl: String): String {
        var clean = baseUrl.trim().trimEnd('/')
        if (clean.endsWith("/tags")) {
            return clean
        }
        if (clean.endsWith("/chat")) {
            clean = clean.removeSuffix("/chat").trimEnd('/')
        }
        if (clean.endsWith("/generate")) {
            clean = clean.removeSuffix("/generate").trimEnd('/')
        }
        return if (clean.endsWith("/api")) "$clean/tags" else "$clean/api/tags"
    }

    suspend fun testConnection(provider: LlmProviderInfo): Result<String> {
        return try {
            when (provider.type) {
                ProviderType.OLLAMA -> {
                    val tagsUrl = resolveOllamaTagsUrl(provider.baseUrl)
                    val response = httpClient.get(tagsUrl) {
                        applyAuth(provider)
                    }
                    if (response.status.isSuccess()) {
                        val body = response.bodyAsText()
                        val parsed = json.parseToJsonElement(body).jsonObject
                        val models = parsed["models"]?.jsonArray?.mapNotNull {
                            it.jsonObject["name"]?.jsonPrimitive?.contentOrNull
                        } ?: emptyList()
                        if (models.isNotEmpty()) {
                            Result.success("Connected! Found ${models.size} models:\n${models.take(4).joinToString(", ")}${if (models.size > 4) "..." else ""}")
                        } else {
                            Result.success("Connected to Ollama! (0 models installed)")
                        }
                    } else {
                        Result.failure(Exception("HTTP ${response.status.value}: ${response.status.description}"))
                    }
                }
                else -> sdk.testConnection(provider)
            }
        } catch (e: kotlinx.coroutines.CancellationException) {
            throw e
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun fetchOllamaModels(baseUrl: String): List<String> {
        return try {
            val tagsUrl = resolveOllamaTagsUrl(baseUrl)
            val response = httpClient.get(tagsUrl)
            if (response.status.isSuccess()) {
                val body = response.bodyAsText()
                val parsed = json.parseToJsonElement(body).jsonObject
                parsed["models"]?.jsonArray?.mapNotNull {
                    it.jsonObject["name"]?.jsonPrimitive?.contentOrNull
                } ?: emptyList()
            } else {
                emptyList()
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    suspend fun generateStream(
        provider: LlmProviderInfo,
        modelName: String,
        messages: List<StoredMessage>,
        systemPrompt: String = ""
    ): Flow<String> = flow {
        val modelConfig = provider.config.modelConfigs[modelName] ?: ModelConfiguration()
        val requestProvider = provider.copy(config = provider.config.copy(supportStream = provider.streamEnabledFor(modelName)))
        val temperature = modelConfig.temperature
        val topP = modelConfig.topP
        val topK = modelConfig.topK
        val maxTokens = provider.config.maxTokens
        when (provider.type) {
            ProviderType.OPENAI -> {
                emitAll(sdk.streamOpenAi(requestProvider, modelName, messages, systemPrompt, temperature, topP, maxTokens))
            }
            ProviderType.ANTHROPIC -> {
                emitAll(sdk.streamAnthropic(requestProvider, modelName, messages, systemPrompt, temperature, topP, maxTokens, topK))
            }
            ProviderType.GOOGLE -> {
                emitAll(sdk.streamGoogle(requestProvider, modelName, messages, systemPrompt, temperature, topP, maxTokens, topK))
            }
            ProviderType.OLLAMA -> {
                emitAll(streamOllama(requestProvider, modelName, messages, systemPrompt, temperature, topP, maxTokens, topK))
            }
        }
    }

    private fun streamOllama(
        provider: LlmProviderInfo,
        modelName: String,
        messages: List<StoredMessage>,
        systemPrompt: String,
        temperature: Double?,
        topP: Double?,
        maxTokens: Int,
        topK: Int?
    ): Flow<String> = flow {
        val url = resolveOllamaChatUrl(provider.baseUrl)

        val ollamaMessages = mutableListOf<JsonObject>()
        if (systemPrompt.isNotBlank()) {
            ollamaMessages.add(buildJsonObject {
                put("role", "system")
                put("content", systemPrompt)
            })
        }
        for (m in messages) {
            ollamaMessages.add(buildJsonObject {
                put("role", if (m.role == ChatRole.MODEL) "assistant" else "user")
                put("content", m.content)
            })
        }

        val requestBody = buildJsonObject {
            put("model", modelName)
            put("messages", JsonArray(ollamaMessages))
            put("stream", provider.config.supportStream)
            put("options", buildJsonObject {
                put("num_predict", maxTokens)
                temperature?.let { put("temperature", it) }
                topP?.let { put("top_p", it) }
                topK?.let { put("top_k", it) }
            })
        }

        try {
            val response = httpClient.post(url) {
                contentType(ContentType.Application.Json)
                applyAuth(provider)
                setBody(requestBody.toString())
            }

            val channel = response.bodyAsChannel()
            while (!channel.isClosedForRead) {
                val line = channel.readUTF8Line() ?: break
                if (line.isNotBlank()) {
                    try {
                        val parsed = json.parseToJsonElement(line).jsonObject
                        val content = parsed["message"]?.jsonObject?.get("content")?.jsonPrimitive?.contentOrNull
                        if (!content.isNullOrEmpty()) {
                            emit(content)
                        }
                    } catch (_: Exception) {}
                }
            }
        } catch (e: Exception) {
            emit(" [Error: ${e.localizedMessage ?: "Network error"}]")
        }
    }

    private fun HttpRequestBuilder.applyAuth(provider: LlmProviderInfo) {
        val key = provider.auth.key ?: provider.auth.value
        if (!key.isNullOrEmpty()) {
            when (provider.auth.method) {
                AuthMethod.BEARER_TOKEN -> bearerAuth(key)
                AuthMethod.CUSTOM_HEADER -> {
                    val headerName = provider.auth.key ?: "Authorization"
                    val headerVal = provider.auth.value ?: key
                    header(headerName, headerVal)
                }
                AuthMethod.QUERY_PARAM -> {
                    parameter(provider.auth.key ?: "key", provider.auth.value ?: key)
                }
                AuthMethod.OTHER -> {
                    bearerAuth(key)
                }
            }
        }
        provider.config.headers.forEach { (k, v) ->
            header(k, v)
        }
    }
}
