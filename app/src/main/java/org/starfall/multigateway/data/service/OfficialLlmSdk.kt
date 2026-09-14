package org.starfall.multigateway.data.service

import com.openai.client.OpenAIClientImpl
import com.openai.models.chat.completions.ChatCompletionCreateParams
import com.anthropic.client.okhttp.AnthropicOkHttpClient
import com.anthropic.models.messages.MessageCreateParams
import com.google.genai.Client
import com.google.genai.types.ClientOptions
import com.google.genai.types.Content
import com.google.genai.types.GenerateContentConfig
import com.google.genai.types.HttpOptions
import com.google.genai.types.Part
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.runInterruptible
import okhttp3.OkHttpClient
import org.starfall.multigateway.data.model.*
import java.time.Duration

/** Each operation owns its client and immutable provider snapshot, including credentials.
 * Switching providers cannot redirect an in-flight request or reuse another provider's key.
 */
internal class OfficialLlmSdk {
    private inline fun <R> com.openai.client.OpenAIClient.useClient(block: (com.openai.client.OpenAIClient) -> R): R =
        try { block(this) } finally { close() }

    private inline fun <R> com.anthropic.client.AnthropicClient.useClient(block: (com.anthropic.client.AnthropicClient) -> R): R =
        try { block(this) } finally { close() }

    // SDKs wrap an interrupted socket in their own IOException type. Preserve
    // coroutine cancellation instead of displaying it as a generation failure.
    private suspend fun <T> sdkCall(block: () -> T): T = try {
        runInterruptible(block = block)
    } catch (e: Exception) {
        currentCoroutineContext().ensureActive()
        throw e
    }

    private fun baseUrl(provider: LlmProviderInfo): String {
        var base = provider.baseUrl.trim().trimEnd('/')
        when (provider.type) {
            ProviderType.OPENAI -> for (suffix in listOf("/chat/completions", "/responses", "/models")) {
                if (base.endsWith(suffix)) base = base.removeSuffix(suffix)
            }
            // Anthropic SDK adds /v1/messages itself.
            ProviderType.ANTHROPIC -> {
                base = base.removeSuffix("/messages").removeSuffix("/models").removeSuffix("/v1")
            }
            else -> Unit
        }
        return base
    }

    private fun headers(provider: LlmProviderInfo, nativeHeader: String): Map<String, String> {
        val result = linkedMapOf<String, String>()
        val auth = provider.auth
        when (auth.method) {
            AuthMethod.CUSTOM_HEADER -> if (!auth.key.isNullOrBlank()) result[auth.key] = auth.value.orEmpty()
            AuthMethod.QUERY_PARAM -> Unit
            else -> (auth.key?.takeIf { it.isNotBlank() } ?: auth.value)?.takeIf { it.isNotBlank() }?.let {
                result[nativeHeader] = if (nativeHeader == "Authorization") "Bearer $it" else it
            }
        }
        result.putAll(provider.config.headers)
        return result
    }

    private fun openAi(provider: LlmProviderInfo) = OpenAIClientImpl(com.openai.core.ClientOptions.builder().apply {
        val transport = com.openai.client.okhttp.OkHttpClient.builder().timeout(Duration.ofMinutes(2)).build()
        httpClient(object : com.openai.core.http.HttpClient by transport {
            override fun execute(request: com.openai.core.http.HttpRequest,
                                 requestOptions: com.openai.core.RequestOptions): com.openai.core.http.HttpResponse {
                // Interrupting a blocking socket read does not reliably close the socket.
                // The official async transport cancels its OkHttp call when this future is cancelled.
                val future = transport.executeAsync(request, requestOptions)
                try {
                    return future.get()
                } catch (e: InterruptedException) {
                    future.cancel(true)
                    throw e
                } catch (e: java.util.concurrent.ExecutionException) {
                    throw (e.cause ?: e)
                }
            }
        })
        baseUrl(baseUrl(provider))
        timeout(Duration.ofMinutes(2))
        maxRetries(0)
        // The SDK requires an explicit authentication strategy. Gateways can use
        // headers or query parameters rather than its built-in bearer credential.
        httpRequestAuthenticator(object : com.openai.core.http.HttpRequestAuthenticator {
            override fun authenticate(request: com.openai.core.http.HttpRequest) = request.toBuilder().apply {
                headers(provider, "Authorization").forEach { (key, value) -> putHeader(key, value) }
                if (provider.auth.method == AuthMethod.QUERY_PARAM) {
                    putQueryParam(provider.auth.key ?: "key", provider.auth.value.orEmpty())
                }
            }.build()
        })
    }.build())

    private fun anthropic(provider: LlmProviderInfo) = AnthropicOkHttpClient.builder().apply {
        baseUrl(baseUrl(provider))
        timeout(Duration.ofMinutes(2))
        maxRetries(0)
        headers(provider, "x-api-key").forEach { (key, value) -> putHeader(key, value) }
        if (provider.auth.method == AuthMethod.QUERY_PARAM) {
            putQueryParam(provider.auth.key ?: "key", provider.auth.value.orEmpty())
        }
    }.build()

