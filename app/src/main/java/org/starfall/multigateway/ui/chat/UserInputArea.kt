package org.starfall.multigateway.ui.chat

import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.ArrowUpward
import androidx.compose.material.icons.filled.Stop
import androidx.compose.material.icons.outlined.Extension
import androidx.compose.material.icons.outlined.InsertDriveFile
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.starfall.multigateway.data.model.LlmProviderInfo
import org.starfall.multigateway.data.model.ModelConfiguration
import org.starfall.multigateway.data.model.ProviderType

@Composable
fun UserInputArea(
    isGenerating: Boolean,
    onSendMessage: (String, List<String>) -> Boolean,
    onStopGenerating: () -> Unit,
    selectedModelName: String,
    providers: List<LlmProviderInfo>,
    selectedProviderId: String,
    onSelectModel: (providerId: String, modelId: String) -> Unit,
    onSaveModelConfig: (String, String, ModelConfiguration) -> Unit,
    onFetchOllamaModels: (suspend (String) -> List<String>)? = null,
    modifier: Modifier = Modifier
) {
    var textState by remember { mutableStateOf("") }
    val context = LocalContext.current

    var showModelPicker by remember { mutableStateOf(false) }
    var showQuickActions by remember { mutableStateOf(false) }
    var showAddMenu by remember { mutableStateOf(false) }
    var showFilesSheet by remember { mutableStateOf(false) }

    val selectedProvider = providers.find { it.id == selectedProviderId }
    val canSend = !isGenerating && textState.isNotBlank()

    Surface(
        modifier = modifier.fillMaxWidth(),
        color = MaterialTheme.colorScheme.background,
        tonalElevation = 0.dp
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .windowInsetsPadding(WindowInsets.safeDrawing.only(WindowInsetsSides.Horizontal + WindowInsetsSides.Bottom))
                .imePadding()
                .padding(horizontal = 12.dp, vertical = 8.dp)
        ) {
            Surface(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(36.dp),
                color = MaterialTheme.colorScheme.surfaceContainer,
                tonalElevation = 1.dp,
                shadowElevation = 2.dp
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(start = 6.dp, top = 6.dp, end = 6.dp, bottom = 6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box {
                        IconButton(
                            onClick = { showAddMenu = true },
                            modifier = Modifier.size(48.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.Add,
                                contentDescription = "Attachments and tools",
                                tint = MaterialTheme.colorScheme.onSurface,
                                modifier = Modifier.size(30.dp)
                            )
                        }
                        DropdownMenu(
                            expanded = showAddMenu,
                            onDismissRequest = { showAddMenu = false }
                        ) {
                            DropdownMenuItem(
                                text = { Text("Attach files") },
                                leadingIcon = { Icon(Icons.Outlined.InsertDriveFile, contentDescription = null) },
                                onClick = {
                                    showAddMenu = false
                                    showFilesSheet = true
                                }
                            )
                            DropdownMenuItem(
                                text = { Text("MCP & tools") },
                                leadingIcon = { Icon(Icons.Outlined.Extension, contentDescription = null) },
                                onClick = {
                                    showAddMenu = false
                                    showQuickActions = true
                                }
                            )
                        }
                    }

                    BasicTextField(
                        value = textState,
                        onValueChange = { textState = it },
                        textStyle = MaterialTheme.typography.bodyLarge.copy(
                            color = MaterialTheme.colorScheme.onSurface,
                            fontSize = 18.sp
                        ),
                        cursorBrush = SolidColor(MaterialTheme.colorScheme.primary),
                        modifier = Modifier
                            .weight(1f)
                            .padding(horizontal = 8.dp, vertical = 10.dp),
                        maxLines = 4,
                        decorationBox = { innerTextField ->
                            Box(contentAlignment = Alignment.CenterStart) {
                                if (textState.isEmpty()) {
                                    Text(
                                        text = "...",
                                        style = MaterialTheme.typography.bodyLarge.copy(fontSize = 20.sp),
                                        color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.55f)
                                    )
                                }
                                innerTextField()
                            }
                        }
                    )

                    Box(
                        modifier = Modifier
                            .padding(end = 6.dp)
                            .size(44.dp)
                            .clip(CircleShape)
                            .background(MaterialTheme.colorScheme.surfaceContainerHighest)
                            .clickable { showModelPicker = true },
                        contentAlignment = Alignment.Center
                    ) {
                        ModelLogo(
                            provider = selectedProvider,
                            modelName = selectedModelName
                        )
                    }

                    Box(
                        modifier = Modifier
                            .size(48.dp)
                            .clip(CircleShape)
                            .background(
                                when {
                                    isGenerating -> MaterialTheme.colorScheme.errorContainer
                                    canSend -> MaterialTheme.colorScheme.primaryContainer
                                    else -> MaterialTheme.colorScheme.surfaceContainerHighest
                                }
                            )
                            .clickable(
                                enabled = isGenerating || canSend,
                                onClick = {
                                    if (isGenerating) {
                                        onStopGenerating()
                                    } else if (canSend) {
                                        if (onSendMessage(textState, emptyList())) {
                                            textState = ""
                                        } else {
                                            Toast.makeText(
                                                context,
                                                "Select an available provider and model, or wait for the current response.",
                                                Toast.LENGTH_SHORT
                                            ).show()
                                        }
                                    }
                                }
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        if (isGenerating) {
                            Icon(
                                imageVector = Icons.Default.Stop,
                                contentDescription = "Stop generation",
                                tint = MaterialTheme.colorScheme.onErrorContainer,
                                modifier = Modifier.size(20.dp)
                            )
                        } else {
                            Icon(
                                imageVector = Icons.Default.ArrowUpward,
                                contentDescription = "Send message",
                                tint = if (canSend) {
                                    MaterialTheme.colorScheme.onPrimaryContainer
                                } else {
                                    MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.42f)
                                },
                                modifier = Modifier.size(24.dp)
                            )
                        }
                    }
                }
            }
        }
    }

    if (showModelPicker) {
        ModelPickerSheet(
            providers = providers,
            selectedProviderId = selectedProviderId,
            selectedModelId = selectedModelName,
            onSelectModel = onSelectModel,
            onFetchOllamaModels = onFetchOllamaModels,
            onDismiss = { showModelPicker = false }
        )
    }

    if (showQuickActions) {
        QuickActionsSheet(onDismiss = { showQuickActions = false })
    }

    if (showFilesSheet) {
        AlertDialog(
            onDismissRequest = { showFilesSheet = false },
            title = { Text("Attachments unavailable") },
            text = { Text("Sending images and documents is not supported yet. Please paste text into your message.") },
            confirmButton = {
                TextButton(onClick = { showFilesSheet = false }) { Text("OK") }
            }
        )
    }
}

@Composable
private fun ModelLogo(
    provider: LlmProviderInfo?,
    modelName: String
) {
    val mark = when (provider?.type) {
        ProviderType.OPENAI, ProviderType.OPENAI_RESPONSES -> if (modelName.startsWith("o", ignoreCase = true)) "◉" else "◎"
        ProviderType.GOOGLE -> "✦"
        ProviderType.ANTHROPIC -> "A"
        ProviderType.OLLAMA -> "◌"
        null -> "AI"
    }
    Text(
        text = mark,
        color = MaterialTheme.colorScheme.onSurface,
        style = MaterialTheme.typography.titleMedium.copy(
            fontWeight = FontWeight.SemiBold,
            fontSize = if (mark.length > 1) 11.sp else 22.sp
        ),
        maxLines = 1
    )
}
