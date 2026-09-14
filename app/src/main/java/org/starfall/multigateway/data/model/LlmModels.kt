package org.starfall.multigateway.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

enum class ProviderType(val displayName: String) {
    @SerialName("openai") OPENAI("OpenAI"),
    @SerialName("google") GOOGLE("Google"),
    @SerialName("anthropic") ANTHROPIC("Anthropic"),
    @SerialName("ollama") OLLAMA("Ollama")
}

enum class AuthMethod {
    @SerialName("query_param") QUERY_PARAM,
    @SerialName("bearer_token") BEARER_TOKEN,
    @SerialName("custom_header") CUSTOM_HEADER,
    @SerialName("other") OTHER
}

@Serializable
data class Authorization(
    val method: AuthMethod = AuthMethod.BEARER_TOKEN,
    val key: String? = null,
    val value: String? = null
)

@Serializable
data class ProviderConfiguration(
    val httpProxy: Map<String, String> = emptyMap(),
    val socksProxy: Map<String, String> = emptyMap(),
    val supportStream: Boolean = true,
    val headers: Map<String, String> = emptyMap(),
    val responsesApi: Boolean = false,
    val customListModelsUrl: String? = null,
    val maxTokens: Int = 4000,
    // Model IDs are scoped to this provider, including custom gateway models.
    val modelConfigs: Map<String, ModelConfiguration> = emptyMap()
)

@Serializable
data class LlmProviderInfo(
    val id: String,
    val name: String,
    val type: ProviderType,
    val auth: Authorization = Authorization(),
    val icon: String? = null,
    val baseUrl: String,
    val config: ProviderConfiguration = ProviderConfiguration()
)

@Serializable
data class Capabilities(
    val text: Boolean = true,
    val image: Boolean = false,
    val video: Boolean = false,
    val embed: Boolean = false,
    val audio: Boolean = false,
    val others: String? = null
)

@Serializable
data class LlmModel(
    val id: String,
    @SerialName("display_name") val displayName: String,
    val icon: String? = null,
    @SerialName("provider_id") val providerId: String,
    @SerialName("input_capabilities") val inputCapabilities: Capabilities = Capabilities(),
    @SerialName("output_capabilities") val outputCapabilities: Capabilities = Capabilities()
)

@Serializable
data class LlmProviderModels(
    val id: String,
    val models: List<LlmModel> = emptyList()
)

@Serializable
data class ModelConfiguration(
    val temperature: Double? = null,
    @SerialName("top_p") val topP: Double? = null,
    @SerialName("top_k") val topK: Int? = null,
    // null inherits the provider setting; false is an explicit override.
    val supportStream: Boolean? = null
)

fun LlmProviderInfo.streamEnabledFor(modelId: String): Boolean =
    config.modelConfigs[modelId]?.supportStream ?: config.supportStream
