package org.starfall.multigateway.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

// Keep the stored config/system_prompt shape so existing profiles retain their prompts.
@Serializable
data class LlmChatConfig(
    @SerialName("system_prompt") val systemPrompt: String = ""
)

@Serializable
data class ChatProfile(
    val id: String,
    val name: String,
    val icon: String? = null,
    val config: LlmChatConfig = LlmChatConfig()
)
