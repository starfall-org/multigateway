package org.starfall.multigateway.data.service

import io.ktor.client.*
import io.ktor.client.engine.cio.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.utils.io.*
import kotlinx.coroutines.flow.*
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

    suspend fun testModel(provider: LlmProviderInfo, modelId: String): Result<String> {
        return try {
            require(modelId.isNotBlank()) { "Model ID is empty" }
            val modelConfig = provider.config.modelConfigs[modelId] ?: ModelConfiguration()
            require(modelConfig.modelType == ModelType.TEXT_GENERATION) {
                "${modelConfig.modelType.displayName} models cannot be tested with a text request"
            }
            val testProvider = provider.copy(config = provider.config.copy(
                supportStream = false,
                maxTokens = minOf(provider.config.maxTokens, 64),
                modelConfigs = provider.config.modelConfigs + (modelId to modelConfig.copy(supportStream = false))
            ))
            val message = StoredMessage(
                id = "connection-test",
                role = ChatRole.USER,
                versions = listOf(MessageVersion(content = "Reply with OK."))
            )
            val outputBuilder = StringBuilder()
            streamContent(testProvider, modelId, listOf(message)).collect { chunk ->
                if (outputBuilder.length < 500) {
                    outputBuilder.append(chunk.take(500 - outputBuilder.length))
                }
            }
            val output = outputBuilder.toString().trim()
            if (output.startsWith("[Error:") || output.startsWith(" [Error:")) {
                Result.failure(Exception(output.trim()))
            } else {
                Result.success(if (output.isBlank()) "Model request completed successfully" else output)
            }
        } catch (e: kotlinx.coroutines.CancellationException) {
            throw e
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun fetchProviderModels(provider: LlmProviderInfo): List<String> {
        var base = provider.baseUrl.trim().trimEnd('/')
        for (suffix in listOf("/chat/completions", "/responses", "/messages", "/models", "/chat", "/tags", "/generate")) {
            base = base.removeSuffix(suffix)
        }
        val endpoint = provider.config.customListModelsUrl?.takeIf { it.isNotBlank() } ?: when (provider.type) {
            ProviderType.OLLAMA -> base.removeSuffix("/api").removeSuffix("/v1") + "/v1/models"
            ProviderType.ANTHROPIC -> base.removeSuffix("/v1") + "/v1/models"
            ProviderType.GOOGLE -> if (Regex("/v1(?:beta|alpha)?$").containsMatchIn(base)) "$base/models" else "$base/v1beta/models"
            ProviderType.OPENAI, ProviderType.OPENAI_RESPONSES -> "$base/models"
        }
        val models = linkedSetOf<String>()
        var cursor: String? = null
        val seenCursors = mutableSetOf<String>()
        do {
            val response = httpClient.get(endpoint) {
                val auth = provider.auth
                when (auth.method) {
                    AuthMethod.CUSTOM_HEADER -> auth.key?.takeIf { it.isNotBlank() }?.let { header(it, auth.value.orEmpty()) }
                    AuthMethod.QUERY_PARAM -> parameter(auth.key ?: "key", auth.value.orEmpty())
                    else -> auth.token.takeIf { it.isNotBlank() }?.let { token ->
                        when (provider.type) {
                            ProviderType.ANTHROPIC -> header("x-api-key", token)
                            ProviderType.GOOGLE -> header("x-goog-api-key", token)
                            else -> bearerAuth(token)
                        }
                    }
                }
                if (provider.type == ProviderType.ANTHROPIC) header("anthropic-version", "2023-06-01")
                provider.config.headers.forEach { (name, value) -> headers.remove(name); header(name, value) }
                cursor?.let { parameter(if (provider.type == ProviderType.GOOGLE) "pageToken" else "after_id", it) }
            }
            check(response.status.isSuccess()) { "Unable to load models: HTTP ${response.status.value}" }
            val body = json.parseToJsonElement(response.bodyAsText()).jsonObject
            val entries = (body["data"] ?: body["models"]) as? JsonArray
                ?: error("The models endpoint returned an unsupported response.")
            entries.forEach { entry ->
                val item = entry as? JsonObject ?: return@forEach
                val id = (item["id"] ?: item["name"])?.jsonPrimitive?.contentOrNull
                id?.takeIf { it.isNotBlank() }?.let {
                    models += if (provider.type == ProviderType.GOOGLE) it.removePrefix("models/") else it
                }
            }
            cursor = when {
                provider.type == ProviderType.GOOGLE -> body["nextPageToken"]?.jsonPrimitive?.contentOrNull
                provider.type == ProviderType.ANTHROPIC && body["has_more"]?.jsonPrimitive?.booleanOrNull == true ->
                    body["last_id"]?.jsonPrimitive?.contentOrNull
                else -> null
            }?.takeIf { it.isNotBlank() }
            check(cursor == null || seenCursors.add(cursor!!)) { "The models endpoint repeated a page." }
        } while (cursor != null)
        return models.toList()
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

    fun streamEvents(
        provider: LlmProviderInfo,
        modelName: String,
        messages: List<StoredMessage>,
        systemPrompt: String = ""
    ): Flow<GenerationEvent> = flow {
        val modelConfig = provider.config.modelConfigs[modelName] ?: ModelConfiguration()
        val requestProvider = provider.copy(config = provider.config.copy(supportStream = provider.streamEnabledFor(modelName)))
        val temperature = modelConfig.temperature
        val topP = modelConfig.topP
        val topK = modelConfig.topK
        val maxTokens = provider.config.maxTokens
        when (provider.type) {
            ProviderType.OPENAI -> emitAll(
                sdk.streamOpenAi(
                    requestProvider, modelName, messages, systemPrompt,
                    temperature, topP, maxTokens, modelConfig.reasoningEffort, modelConfig.sendThinkingContent
                )
            )
            ProviderType.OPENAI_RESPONSES -> emitAll(
                sdk.streamResponses(
                    requestProvider, modelName, messages, systemPrompt,
                    temperature, topP, maxTokens, modelConfig.reasoningEffort, modelConfig.sendThinkingContent
                )
            )
            ProviderType.ANTHROPIC -> emitAll(
                sdk.streamAnthropic(
                    requestProvider, modelName, messages, systemPrompt,
                    temperature, topP, maxTokens, topK, modelConfig.sendThinkingContent
                )
            )
            ProviderType.GOOGLE -> emitAll(
                sdk.streamGoogle(
                    requestProvider, modelName, messages, systemPrompt,
                    temperature, topP, maxTokens, topK, modelConfig.sendThinkingContent
                )
            )
            ProviderType.OLLAMA -> streamOllama(
                requestProvider, modelName, messages, systemPrompt,
                temperature, topP, maxTokens, topK
            ).collect { emit(GenerationEvent.Text(it)) }
        }
    }

    suspend fun streamContent(
        provider: LlmProviderInfo,
        modelName: String,
        messages: List<StoredMessage>,
        systemPrompt: String = ""
    ): Flow<String> = streamEvents(provider, modelName, messages, systemPrompt)
        .transform { event ->
            if (event is GenerationEvent.Text) emit(event.text)
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
        for (message in messages) {
            ollamaMessages.add(buildJsonObject {
                put("role", if (message.role == ChatRole.MODEL) "assistant" else "user")
                put("content", message.content)
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
                        if (!content.isNullOrEmpty()) emit(content)
                    } catch (_: Exception) {
                    }
                }
            }
        } catch (e: Exception) {
            emit(" [Error: ${e.localizedMessage ?: "Network error"}]")
        }
    }

    private fun HttpRequestBuilder.applyAuth(provider: LlmProviderInfo) {
        val key = provider.auth.token
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
