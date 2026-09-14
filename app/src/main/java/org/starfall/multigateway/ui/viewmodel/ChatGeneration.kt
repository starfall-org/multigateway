package org.starfall.multigateway.ui.viewmodel

import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import org.starfall.multigateway.data.model.*

/** A single generation owns its conversation snapshot, independently of navigation. */
internal class ChatGeneration(
    private val scope: CoroutineScope,
    private val save: suspend (Conversation) -> Unit,
    private val publish: (Conversation) -> Unit
) {
    private val _busy = MutableStateFlow(false)
    val busy = _busy.asStateFlow()
    private val _error = MutableStateFlow<String?>(null)
    val error = _error.asStateFlow()
    private val _conversationId = MutableStateFlow<String?>(null)
    val conversationId = _conversationId.asStateFlow()
    var snapshot: Conversation? = null
        private set
    private var job: Job? = null

    fun start(conversation: Conversation, messageId: String, chunks: Flow<String>): Boolean =
        startEvents(conversation, messageId, chunks.map { GenerationEvent.Text(it) })

    fun startEvents(conversation: Conversation, messageId: String, chunks: Flow<GenerationEvent>): Boolean {
        if (_busy.value) return false
        _busy.value = true
        _error.value = null
        _conversationId.value = conversation.id
        snapshot = conversation
        publish(conversation)
        job = scope.launch(start = CoroutineStart.LAZY) {
            var output = ""
            fun update() {
                snapshot = updateResponse(snapshot!!, messageId, output)
                publish(snapshot!!)
            }
            try {
                save(snapshot!!)
                chunks.collect { chunk ->
                    when (chunk) {
                        is GenerationEvent.Text -> { output += chunk.text; update() }
                        is GenerationEvent.Tool -> {
                            snapshot = snapshot!!.copy(messages = snapshot!!.messages.map { message ->
                                if (message.id != messageId) message else message.copy(versions = message.versions.mapIndexed { index, version ->
                                    if (index != message.activeVersionIndex) version else version.copy(
                                        toolActivity = version.toolActivity.filterNot { it.id == chunk.activity.id } + chunk.activity
                                    )
                                })
                            })
                            publish(snapshot!!)
                            save(snapshot!!)
                        }
                    }
                }
            } catch (e: CancellationException) {
                throw e
            } catch (e: Exception) {
                _error.value = e.localizedMessage ?: "Generation failed"
                output += "\n[Error: ${_error.value}]"
                update()
            } finally {
                try {
                    // A stopped stream must retain its partial response before allowing another send.
                    withContext(NonCancellable) {
                        snapshot = snapshot!!.copy(messages = snapshot!!.messages.map { message ->
                            if (message.id != messageId) message else message.copy(versions = message.versions.mapIndexed { index, version ->
                                if (index != message.activeVersionIndex) version else version.copy(toolActivity = version.toolActivity.map {
                                    if (it.status == "running") it.copy(status = "cancelled", summary = "Stopped") else it
                                })
                            })
                        })
                        publish(snapshot!!)
                        save(snapshot!!)
                    }
                } catch (e: Exception) {
                    _error.value = "Could not save conversation: ${e.localizedMessage}"
                } finally {
                    snapshot = null
                    _conversationId.value = null
                    _busy.value = false
                }
            }
        }
        job!!.start()
        return true
    }

    fun stop() { job?.cancel() }
    suspend fun stopAndJoin() { job?.cancelAndJoin() }
}

internal fun updateResponse(conversation: Conversation, messageId: String, output: String): Conversation {
    val thinking = output.startsWith("<think>")
    val end = output.indexOf("</think>")
    val reasoning = if (thinking) output.substring(7, if (end >= 0) end else output.length).trim() else null
    val content = if (thinking) { if (end >= 0) output.substring(end + 8).trimStart() else "" } else output
    return conversation.copy(
        updatedAt = System.currentTimeMillis(),
        messages = conversation.messages.map { message ->
            if (message.id != messageId) message else message.copy(
                versions = message.versions.mapIndexed { index, version ->
                    if (index == message.activeVersionIndex) version.copy(content = content, reasoningContent = reasoning) else version
                }
            )
        }
    )
}

/** Regeneration keeps earlier versions and uses only the context before the selected answer. */
internal fun prepareRegeneration(conversation: Conversation, messageId: String): Conversation? {
    val index = conversation.messages.indexOfFirst { it.id == messageId && it.role == ChatRole.MODEL }
    if (index < 1 || conversation.messages.take(index).none { it.role == ChatRole.USER }) return null
    val message = conversation.messages[index]
    return conversation.copy(messages = conversation.messages.take(index) + message.copy(
        versions = message.versions + MessageVersion(timestamp = System.currentTimeMillis().toString()),
        activeVersionIndex = message.versions.size
    ))
}
