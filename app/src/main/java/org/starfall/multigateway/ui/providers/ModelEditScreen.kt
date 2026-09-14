package org.starfall.multigateway.ui.providers

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import org.starfall.multigateway.data.model.*
import org.starfall.multigateway.ui.chat.ModelConfigDialog

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ModelEditScreen(
    provider: LlmProviderInfo,
    initialModelId: String,
    existingModelIds: Set<String>,
    onSave: (String, ModelConfiguration) -> Unit,
    onBack: () -> Unit
) {
    var modelId by remember { mutableStateOf(initialModelId) }
    var config by remember { mutableStateOf(provider.config.modelConfigs[initialModelId] ?: ModelConfiguration()) }
    var typeExpanded by remember { mutableStateOf(false) }
    var showSampling by remember { mutableStateOf(false) }
    val trimmedId = modelId.trim()
    val idError = when {
        trimmedId.isBlank() -> "Model ID is required."
        trimmedId.any { it.isWhitespace() } -> "Model ID cannot contain whitespace."
        trimmedId != initialModelId && trimmedId in existingModelIds -> "This provider already has a model with this ID."
        else -> null
    }
    BackHandler(onBack = onBack)
    Scaffold(
        modifier = Modifier.fillMaxSize().imePadding(),
        topBar = {
            TopAppBar(
                title = { Text("Edit Model") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    TextButton(enabled = idError == null, onClick = {
                        onSave(trimmedId, config.copy(displayName = config.displayName.trim()))
                    }) { Text("Save") }
                }
            )
        }
    ) { padding ->
        Column(
            Modifier.fillMaxSize().padding(padding).verticalScroll(rememberScrollState()).padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            OutlinedTextField(
                value = config.displayName,
                onValueChange = { config = config.copy(displayName = it) },
                label = { Text("Display name") },
                supportingText = { Text("Leave blank to display the model ID.") },
                singleLine = true, modifier = Modifier.fillMaxWidth()
            )
            OutlinedTextField(
                value = modelId, onValueChange = { modelId = it },
                label = { Text("Model ID") },
                supportingText = { Text(idError ?: "The ID sent to the provider API.") },
                isError = idError != null, singleLine = true, modifier = Modifier.fillMaxWidth()
            )
            ExposedDropdownMenuBox(expanded = typeExpanded, onExpandedChange = { typeExpanded = !typeExpanded }) {
                OutlinedTextField(
                    value = config.modelType.displayName, onValueChange = {}, readOnly = true,
                    label = { Text("Model type") },
                    trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = typeExpanded) },
                    modifier = Modifier.menuAnchor().fillMaxWidth()
                )
                ExposedDropdownMenu(expanded = typeExpanded, onDismissRequest = { typeExpanded = false }) {
                    ModelType.entries.forEach { type ->
                        DropdownMenuItem(text = { Text(type.displayName) }, onClick = {
                            config = config.copy(modelType = type)
                            typeExpanded = false
                        })
                    }
                }
            }
            if (config.modelType == ModelType.TEXT_GENERATION) {
                HorizontalDivider()
                Text("Capabilities", style = MaterialTheme.typography.titleMedium)
                ModelCapabilitySwitch("Vision", config.supportsVision) { config = config.copy(supportsVision = it) }
                ModelCapabilitySwitch("Thinking", config.supportsThinking) { config = config.copy(supportsThinking = it) }
                ModelCapabilitySwitch("Tool calls", config.supportsToolCalls) { config = config.copy(supportsToolCalls = it) }
                HorizontalDivider()
                Text("Streaming", style = MaterialTheme.typography.titleMedium)
                ModelCapabilitySwitch("Use provider stream setting", config.supportStream == null) {
                    config = config.copy(supportStream = if (it) null else provider.config.supportStream)
                }
                if (config.supportStream == null) {
                    Text("Provider: ${if (provider.config.supportStream) "On" else "Off"}",
                        style = MaterialTheme.typography.bodyMedium)
                } else {
                    ModelCapabilitySwitch("Stream responses", config.supportStream == true) {
                        config = config.copy(supportStream = it)
                    }
                }
                OutlinedButton(onClick = { showSampling = true }, modifier = Modifier.fillMaxWidth()) {
                    Text("Temperature / Top-p / Top-k")
                }
            }
        }
    }
    if (showSampling) {
        ModelConfigDialog(
            provider = provider.copy(config = provider.config.copy(
                modelConfigs = provider.config.modelConfigs + (initialModelId to config)
            )),
            modelId = initialModelId,
            onSave = { config = it },
            onDismiss = { showSampling = false }
        )
    }
}

@Composable
private fun ModelCapabilitySwitch(label: String, checked: Boolean, onCheckedChange: (Boolean) -> Unit) {
    Row(Modifier.fillMaxWidth().heightIn(min = 48.dp), verticalAlignment = Alignment.CenterVertically) {
        Text(label, modifier = Modifier.weight(1f).padding(end = 12.dp))
        Switch(checked = checked, onCheckedChange = onCheckedChange)
    }
}
