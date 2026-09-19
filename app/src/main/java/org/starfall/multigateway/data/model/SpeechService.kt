package org.starfall.multigateway.data.model

import kotlinx.serialization.Serializable

@Serializable
data class SpeechService(
    val id: String,
    val name: String,
    val provider: String = "system", // "system" or LlmProviderInfo.id
    val modelId: String? = null,
    val voice: String = "Default",
    val speed: Float = 1.0f,
    val pitch: Float = 1.0f,
    val apiKey: String = "",
    val sortOrder: Int = Int.MAX_VALUE
)
