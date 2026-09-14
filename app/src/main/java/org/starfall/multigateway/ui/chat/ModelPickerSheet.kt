package org.starfall.multigateway.ui.chat

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.outlined.Tune
import androidx.compose.material.icons.outlined.Add
import androidx.compose.material.icons.outlined.SmartToy
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.starfall.multigateway.data.model.ModelConfiguration
import org.starfall.multigateway.data.model.LlmProviderInfo
import org.starfall.multigateway.data.model.ProviderType

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ModelPickerSheet(
    providers: List<LlmProviderInfo>,
    selectedProviderId: String,
    selectedModelId: String,
    onSelectModel: (providerId: String, modelId: String) -> Unit,
    onSaveModelConfig: (String, String, ModelConfiguration) -> Unit,
    onFetchOllamaModels: (suspend (String) -> List<String>)? = null,
    onDismiss: () -> Unit
) {
    val dynamicModelsMap = remember {
        mutableStateMapOf(
            "openai" to listOf("gpt-4o", "gpt-4o-mini", "o1", "o1-mini", "gpt-4-turbo"),
            "google" to listOf("gemini-1.5-pro", "gemini-1.5-flash", "gemini-2.0-flash-exp"),
            "anthropic" to listOf("claude-3-5-sonnet-20241022", "claude-3-5-haiku-20241022", "claude-3-opus-20240229"),
            "ollama" to listOf("llama3.2:latest", "smollm2:135m", "llava:latest", "llava:7b", "pentest_test:1.0", "probe-nonexistent:latest")
        )
    }

    var configuringModel by remember { mutableStateOf<Pair<String, String>?>(null) }
    var customModelInput by remember { mutableStateOf("") }
    var showCustomInput by remember { mutableStateOf(false) }

    LaunchedEffect(providers) {
        providers.filter { it.type == ProviderType.OLLAMA }.forEach { ollamaProv ->
            val remoteModels = onFetchOllamaModels?.invoke(ollamaProv.baseUrl) ?: emptyList()
            if (remoteModels.isNotEmpty()) {
                dynamicModelsMap[ollamaProv.id] = remoteModels
            }
        }
    }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.85f)
                .imePadding()
                .padding(horizontal = 20.dp, vertical = 12.dp)
        ) {
            LazyColumn(
                modifier = Modifier.fillMaxWidth().weight(1f),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                item(key = "model-picker-controls") {
                    Column {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(bottom = 16.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = "Select Model",
                                modifier = Modifier.weight(1f).padding(end = 8.dp),
                                style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.Bold)
                            )

                            TextButton(onClick = { showCustomInput = !showCustomInput }) {
                                Icon(Icons.Outlined.Add, contentDescription = null, modifier = Modifier.size(16.dp))
                                Spacer(modifier = Modifier.width(4.dp))
                                Text(if (showCustomInput) "Hide Custom" else "Custom Model")
                            }
                        }

                        if (showCustomInput) {
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(bottom = 12.dp),
                                horizontalArrangement = Arrangement.spacedBy(8.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                OutlinedTextField(
                                    value = customModelInput,
                                    onValueChange = { customModelInput = it },
                                    placeholder = { Text("e.g. smollm2:135m") },
                                    singleLine = true,
                                    modifier = Modifier.weight(1f)
                                )
                                Button(
                                    onClick = {
                                        if (customModelInput.isNotBlank()) {
                                            val provId = selectedProviderId.ifBlank { providers.firstOrNull()?.id ?: "ollama" }
                                            onSelectModel(provId, customModelInput.trim())
                                            onDismiss()
                                        }
                                    }
                                ) {
                                    Text("Apply")
                                }
                            }
                        }
                    }
                }
                items(providers) { provider ->
                    val models = ((dynamicModelsMap[provider.id]
                        ?: dynamicModelsMap[provider.type.name.lowercase()]
                        ?: emptyList()) + provider.config.modelConfigs.keys +
                        if (provider.id == selectedProviderId && selectedModelId.isNotBlank()) listOf(selectedModelId) else emptyList()).distinct()

                    Column(modifier = Modifier.fillMaxWidth()) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(bottom = 6.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = provider.name.uppercase(),
                                modifier = Modifier.weight(1f).padding(end = 8.dp),
                                maxLines = 2,
                                overflow = TextOverflow.Ellipsis,
                                style = MaterialTheme.typography.labelSmall.copy(
                                    fontWeight = FontWeight.Bold,
                                    letterSpacing = 1.sp
                                ),
                                color = MaterialTheme.colorScheme.primary
                            )
                            Text(
                                text = "${models.size} models",
                                style = MaterialTheme.typography.labelSmall,
                                color = MaterialTheme.colorScheme.outline
                            )
                        }

                        Card(
                            shape = RoundedCornerShape(12.dp),
                            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceContainerLow)
                        ) {
                            Column {
                                models.forEachIndexed { index, modelName ->
                                    val isSelected = provider.id == selectedProviderId && modelName == selectedModelId

                                    Row(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .clickable {
                                                onSelectModel(provider.id, modelName)
                                                onDismiss()
                                            }
                                            .padding(horizontal = 16.dp, vertical = 12.dp),
                                        horizontalArrangement = Arrangement.SpaceBetween,
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        Row(
                                            verticalAlignment = Alignment.CenterVertically,
                                            modifier = Modifier.weight(1f)
                                        ) {
                                            Icon(
                                                imageVector = Icons.Outlined.SmartToy,
                                                contentDescription = null,
                                                tint = if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outline,
                                                modifier = Modifier.size(20.dp)
                                            )
                                            Spacer(modifier = Modifier.width(12.dp))
                                            Text(
                                                text = modelName,
                                                modifier = Modifier.weight(1f),
                                                maxLines = 2,
                                                overflow = TextOverflow.Ellipsis,
                                                style = MaterialTheme.typography.bodyMedium.copy(
                                                    fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal
                                                ),
                                                color = if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface
                                            )
                                        }

                                        IconButton(onClick = { configuringModel = provider.id to modelName }) {
                                            Icon(Icons.Outlined.Tune, contentDescription = "Configure $modelName")
                                        }
                                        if (isSelected) {
                                            Icon(
                                                imageVector = Icons.Default.Check,
                                                contentDescription = "Selected",
                                                tint = MaterialTheme.colorScheme.primary,
                                                modifier = Modifier.size(20.dp)
                                            )
                                        }
                                    }

                                    if (index < models.size - 1) {
                                        HorizontalDivider(
                                            modifier = Modifier.padding(horizontal = 16.dp),
                                            color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.3f),
                                            thickness = 0.5.dp
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    configuringModel?.let { (providerId, modelId) ->
        providers.find { it.id == providerId }?.let { provider ->
            key(providerId, modelId) {
                ModelConfigDialog(provider, modelId,
                    onSave = { onSaveModelConfig(providerId, modelId, it) },
                    onDismiss = { configuringModel = null })
            }
        }
    }

}
