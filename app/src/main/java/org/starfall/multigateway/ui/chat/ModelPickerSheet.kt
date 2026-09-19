package org.starfall.multigateway.ui.chat

import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.outlined.Build
import androidx.compose.material.icons.outlined.Image
import androidx.compose.material.icons.outlined.Videocam
import androidx.compose.material.icons.outlined.Audiotrack
import androidx.compose.material.icons.outlined.Psychology
import androidx.compose.material.icons.outlined.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.starfall.multigateway.data.model.LlmProviderInfo
import org.starfall.multigateway.data.model.ModelConfiguration
import org.starfall.multigateway.data.model.ModelType
import org.starfall.multigateway.data.model.ProviderType

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ModelPickerSheet(
    providers: List<LlmProviderInfo>,
    selectedProviderId: String,
    selectedModelId: String,
    onSelectModel: (providerId: String, modelId: String) -> Unit,
    onFetchOllamaModels: (suspend (String) -> List<String>)? = null,
    onDismiss: () -> Unit
) {
    val dynamicModelsMap = remember { mutableStateMapOf<String, List<String>>() }
    var query by remember { mutableStateOf("") }
    var providerFilterId by remember { mutableStateOf<String?>(null) }

    LaunchedEffect(providers) {
        providers
            .filter { it.type == ProviderType.OLLAMA && it.config.modelIds == null }
            .forEach { provider ->
                val remoteModels = onFetchOllamaModels?.invoke(provider.baseUrl).orEmpty()
                if (remoteModels.isNotEmpty()) dynamicModelsMap[provider.id] = remoteModels
            }
    }

    val visibleProviders = providers.mapNotNull { provider ->
        if (providerFilterId != null && provider.id != providerFilterId) return@mapNotNull null
        val models = providerModels(provider, dynamicModelsMap, selectedProviderId, selectedModelId)
            .filter { modelId ->
                query.isBlank() ||
                        modelId.contains(query, ignoreCase = true) ||
                        provider.config.modelConfigs[modelId]?.displayName.orEmpty()
                            .contains(query, ignoreCase = true) ||
                        provider.name.contains(query, ignoreCase = true)
            }
        if (models.isEmpty()) null else provider to models
    }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        shape = RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.88f)
                .imePadding()
        ) {
            OutlinedTextField(
                value = query,
                onValueChange = { query = it },
                leadingIcon = { Icon(Icons.Outlined.Search, contentDescription = null) },
                placeholder = { Text("Enter model name to search") },
                singleLine = true,
                shape = RoundedCornerShape(28.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 8.dp)
            )

            LazyColumn(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f),
                contentPadding = PaddingValues(start = 20.dp, top = 10.dp, end = 20.dp, bottom = 18.dp),
                verticalArrangement = Arrangement.spacedBy(18.dp)
            ) {
                if (visibleProviders.isEmpty()) {
                    item(key = "empty") {
                        Box(
                            modifier = Modifier.fillParentMaxSize(),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "No matching models",
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                style = MaterialTheme.typography.bodyLarge
                            )
                        }
                    }
                }

                items(visibleProviders, key = { it.first.id }) { (provider, models) ->
                    Column(
                        modifier = Modifier.fillMaxWidth(),
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        Text(
                            text = provider.name,
                            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            modifier = Modifier.padding(horizontal = 2.dp)
                        )

                        models.forEach { modelId ->
                            val config = provider.config.modelConfigs[modelId] ?: ModelConfiguration()
                            val isSelected = provider.id == selectedProviderId && modelId == selectedModelId
                            ModelPickerCard(
                                modelId = modelId,
                                config = config,
                                isSelected = isSelected,
                                onClick = {
                                    onSelectModel(provider.id, modelId)
                                    onDismiss()
                                }
                            )
                        }
                    }
                }
            }

            HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.5f))
            LazyRow(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 10.dp),
                contentPadding = PaddingValues(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                item(key = "all-providers") {
                    FilterChip(
                        selected = providerFilterId == null,
                        onClick = { providerFilterId = null },
                        label = { Text("All") }
                    )
                }
                items(providers, key = { it.id }) { provider ->
                    FilterChip(
                        selected = providerFilterId == provider.id,
                        onClick = { providerFilterId = provider.id },
                        leadingIcon = {
                            ProviderMark(
                                provider = provider,
                                modelId = provider.config.modelIds?.firstOrNull().orEmpty(),
                                compact = true
                            )
                        },
                        label = {
                            Text(
                                text = provider.name,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                        }
                    )
                }
            }
        }
    }
}

@Composable
private fun ModelPickerCard(
    modelId: String,
    config: ModelConfiguration,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(20.dp),
        color = if (isSelected) {
            MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.34f)
        } else {
            MaterialTheme.colorScheme.surfaceContainerLow
        },
        border = if (isSelected) {
            androidx.compose.foundation.BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.45f))
        } else null
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 14.dp, vertical = 14.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Surface(
                shape = RoundedCornerShape(14.dp),
                color = MaterialTheme.colorScheme.surfaceContainerHighest,
                modifier = Modifier.size(52.dp)
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Text(
                        text = modelInitial(modelId),
                        style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.Bold),
                        color = MaterialTheme.colorScheme.onSurface
                    )
                }
            }

            Spacer(Modifier.width(14.dp))

            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Text(
                    text = config.displayName.ifBlank { modelId },
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
                ModelCapabilityBadges(config)
            }

            if (isSelected) {
                Spacer(Modifier.width(10.dp))
                Icon(
                    imageVector = Icons.Default.Check,
                    contentDescription = "Selected",
                    tint = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.size(22.dp)
                )
            }
        }
    }
}

