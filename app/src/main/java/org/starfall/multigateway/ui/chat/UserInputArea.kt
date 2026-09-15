package org.starfall.multigateway.ui.chat

import android.widget.Toast
import androidx.compose.ui.platform.LocalContext
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.ArrowUpward
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.Stop
import androidx.compose.material.icons.outlined.Extension
import androidx.compose.material.icons.outlined.InsertDriveFile
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.starfall.multigateway.data.model.ModelConfiguration
import org.starfall.multigateway.data.model.LlmProviderInfo

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

    val canSend = !isGenerating && textState.isNotBlank()

    Surface(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp),
        color = MaterialTheme.colorScheme.background,
        tonalElevation = 0.dp
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .windowInsetsPadding(WindowInsets.safeDrawing.only(WindowInsetsSides.Horizontal + WindowInsetsSides.Bottom))
                .imePadding()
                .padding(start = 12.dp, top = 4.dp, end = 12.dp, bottom = 4.dp)
        ) {
            // Text Input Box with embedded Suffix Button
            Surface(
                shape = RoundedCornerShape(24.dp),
                color = MaterialTheme.colorScheme.surfaceContainer,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    BasicTextField(
                        value = textState,
                        onValueChange = { textState = it },
                        textStyle = MaterialTheme.typography.bodyMedium.copy(
                            color = MaterialTheme.colorScheme.onSurface
                        ),
                        cursorBrush = SolidColor(MaterialTheme.colorScheme.primary),
                        modifier = Modifier
                            .weight(1f)
                            .padding(start = 8.dp, end = 4.dp, top = 8.dp, bottom = 8.dp),
                        maxLines = 4,
                        decorationBox = { innerTextField ->
                            Box {
                                if (textState.isEmpty()) {
                                    Text(
                                        text = "Type something...",
                                        style = MaterialTheme.typography.bodyMedium,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.6f)
                                    )
                                }
                                innerTextField()
                            }
                        }
                    )

                    // Embedded action button (Stop or Send)
                    Box(
                        modifier = Modifier
                            .size(48.dp)
                            .clip(CircleShape)
                            .background(
                                when {
                                    isGenerating -> MaterialTheme.colorScheme.errorContainer
                                    canSend -> MaterialTheme.colorScheme.primary
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
                                            Toast.makeText(context, "Select an available provider and model, or wait for the current response.", Toast.LENGTH_SHORT).show()
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
                                modifier = Modifier.size(18.dp)
                            )
                        } else {
                            Icon(
                                imageVector = Icons.Default.ArrowUpward,
                                contentDescription = "Send message",
                                tint = if (canSend) MaterialTheme.colorScheme.onPrimary else MaterialTheme.colorScheme.outline.copy(alpha = 0.5f),
                                modifier = Modifier.size(18.dp)
                            )
                        }
                    }
                }
            }

            // Bottom Buttons Row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Attachments and tools share the add menu.
                Box {
                    IconButton(
                        onClick = { showAddMenu = true },
                        modifier = Modifier.size(48.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Add,
                            contentDescription = "Attachments and tools",
                            tint = MaterialTheme.colorScheme.onSurfaceVariant
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

                // Compact model selector, bounded by the space left beside the add button.
                OutlinedButton(
                    onClick = { showModelPicker = true },
                    shape = RoundedCornerShape(50),
                    border = borderStroke(1.dp, MaterialTheme.colorScheme.outline.copy(alpha = 0.3f)),
                    contentPadding = PaddingValues(horizontal = 10.dp, vertical = 4.dp),
                    modifier = Modifier.weight(1f, fill = false).widthIn(max = 220.dp).padding(start = 8.dp)
                ) {
                    Text(
                        text = providers.find { it.id == selectedProviderId }?.config?.modelConfigs
                            ?.get(selectedModelName)?.displayName?.ifBlank { selectedModelName } ?: selectedModelName,
                        modifier = Modifier.weight(1f, fill = false),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        style = MaterialTheme.typography.labelMedium.copy(fontSize = 12.sp),
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Icon(
                        imageVector = Icons.Default.KeyboardArrowDown,
                        contentDescription = "Select Model",
                        tint = MaterialTheme.colorScheme.outline,
                        modifier = Modifier.size(16.dp)
                    )
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
            onSaveModelConfig = onSaveModelConfig,
            onFetchOllamaModels = onFetchOllamaModels,
            onDismiss = { showModelPicker = false }
        )
    }

    if (showQuickActions) {
        QuickActionsSheet(
            onDismiss = { showQuickActions = false }
        )
    }

    if (showFilesSheet) {
        AlertDialog(
            onDismissRequest = { showFilesSheet = false },
            title = { Text("Attachments unavailable") },
            text = { Text("Sending images and documents is not supported yet. Please paste text into your message.") },
            confirmButton = { TextButton(onClick = { showFilesSheet = false }) { Text("OK") } }
        )
    }
}

private fun borderStroke(width: androidx.compose.ui.unit.Dp, color: Color) =
    androidx.compose.foundation.BorderStroke(width, color)
