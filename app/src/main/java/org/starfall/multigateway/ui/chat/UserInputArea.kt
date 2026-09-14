package org.starfall.multigateway.ui.chat

import android.widget.Toast
import androidx.compose.ui.platform.LocalContext
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.ArrowUpward
import androidx.compose.material.icons.filled.Close
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
    var showFilesSheet by remember { mutableStateOf(false) }

    val canSend = !isGenerating && textState.isNotBlank()

    Surface(
        modifier = modifier.fillMaxWidth().navigationBarsPadding().imePadding(),
        shape = RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp),
        color = MaterialTheme.colorScheme.surfaceContainerLow,
        tonalElevation = 2.dp
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(start = 12.dp, top = 8.dp, end = 12.dp, bottom = 4.dp)
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
                        .padding(horizontal = 8.dp, vertical = 2.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    TextField(
                        value = textState,
                        onValueChange = { textState = it },
                        placeholder = {
                            Text(
                                text = "Type something...",
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.6f)
                            )
                        },
                        colors = TextFieldDefaults.colors(
                            focusedContainerColor = Color.Transparent,
                            unfocusedContainerColor = Color.Transparent,
                            disabledContainerColor = Color.Transparent,
                            focusedIndicatorColor = Color.Transparent,
                            unfocusedIndicatorColor = Color.Transparent
                        ),
                        modifier = Modifier
                            .weight(1f)
                            .padding(end = 4.dp),
                        maxLines = 4
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

            Spacer(modifier = Modifier.height(4.dp))

            // Bottom Buttons Row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Left side: Add file + Quick Actions
                Row(verticalAlignment = Alignment.CenterVertically) {
                    IconButton(
                        onClick = { showFilesSheet = true },
                        modifier = Modifier.size(48.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Add,
                            contentDescription = "Attach files",
                            tint = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }

                    IconButton(
                        onClick = { showQuickActions = true },
                        modifier = Modifier.size(48.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Outlined.Extension,
                            contentDescription = "Quick Actions",
                            tint = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }

                // Right side: Outlined Model selector button
                OutlinedButton(
                    onClick = { showModelPicker = true },
                    shape = RoundedCornerShape(12.dp),
                    border = borderStroke(1.dp, MaterialTheme.colorScheme.outline.copy(alpha = 0.5f)),
                    contentPadding = PaddingValues(horizontal = 10.dp, vertical = 6.dp),
                    modifier = Modifier.weight(1f).padding(start = 8.dp).heightIn(min = 48.dp)
                ) {
                    Text(
                        text = selectedModelName,
                        modifier = Modifier.weight(1f),
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