@Composable
private fun ModelCapabilityBadges(config: ModelConfiguration) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .horizontalScroll(rememberScrollState()),
        horizontalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        ModelBadge(
            label = when (config.modelType) {
                ModelType.TEXT_GENERATION -> "Chat"
                else -> config.modelType.displayName
            },
            colors = AssistChipDefaults.assistChipColors(
                containerColor = MaterialTheme.colorScheme.primaryContainer,
                labelColor = MaterialTheme.colorScheme.onPrimaryContainer,
                leadingIconContentColor = MaterialTheme.colorScheme.onPrimaryContainer
            )
        )
        if (config.supportsVision) {
            ModelBadge(
                label = "Image",
                icon = Icons.Outlined.Image,
                colors = AssistChipDefaults.assistChipColors(
                    containerColor = MaterialTheme.colorScheme.tertiaryContainer,
                    labelColor = MaterialTheme.colorScheme.onTertiaryContainer,
                    leadingIconContentColor = MaterialTheme.colorScheme.onTertiaryContainer
                )
            )
        }
        if (config.supportsVideoInput) {
            ModelBadge(
                label = "Video",
                icon = Icons.Outlined.Videocam,
                colors = AssistChipDefaults.assistChipColors(
                    containerColor = MaterialTheme.colorScheme.tertiaryContainer,
                    labelColor = MaterialTheme.colorScheme.onTertiaryContainer,
                    leadingIconContentColor = MaterialTheme.colorScheme.onTertiaryContainer
                )
            )
        }
        if (config.supportsAudioInput) {
            ModelBadge(
                label = "Audio",
                icon = Icons.Outlined.Audiotrack,
                colors = AssistChipDefaults.assistChipColors(
                    containerColor = MaterialTheme.colorScheme.tertiaryContainer,
                    labelColor = MaterialTheme.colorScheme.onTertiaryContainer,
                    leadingIconContentColor = MaterialTheme.colorScheme.onTertiaryContainer
                )
            )
        }
        if (config.supportsThinking) {
            ModelBadge(
                label = "Thinking",
                icon = Icons.Outlined.Psychology,
                colors = AssistChipDefaults.assistChipColors(
                    containerColor = MaterialTheme.colorScheme.secondaryContainer,
                    labelColor = MaterialTheme.colorScheme.onSecondaryContainer,
                    leadingIconContentColor = MaterialTheme.colorScheme.onSecondaryContainer
                )
            )
        }
        if (config.supportsToolCalls) {
            ModelBadge(
                label = "Tools",
                icon = Icons.Outlined.Build,
                colors = AssistChipDefaults.assistChipColors(
                    containerColor = MaterialTheme.colorScheme.surfaceContainerHighest,
                    labelColor = MaterialTheme.colorScheme.onSurfaceVariant,
                    leadingIconContentColor = MaterialTheme.colorScheme.onSurfaceVariant
                )
            )
        }
    }
}

@Composable
private fun ModelBadge(
    label: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector? = null,
    colors: ChipColors
) {
    AssistChip(
        onClick = {},
        enabled = false,
        label = { Text(label, fontSize = 11.sp) },
        leadingIcon = icon?.let { imageVector ->
            { Icon(imageVector, contentDescription = null, modifier = Modifier.size(14.dp)) }
        },
        colors = colors,
        border = null,
        modifier = Modifier.height(28.dp)
    )
}

@Composable
private fun ProviderMark(
    provider: LlmProviderInfo,
    modelId: String,
    compact: Boolean = false
) {
    val mark = when (provider.type) {
        ProviderType.OPENAI, ProviderType.OPENAI_RESPONSES -> if (modelId.startsWith(
                "o",
                ignoreCase = true
            )
        ) "◉" else "◎"

        ProviderType.GOOGLE -> "✦"
        ProviderType.ANTHROPIC -> "A"
        ProviderType.OLLAMA -> "◌"
    }
    Text(
        text = mark,
        color = MaterialTheme.colorScheme.onSurface,
        style = MaterialTheme.typography.titleMedium.copy(
            fontWeight = FontWeight.SemiBold,
            fontSize = if (compact) 14.sp else 24.sp
        ),
        maxLines = 1
    )
}

private fun providerModels(
    provider: LlmProviderInfo,
    dynamicModelsMap: Map<String, List<String>>,
    selectedProviderId: String,
    selectedModelId: String
): List<String> = (
        provider.config.modelIds
            ?: ((dynamicModelsMap[provider.id]
                ?: defaultProviderModels(provider.type)) + provider.config.modelConfigs.keys)
        )
    .plus(if (provider.id == selectedProviderId && selectedModelId.isNotBlank()) listOf(selectedModelId) else emptyList())
    .distinct()

internal fun modelInitial(modelName: String): String {
    val source = if ('/' in modelName) modelName.substringAfterLast('/') else modelName
    return source.trim().firstOrNull()?.uppercaseChar()?.toString()
        ?: modelName.trim().firstOrNull()?.uppercaseChar()?.toString()
        ?: "?"
}

internal fun defaultProviderModels(type: ProviderType): List<String> = when (type) {
    ProviderType.OPENAI, ProviderType.OPENAI_RESPONSES -> emptyList()
    ProviderType.GOOGLE -> emptyList()
    ProviderType.ANTHROPIC -> emptyList()
    ProviderType.OLLAMA -> emptyList()
}
