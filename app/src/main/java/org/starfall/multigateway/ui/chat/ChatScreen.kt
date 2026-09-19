package org.starfall.multigateway.ui.chat

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.widget.Toast
import androidx.compose.foundation.layout.*
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.input.nestedscroll.NestedScrollConnection
import androidx.compose.ui.input.nestedscroll.NestedScrollSource
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import org.starfall.multigateway.data.model.ChatProfile
import org.starfall.multigateway.data.model.ChatRole
import org.starfall.multigateway.data.model.Conversation
import org.starfall.multigateway.data.model.LlmProviderInfo
import org.starfall.multigateway.data.model.StoredMessage

@Composable
fun ChatScreen(
    conversation: Conversation?,
    selectedProfile: ChatProfile?,
    isGenerating: Boolean,
    generatingConversationId: String?,
    chatError: String?,
    providers: List<LlmProviderInfo>,
    selectedProviderId: String,
    selectedModelName: String,
    onSendMessage: (String, List<String>) -> Boolean,
    onStopGenerating: () -> Unit,
    onOpenDrawer: () -> Unit,
    onOpenEndDrawer: () -> Unit,
    onRegenerate: (String) -> Unit,
    onEditMessage: (messageId: String, newContent: String) -> Unit,
    onDeleteMessage: (messageId: String) -> Unit,
    onDeleteMessageVersion: (messageId: String) -> Unit,
    onSwitchVersion: (messageId: String, versionIndex: Int) -> Unit,
    onSelectModel: (providerId: String, modelId: String) -> Unit,
    onReadMessage: (String) -> Unit,
    onFetchOllamaModels: (suspend (String) -> List<String>)? = null,
    modifier: Modifier = Modifier
) {
    val listState = key(conversation?.id) { rememberLazyListState() }
    var followBottom by remember(conversation?.id) { mutableStateOf(true) }
    val context = LocalContext.current

    val messages = conversation?.messages ?: emptyList()

    // Dialog state for editing a message
    var editingMessage by remember(conversation?.id) { mutableStateOf<StoredMessage?>(null) }
    var editContentText by remember { mutableStateOf("") }

    // Dialog state for deleting a message
    var deletingMessageId by remember(conversation?.id) { mutableStateOf<String?>(null) }

    var regeneratingMessageId by remember(conversation?.id) { mutableStateOf<String?>(null) }
    val streamingHere = isGenerating && generatingConversationId == conversation?.id
    val lastMessage = messages.lastOrNull()
    val autoScrollTick = if (streamingHere) {
        ((lastMessage?.content?.length ?: 0) + (lastMessage?.reasoningContent?.length ?: 0)) / 48
    } else {
        lastMessage?.activeVersionIndex
    }
    fun whenIdle(action: () -> Unit) {
        if (isGenerating) Toast.makeText(context, "Stop the current response before editing messages.", Toast.LENGTH_SHORT).show()
        else action()
    }
    val scrollConnection = remember(listState) {
        object : NestedScrollConnection {
            override fun onPreScroll(available: Offset, source: NestedScrollSource): Offset {
                if (source == NestedScrollSource.Drag && available.y > 0f) followBottom = false
                return Offset.Zero
            }
            override fun onPostScroll(consumed: Offset, available: Offset, source: NestedScrollSource): Offset {
                if (source == NestedScrollSource.Drag && !listState.canScrollForward) followBottom = true
                return Offset.Zero
            }
        }
    }
    LaunchedEffect(conversation?.id, messages.size, autoScrollTick, followBottom, streamingHere) {
        if (followBottom && messages.isNotEmpty()) {
            listState.scrollToItem(messages.lastIndex)
            val height = listState.layoutInfo.visibleItemsInfo.lastOrNull()?.size ?: 0
            if (height > 0) listState.scrollToItem(messages.lastIndex, height)
        }
    }
    LaunchedEffect(chatError) {
        chatError?.let { Toast.makeText(context, it, Toast.LENGTH_LONG).show() }
    }

    val topBarClearance = WindowInsets.statusBars.asPaddingValues().calculateTopPadding() + 80.dp

    Box(modifier = modifier.fillMaxSize()) {
        if (messages.isEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(top = topBarClearance, bottom = 88.dp),
                contentAlignment = Alignment.Center
            ) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.padding(24.dp)
                ) {
                    Text(
                        text = "MultiGateway",
                        style = MaterialTheme.typography.headlineMedium,
                        color = MaterialTheme.colorScheme.primary
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = selectedProfile?.config?.systemPrompt?.take(90)?.plus("...")
                            ?: "Connect to multiple LLM providers and agents seamlessly.",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.outline,
                        textAlign = androidx.compose.ui.text.style.TextAlign.Center
                    )
                }
            }

            if (isGenerating && !streamingHere) {
                Text(
                    "A response is running in another conversation. Use Stop to cancel it.",
                    modifier = Modifier
                        .align(Alignment.TopCenter)
                        .padding(top = topBarClearance, start = 12.dp, end = 12.dp),
                    style = MaterialTheme.typography.bodySmall
                )
            }
        } else {
            LazyColumn(
                state = listState,
                modifier = Modifier
                    .fillMaxSize()
                    .nestedScroll(scrollConnection),
                contentPadding = PaddingValues(top = topBarClearance, bottom = 104.dp)
            ) {
                if (isGenerating && !streamingHere) {
                    item(key = "generation-warning") {
                        Text(
                            "A response is running in another conversation. Use Stop to cancel it.",
                            modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
                            style = MaterialTheme.typography.bodySmall
                        )
                    }
                }

                items(messages, key = { it.id }) { msg ->
                    val isLast = msg.id == messages.lastOrNull()?.id

                    if (msg.role == ChatRole.USER) {
                        UserMessageCard(
                            message = msg,
                            onEdit = {
                                whenIdle {
                                    editingMessage = msg
                                    editContentText = msg.content
                                }
                            },
                            onDelete = {
                                whenIdle { deletingMessageId = msg.id }
                            },
                            onSwitchVersion = { newIdx ->
                                whenIdle { onSwitchVersion(msg.id, newIdx) }
                            }
                        )
                    } else {
                        AssistantMessageCard(
                            message = msg,
                            isStreaming = streamingHere && isLast,
                            onCopy = {
                                val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                                clipboard.setPrimaryClip(ClipData.newPlainText("Copied", msg.content))
                                Toast.makeText(context, "Copied to clipboard", Toast.LENGTH_SHORT).show()
                            },
                            onRegenerate = {
                                whenIdle {
                                    if (!isLast) regeneratingMessageId = msg.id
                                    else onRegenerate(msg.id)
                                }
                            },
                            onEdit = {
                                whenIdle {
                                    editingMessage = msg
                                    editContentText = msg.content
                                }
                            },
                            onDelete = {
                                whenIdle { deletingMessageId = msg.id }
                            },
                            onRead = {
                                onReadMessage(msg.content)
                            },
                            onSwitchVersion = { newIdx ->
                                whenIdle { onSwitchVersion(msg.id, newIdx) }
                            }
                        )
                    }
                }

                item(key = "chat-bottom-spacer") {
                    Spacer(modifier = Modifier.height(96.dp))
                }
            }
        }

        Column(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
        ) {
            if (messages.isNotEmpty() && !followBottom) {
                TextButton(
                    onClick = { followBottom = true },
                    modifier = Modifier
                        .align(Alignment.End)
                        .padding(end = 12.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.KeyboardArrowDown,
                        contentDescription = null,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text("Jump to latest")
                }
            }
            UserInputArea(
                isGenerating = isGenerating,
                onSendMessage = { text, files ->
                    onSendMessage(text, files).also { if (it) followBottom = true }
                },
                onStopGenerating = onStopGenerating,
                selectedModelName = selectedModelName,
                providers = providers,
                selectedProviderId = selectedProviderId,
                onSelectModel = onSelectModel,
                onFetchOllamaModels = onFetchOllamaModels
            )
        }

        ChatAppBar(
            currentSession = conversation,
            selectedProfile = selectedProfile,
            onOpenDrawer = onOpenDrawer,
            onOpenEndDrawer = onOpenEndDrawer,
            modifier = Modifier.align(Alignment.TopCenter)
        )
    }

    if (regeneratingMessageId != null) {
        AlertDialog(
            onDismissRequest = { regeneratingMessageId = null },
            title = { Text("Regenerate this response?") },
            text = { Text("Later messages will be removed. The current response will remain available as an earlier version.") },
            confirmButton = { TextButton(onClick = {
                regeneratingMessageId?.let(onRegenerate)
                regeneratingMessageId = null
            }) { Text("Regenerate") } },
            dismissButton = { TextButton(onClick = { regeneratingMessageId = null }) { Text("Cancel") } }
        )
    }

    // Edit message dialog
    if (editingMessage != null) {
        AlertDialog(
            onDismissRequest = { editingMessage = null },
            title = { Text("Edit Message") },
            text = {
                OutlinedTextField(
                    value = editContentText,
                    onValueChange = { editContentText = it },
                    modifier = Modifier.fillMaxWidth().heightIn(min = 120.dp, max = 240.dp),
                    label = { Text("Message Content") }
                )
            },
            confirmButton = {
                Button(
                    onClick = {
                        val id = editingMessage?.id
                        if (id != null && editContentText.isNotBlank()) {
                            onEditMessage(id, editContentText)
                        }
                        editingMessage = null
                    }
                ) {
                    Text("Save")
                }
            },
            dismissButton = {
                TextButton(onClick = { editingMessage = null }) {
                    Text("Cancel")
                }
            }
        )
    }

    // Delete message/version confirmation dialog
    val deletingMessage = deletingMessageId?.let { id -> messages.firstOrNull { it.id == id } }
    if (deletingMessage != null) {
        val hasMultipleVersions = deletingMessage.versions.size > 1
        AlertDialog(
            onDismissRequest = { deletingMessageId = null },
            title = { Text(if (hasMultipleVersions) "Delete Message Version" else "Delete Message") },
            text = {
                Text(
                    if (hasMultipleVersions) {
                        "This message has ${deletingMessage.versions.size} versions. Delete only the current version or delete the entire message with all versions?"
                    } else {
                        "Are you sure you want to delete this message?"
                    }
                )
            },
            confirmButton = {
                if (hasMultipleVersions) {
                    Column(horizontalAlignment = Alignment.End) {
                        TextButton(
                            onClick = {
                                onDeleteMessageVersion(deletingMessage.id)
                                deletingMessageId = null
                            },
                            colors = ButtonDefaults.textButtonColors(contentColor = MaterialTheme.colorScheme.error)
                        ) {
                            Text("Delete current version")
                        }
                        TextButton(
                            onClick = {
                                onDeleteMessage(deletingMessage.id)
                                deletingMessageId = null
                            },
                            colors = ButtonDefaults.textButtonColors(contentColor = MaterialTheme.colorScheme.error)
                        ) {
                            Text("Delete all versions")
                        }
                    }
                } else {
                    Button(
                        onClick = {
                            onDeleteMessage(deletingMessage.id)
                            deletingMessageId = null
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.error)
                    ) {
                        Text("Delete")
                    }
                }
            },
            dismissButton = {
                TextButton(onClick = { deletingMessageId = null }) {
                    Text("Cancel")
                }
            }
        )
    }
}