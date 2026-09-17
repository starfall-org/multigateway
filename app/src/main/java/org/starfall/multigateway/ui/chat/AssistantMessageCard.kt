package org.starfall.multigateway.ui.chat

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.MoreHoriz
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.starfall.multigateway.data.model.MessageVersion
import org.starfall.multigateway.data.model.StoredMessage
import org.starfall.multigateway.data.model.ToolActivity

@Composable
fun AssistantMessageCard(
    message: StoredMessage,
    isStreaming: Boolean,
    onCopy: () -> Unit,
    onRegenerate: () -> Unit,
    onEdit: () -> Unit,
    onDelete: () -> Unit,
    onRead: () -> Unit,
    onSwitchVersion: (Int) -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    var showMoreMenu by remember { mutableStateOf(false) }
    val activeVersion = message.activeVersion
    val processingDurationMillis = activeVersion.processingFinishedAt?.let { finishedAt ->
        activeVersion.timestamp.toLongOrNull()?.let { startedAt -> (finishedAt - startedAt).coerceAtLeast(0L) }
    }

    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp)
    ) {
        if (isStreaming) {
            ToolActivityCards(activeVersion.toolActivity)
            if (!message.reasoningContent.isNullOrBlank()) {
                ReasoningDropdown(
                    reasoning = message.reasoningContent!!,
                    isStreaming = message.content.isBlank(),
                    modifier = Modifier.padding(bottom = 10.dp)
                )
            }

            if (message.content.isBlank() && message.reasoningContent.isNullOrBlank()) {
                Row(
                    modifier = Modifier.padding(vertical = 8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(16.dp),
                        strokeWidth = 2.dp,
                        color = MaterialTheme.colorScheme.primary
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "Thinking...",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            } else if (message.content.isNotBlank()) {
                FormattedMarkdownMessage(content = message.content)
            }
        } else {
            CompletedAssistantContent(
                version = activeVersion,
                processingDurationMillis = processingDurationMillis
            )
        }

        if (message.versions.size > 1) {
            Row(
                modifier = Modifier.padding(top = 8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(
                    onClick = {
                        if (message.activeVersionIndex > 0) {
                            onSwitchVersion(message.activeVersionIndex - 1)
                        }
                    },
                    enabled = message.activeVersionIndex > 0,
                    modifier = Modifier.size(30.dp)
                ) {
                    Icon(
                        Icons.AutoMirrored.Filled.ArrowBack,
                        contentDescription = "Previous version",
                        modifier = Modifier.size(16.dp)
                    )
                }
                Text(
                    text = "${message.activeVersionIndex + 1}/${message.versions.size}",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                IconButton(
                    onClick = {
                        if (message.activeVersionIndex < message.versions.size - 1) {
                            onSwitchVersion(message.activeVersionIndex + 1)
                        }
                    },
                    enabled = message.activeVersionIndex < message.versions.size - 1,
                    modifier = Modifier.size(30.dp)
                ) {
                    Icon(
                        Icons.AutoMirrored.Filled.ArrowForward,
                        contentDescription = "Next version",
                        modifier = Modifier.size(16.dp)
                    )
                }
            }
        }

        if (message.content.isNotBlank() || !isStreaming) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 10.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(2.dp)
            ) {
                MessageActionButton(onClick = onRegenerate, contentDescription = "Regenerate") {
                    Icon(Icons.Outlined.Refresh, contentDescription = null, modifier = Modifier.size(22.dp))
                }
                MessageActionButton(
                    onClick = {
                        val share = Intent(Intent.ACTION_SEND).apply {
                            type = "text/plain"
                            putExtra(Intent.EXTRA_TEXT, message.content)
                        }
                        context.startActivity(Intent.createChooser(share, "Share response"))
                    },
                    contentDescription = "Share"
                ) {
                    Icon(Icons.Outlined.Share, contentDescription = null, modifier = Modifier.size(22.dp))
                }
                MessageActionButton(onClick = onCopy, contentDescription = "Copy") {
                    Icon(Icons.Outlined.ContentCopy, contentDescription = null, modifier = Modifier.size(22.dp))
                }

                Box {
                    MessageActionButton(
                        onClick = { showMoreMenu = true },
                        contentDescription = "More"
                    ) {
                        Icon(Icons.Default.MoreHoriz, contentDescription = null, modifier = Modifier.size(24.dp))
                    }
                    DropdownMenu(
                        expanded = showMoreMenu,
                        onDismissRequest = { showMoreMenu = false }
                    ) {
                        DropdownMenuItem(
                            text = { Text("Edit") },
                            leadingIcon = { Icon(Icons.Outlined.Edit, contentDescription = null) },
                            onClick = {
                                showMoreMenu = false
                                onEdit()
                            }
                        )
                        DropdownMenuItem(
                            text = { Text("Delete") },
                            leadingIcon = { Icon(Icons.Outlined.Delete, contentDescription = null) },
                            onClick = {
                                showMoreMenu = false
                                onDelete()
                            }
                        )
                    }
                }

                Spacer(modifier = Modifier.weight(1f))

                MessageActionButton(onClick = onRead, contentDescription = "Read aloud") {
                    Icon(Icons.Outlined.VolumeUp, contentDescription = null, modifier = Modifier.size(24.dp))
                }
            }
        }
    }
}

private data class ProcessingBlock(
    val offset: Int,
    val reasoning: String? = null,
    val activities: List<ToolActivity> = emptyList()
)

@Composable
private fun CompletedAssistantContent(
    version: MessageVersion,
    processingDurationMillis: Long?
) {
    val blocks = remember(version.content, version.reasoningContent, version.toolActivity) {
        buildProcessingBlocks(version)
    }
    val content = version.content

    if (blocks.isEmpty()) {
        if (content.isNotBlank()) FormattedMarkdownMessage(content = content)
        return
    }

    var cursor = 0
    blocks.forEach { block ->
        val offset = block.offset.coerceIn(cursor, content.length)
        if (offset > cursor) {
            val textBefore = content.substring(cursor, offset)
            if (textBefore.isNotBlank()) {
                FormattedMarkdownMessage(content = textBefore)
                Spacer(Modifier.height(6.dp))
            }
        }

        ProcessingDropdown(
            reasoning = block.reasoning,
            activities = block.activities,
            durationMillis = processingDurationMillis.takeIf { blocks.size == 1 },
            modifier = Modifier.padding(bottom = 6.dp)
        )
        cursor = offset
    }

    if (cursor < content.length) {
        val remaining = content.substring(cursor)
        if (remaining.isNotBlank()) FormattedMarkdownMessage(content = remaining)
    }
}

private fun buildProcessingBlocks(version: MessageVersion): List<ProcessingBlock> {
    val content = version.content
    val toolsByOffset = version.toolActivity
        .filterNot { it.name.endsWith(": connect") }
        .groupBy { it.contentOffset.coerceIn(0, content.length) }
    val offsets = buildSet {
        if (!version.reasoningContent.isNullOrBlank()) add(0)
        addAll(toolsByOffset.keys)
    }.sorted()

    val merged = mutableListOf<ProcessingBlock>()
    offsets.forEach { offset ->
        val block = ProcessingBlock(
            offset = offset,
            reasoning = version.reasoningContent?.takeIf { offset == 0 && it.isNotBlank() },
            activities = toolsByOffset[offset].orEmpty()
        )
        val previous = merged.lastOrNull()
        if (previous != null && content.substring(previous.offset, offset).isBlank()) {
            merged[merged.lastIndex] = previous.copy(
                reasoning = previous.reasoning ?: block.reasoning,
                activities = previous.activities + block.activities
            )
        } else {
            merged += block
        }
    }
    return merged
}

@Composable
private fun MessageActionButton(
    onClick: () -> Unit,
    contentDescription: String,
    content: @Composable () -> Unit
) {
    IconButton(
        onClick = onClick,
        modifier = Modifier.size(40.dp),
        colors = IconButtonDefaults.iconButtonColors(
            contentColor = MaterialTheme.colorScheme.onSurfaceVariant
        )
    ) {
        Box(contentAlignment = Alignment.Center) { content() }
    }
}

@Composable
fun FormattedMarkdownMessage(content: String) {
    val context = LocalContext.current
    // Render code blocks vs text paragraphs cleanly
    val blocks = remember(content) { parseMarkdownBlocks(content) }

    Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        blocks.forEach { block ->
            when (block) {
                is ContentBlock.Code -> {
                    Surface(
                        shape = RoundedCornerShape(8.dp),
                        color = MaterialTheme.colorScheme.surfaceContainerHighest,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Column {
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .background(MaterialTheme.colorScheme.surfaceContainerHigh)
                                    .padding(horizontal = 12.dp, vertical = 6.dp),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(
                                    text = block.language.ifEmpty { "code" },
                                    style = MaterialTheme.typography.labelSmall,
                                    color = MaterialTheme.colorScheme.outline
                                )
                                IconButton(
                                    onClick = {
                                        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                                        clipboard.setPrimaryClip(ClipData.newPlainText("Code", block.code))
                                        Toast.makeText(context, "Code copied", Toast.LENGTH_SHORT).show()
                                    },
                                    modifier = Modifier.size(24.dp)
                                ) {
                                    Icon(
                                        Icons.Outlined.ContentCopy,
                                        contentDescription = "Copy code",
                                        tint = MaterialTheme.colorScheme.outline,
                                        modifier = Modifier.size(14.dp)
                                    )
                                }
                            }
                            Text(
                                text = block.code,
                                style = MaterialTheme.typography.bodySmall.copy(
                                    fontFamily = FontFamily.Monospace,
                                    fontSize = 12.sp,
                                    lineHeight = 16.sp
                                ),
                                modifier = Modifier.padding(12.dp),
                                color = MaterialTheme.colorScheme.onSurface
                            )
                        }
                    }
                }
                is ContentBlock.Paragraph -> {
                    Text(
                        text = block.text,
                        style = MaterialTheme.typography.bodyLarge.copy(lineHeight = 22.sp),
                        color = MaterialTheme.colorScheme.onSurface
                    )
                }
            }
        }
    }
}

sealed class ContentBlock {
    data class Paragraph(val text: String) : ContentBlock()
    data class Code(val language: String, val code: String) : ContentBlock()
}

fun parseMarkdownBlocks(markdown: String): List<ContentBlock> {
    val blocks = mutableListOf<ContentBlock>()
    val codeRegex = Regex("```(\\w*)\\n?([\\s\\S]*?)```")
    var lastIndex = 0

    codeRegex.findAll(markdown).forEach { match ->
        val textBefore = markdown.substring(lastIndex, match.range.first).trim()
        if (textBefore.isNotEmpty()) {
            blocks.add(ContentBlock.Paragraph(textBefore))
        }
        val language = match.groupValues[1].trim()
        val code = match.groupValues[2].trim()
        blocks.add(ContentBlock.Code(language, code))
        lastIndex = match.range.last + 1
    }

    if (lastIndex < markdown.length) {
        val remaining = markdown.substring(lastIndex).trim()
        if (remaining.isNotEmpty()) {
            blocks.add(ContentBlock.Paragraph(remaining))
        }
    }

    if (blocks.isEmpty() && markdown.isNotBlank()) {
        blocks.add(ContentBlock.Paragraph(markdown))
    }

    return blocks
}