    private fun google(provider: LlmProviderInfo): Client {
        val base = baseUrl(provider).removeSuffix("/models")
        val version = Regex("/(v1(?:beta|alpha)?)$").find(base)?.groupValues?.get(1)
        // Supply auth in the transport so custom headers/query auth work with gateways too.
        val transport = OkHttpClient.Builder().addInterceptor { chain ->
            val request = chain.request().newBuilder().removeHeader("x-goog-api-key")
            headers(provider, "x-goog-api-key").forEach { (key, value) -> request.header(key, value) }
            if (provider.auth.method == AuthMethod.QUERY_PARAM) {
                request.url(chain.request().url.newBuilder()
                    .setQueryParameter(provider.auth.key ?: "key", provider.auth.value.orEmpty()).build())
            }
            chain.proceed(request.build())
        }.build()
        return Client.builder()
            .apiKey("gateway-auth-configured-in-transport")
            .httpOptions(HttpOptions.builder()
                .baseUrl(if (version == null) base else base.removeSuffix("/$version"))
                .apiVersion(version ?: "v1beta").timeout(120_000).build())
            .clientOptions(ClientOptions.builder().customHttpClient(transport).build())
            .build()
    }

    suspend fun testConnection(provider: LlmProviderInfo): Result<String> = try {
        runInterruptible<Unit>(Dispatchers.IO) {
            when (provider.type) {
                ProviderType.OPENAI -> openAi(provider).useClient { it.models().list() }
                ProviderType.ANTHROPIC -> anthropic(provider).useClient { it.models().list() }
                ProviderType.GOOGLE -> google(provider).use { it.models.list(null).iterator().hasNext() }
                ProviderType.OLLAMA -> error("Use the native Ollama adapter")
            }
        }
        Result.success("${provider.type.displayName} connection successful!")
    } catch (e: CancellationException) {
        throw e
    } catch (e: Exception) {
        currentCoroutineContext().ensureActive()
        Result.failure(e)
    }

    fun streamOpenAi(provider: LlmProviderInfo, modelName: String, messages: List<StoredMessage>,
                     systemPrompt: String, temperature: Double?, topP: Double?, maxTokens: Int): Flow<String> = flow {
        openAi(provider).useClient { client ->
            val params = ChatCompletionCreateParams.builder().model(modelName).maxTokens(maxTokens.toLong())
            if (systemPrompt.isNotBlank()) params.addSystemMessage(systemPrompt)
            messages.forEach { if (it.role == ChatRole.MODEL) params.addAssistantMessage(it.content) else params.addUserMessage(it.content) }
            temperature?.let { params.temperature(it) }
            topP?.let { params.topP(it) }
            if (!provider.config.supportStream) {
                sdkCall { client.chat().completions().create(params.build()) }.choices().firstOrNull()?.message()?.content()?.orElse(null)?.let { emit(it) }
                return@useClient
            }
            sdkCall { client.chat().completions().createStreaming(params.build()) }.use { response ->
                val iterator = response.stream().iterator()
                while (sdkCall { iterator.hasNext() }) {
                    val chunk = iterator.next()
                    chunk.choices().firstOrNull()?.delta()?.content()?.orElse(null)?.let { emit(it) }
                }
            }
        }
    }.flowOn(Dispatchers.IO)

    fun streamAnthropic(provider: LlmProviderInfo, modelName: String, messages: List<StoredMessage>,
                        systemPrompt: String, temperature: Double?, topP: Double?, maxTokens: Int, topK: Int? = null): Flow<String> = flow {
        anthropic(provider).useClient { client ->
            val params = MessageCreateParams.builder().model(modelName).maxTokens(maxTokens.toLong())
            if (systemPrompt.isNotBlank()) params.system(systemPrompt)
            messages.forEach { if (it.role == ChatRole.MODEL) params.addAssistantMessage(it.content) else params.addUserMessage(it.content) }
            temperature?.let { params.temperature(it) }
            topP?.let { params.topP(it) }
            topK?.let { params.topK(it.toLong()) }
            if (!provider.config.supportStream) {
                sdkCall { client.messages().create(params.build()) }.content().forEach { block ->
                    block.text().orElse(null)?.text()?.let { emit(it) }
                }
                return@useClient
            }
            sdkCall { client.messages().createStreaming(params.build()) }.use { response ->
                val iterator = response.stream().iterator()
                while (sdkCall { iterator.hasNext() }) {
                    iterator.next().contentBlockDelta().orElse(null)?.delta()?.text()?.orElse(null)?.text()?.let { emit(it) }
                }
            }
        }
    }.flowOn(Dispatchers.IO)

    fun streamGoogle(provider: LlmProviderInfo, modelName: String, messages: List<StoredMessage>,
                     systemPrompt: String, temperature: Double?, topP: Double?, maxTokens: Int, topK: Int? = null): Flow<String> = flow {
        google(provider).use { client ->
            val contents = messages.map { Content.builder().role(if (it.role == ChatRole.MODEL) "model" else "user")
                .parts(Part.fromText(it.content)).build() }
            val config = GenerateContentConfig.builder().maxOutputTokens(maxTokens)
            if (systemPrompt.isNotBlank()) config.systemInstruction(Content.fromParts(Part.fromText(systemPrompt)))
            temperature?.let { config.temperature(it.toFloat()) }
            topP?.let { config.topP(it.toFloat()) }
            topK?.let { config.topK(it.toFloat()) }
            if (!provider.config.supportStream) {
                sdkCall { client.models.generateContent(modelName.removePrefix("models/"), contents, config.build()) }.text()?.let { emit(it) }
                return@use
            }
            sdkCall { client.models.generateContentStream(modelName.removePrefix("models/"), contents, config.build()) }.use { response ->
                val iterator = response.iterator()
                while (sdkCall { iterator.hasNext() }) {
                    iterator.next().text()?.takeIf { it.isNotEmpty() }?.let { emit(it) }
                }
            }
        }
    }.flowOn(Dispatchers.IO)
}
