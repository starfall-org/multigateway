package org.starfall.multigateway.ui.providers

import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.ui.text.input.KeyboardType
import android.widget.Toast
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import kotlinx.serialization.json.Json
import kotlinx.serialization.encodeToString
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Error
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.launch
import org.starfall.multigateway.data.model.AuthMethod
import org.starfall.multigateway.data.model.Authorization
import org.starfall.multigateway.data.model.LlmProviderInfo
import org.starfall.multigateway.data.model.ProviderType

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProviderScreen(
    providers: List<LlmProviderInfo>,
    onSaveProvider: (LlmProviderInfo) -> Unit,
    onDeleteProvider: (String) -> Unit,
    onTestConnection: (suspend (LlmProviderInfo) -> Result<String>)? = null,
    onBack: () -> Unit
) {
    var isGridView by remember { mutableStateOf(false) }
    var editingProvider by remember { mutableStateOf<LlmProviderInfo?>(null) }
    var isCreatingNew by remember { mutableStateOf(false) }
    var deletingProviderId by remember { mutableStateOf<String?>(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(
                            text = "Providers",
                            style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.SemiBold)
                        )
                        Text(
                            text = "Manage AI providers",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.outline
                        )
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    IconButton(onClick = { isGridView = !isGridView }) {
                        Icon(
                            imageVector = if (isGridView) Icons.Outlined.ViewList else Icons.Outlined.GridView,
                            contentDescription = if (isGridView) "Switch to List View" else "Switch to Grid View"
                        )
                    }
                }
            )
        },
        floatingActionButton = {
            ExtendedFloatingActionButton(
                onClick = { isCreatingNew = true },
                icon = { Icon(Icons.Default.Add, contentDescription = null) },
                text = { Text("Add Provider") }
            )
        }
    ) { padding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 16.dp, vertical = 8.dp)
        ) {
            if (providers.isEmpty()) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            imageVector = Icons.Outlined.Hub,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.outline,
                            modifier = Modifier.size(64.dp)
                        )
                        Spacer(modifier = Modifier.height(12.dp))
                        Text(
                            text = "No Providers Added",
                            style = MaterialTheme.typography.titleMedium,
                            color = MaterialTheme.colorScheme.outline
                        )
                    }
                }
            } else if (isGridView) {
                LazyVerticalGrid(
                    columns = GridCells.Adaptive(minSize = 180.dp),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp),
                    modifier = Modifier.fillMaxSize()
                ) {
                    items(providers, key = { it.id }) { provider ->
                        ProviderGridCard(
                            provider = provider,
                            onEdit = { editingProvider = provider },
                            onDelete = { deletingProviderId = provider.id }
                        )
                    }
                }
            } else {
                LazyColumn(
                    verticalArrangement = Arrangement.spacedBy(10.dp),
                    modifier = Modifier.fillMaxSize()
                ) {
                    items(providers, key = { it.id }) { provider ->
                        ProviderListCard(
                            provider = provider,
                            onEdit = { editingProvider = provider },
                            onDelete = { deletingProviderId = provider.id }
                        )
                    }
                }
            }
        }
    }

    // Add or Edit Dialog
    if (editingProvider != null || isCreatingNew) {
        val targetProvider = editingProvider ?: LlmProviderInfo(
            id = "custom_${System.currentTimeMillis()}",
            name = "Ollama",
            type = ProviderType.OLLAMA,
            baseUrl = "https://ollama.com/api",
            auth = Authorization(method = AuthMethod.OTHER, key = "", value = "")
        )

        AddOrEditProviderDialog(
            initialProvider = targetProvider,
            isNew = isCreatingNew,
            onTestConnection = onTestConnection,
            onDismiss = {
                editingProvider = null
                isCreatingNew = false
            },
            onSave = { saved ->
                onSaveProvider(saved)
                editingProvider = null
                isCreatingNew = false
            }
        )
    }

    // Delete confirmation
    if (deletingProviderId != null) {
        AlertDialog(
            onDismissRequest = { deletingProviderId = null },
            title = { Text("Delete Provider") },
            text = { Text("Are you sure you want to remove this AI provider? Stored credentials will be deleted.") },
            confirmButton = {
                Button(
                    onClick = {
                        deletingProviderId?.let { onDeleteProvider(it) }
                        deletingProviderId = null
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.error)
                ) {
                    Text("Delete")
                }
            },
            dismissButton = {
                TextButton(onClick = { deletingProviderId = null }) {
                    Text("Cancel")
                }
            }
        )
    }
}

@Composable
fun ProviderListCard(
    provider: LlmProviderInfo,
    onEdit: () -> Unit,
    onDelete: () -> Unit
) {
    Surface(
        shape = RoundedCornerShape(16.dp),
        color = MaterialTheme.colorScheme.surfaceContainerLow,
        border = androidx.compose.foundation.BorderStroke(
            1.dp,
            MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.5f)
        ),
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onEdit() }
    ) {
        Row(
            modifier = Modifier.padding(14.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Surface(
                shape = CircleShape,
                color = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.7f),
                modifier = Modifier.size(44.dp)
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Icon(
                        imageVector = Icons.Outlined.Hub,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.size(22.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.width(14.dp))

            Column(modifier = Modifier.weight(1f)) {
                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text(
                        text = provider.name,
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis,
                        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Surface(
                        shape = RoundedCornerShape(6.dp),
                        color = MaterialTheme.colorScheme.secondaryContainer.copy(alpha = 0.6f)
                    ) {
                        Text(
                            text = provider.type.name,
                            style = MaterialTheme.typography.labelSmall.copy(fontSize = 10.sp),
                            color = MaterialTheme.colorScheme.onSecondaryContainer,
                            modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                        )
                    }
                }
                Text(
                    text = provider.baseUrl,
                    style = MaterialTheme.typography.bodySmall.copy(fontSize = 11.sp),
                    color = MaterialTheme.colorScheme.outline,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }

            IconButton(onClick = onEdit) {
                Icon(
                    imageVector = Icons.Outlined.Settings,
                    contentDescription = "Configure",
                    tint = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.size(20.dp)
                )
            }

            IconButton(onClick = onDelete) {
                Icon(
                    imageVector = Icons.Outlined.DeleteOutline,
                    contentDescription = "Delete",
                    tint = MaterialTheme.colorScheme.error,
                    modifier = Modifier.size(20.dp)
                )
            }
        }
    }
}

@Composable
fun ProviderGridCard(
    provider: LlmProviderInfo,
    onEdit: () -> Unit,
    onDelete: () -> Unit
) {
    Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceContainerLow),
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onEdit() }
    ) {
        Column(
            modifier = Modifier.padding(14.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Surface(
                    shape = CircleShape,
                    color = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.6f),
                    modifier = Modifier.size(36.dp)
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Icon(
                            imageVector = Icons.Outlined.Hub,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.primary,
                            modifier = Modifier.size(18.dp)
                        )
                    }
                }

                Row {
                    IconButton(onClick = onEdit, modifier = Modifier.size(48.dp)) {
                        Icon(Icons.Outlined.Edit, contentDescription = "Edit", modifier = Modifier.size(16.dp))
                    }
                    IconButton(onClick = onDelete, modifier = Modifier.size(48.dp)) {
                        Icon(Icons.Outlined.Delete, contentDescription = "Delete", tint = MaterialTheme.colorScheme.error, modifier = Modifier.size(16.dp))
                    }
                }
            }

            Text(
                text = provider.name,
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )

            Text(
                text = provider.baseUrl,
                style = MaterialTheme.typography.bodySmall.copy(fontSize = 11.sp),
                color = MaterialTheme.colorScheme.outline,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddOrEditProviderDialog(
    initialProvider: LlmProviderInfo,
    isNew: Boolean,
    onTestConnection: (suspend (LlmProviderInfo) -> Result<String>)? = null,
    onDismiss: () -> Unit,
    onSave: (LlmProviderInfo) -> Unit
) {
    val coroutineScope = rememberCoroutineScope()

    var name by remember { mutableStateOf(initialProvider.name) }
    var type by remember { mutableStateOf(initialProvider.type) }
    var baseUrl by remember { mutableStateOf(initialProvider.baseUrl) }
    var apiKey by remember { mutableStateOf(initialProvider.auth.key ?: initialProvider.auth.value ?: "") }
    var isTestingConnection by remember { mutableStateOf(false) }
    var testResult by remember { mutableStateOf<String?>(null) }
    var testIsSuccess by remember { mutableStateOf(false) }
    var typeExpanded by remember { mutableStateOf(false) }
    var maxTokens by remember { mutableStateOf(initialProvider.config.maxTokens.toString()) }
    var supportStream by remember { mutableStateOf(initialProvider.config.supportStream) }
    var headersText by remember { mutableStateOf(Json.encodeToString(initialProvider.config.headers)) }
    val parsedHeaders = runCatching { Json.decodeFromString<Map<String, String>>(headersText) }.getOrNull()
    val headersValid = parsedHeaders != null && parsedHeaders.all { (key, value) ->
        key.isNotBlank() && key.none { it <= ' ' || it == ':' || it.code >= 127 } && value.none { it == '\r' || it == '\n' }
    }
    val requestValid = maxTokens.toIntOrNull()?.let { it > 0 } == true && headersValid
    fun requestConfig() = initialProvider.config.copy(
        maxTokens = maxTokens.toIntOrNull() ?: initialProvider.config.maxTokens,
        supportStream = supportStream, headers = parsedHeaders ?: initialProvider.config.headers
    )

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(if (isNew) "Add Provider" else "Configure Provider") },
        text = {
            Column(modifier = Modifier.fillMaxWidth().verticalScroll(rememberScrollState()), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                // Provider Type Dropdown
                ExposedDropdownMenuBox(
                    expanded = typeExpanded,
                    onExpandedChange = { typeExpanded = !typeExpanded }
                ) {
                    OutlinedTextField(
                        value = type.displayName,
                        onValueChange = {},
                        readOnly = true,
                        label = { Text("Provider Type") },
                        trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = typeExpanded) },
                        modifier = Modifier.menuAnchor().fillMaxWidth()
                    )

                    ExposedDropdownMenu(
                        expanded = typeExpanded,
                        onDismissRequest = { typeExpanded = false }
                    ) {
                        ProviderType.values().forEach { t ->
                            DropdownMenuItem(
                                text = { Text(t.displayName) },
                                onClick = {
                                    type = t
                                    typeExpanded = false
                                    if (t == ProviderType.OLLAMA && (baseUrl.contains("api.openai.com") || baseUrl.isBlank())) {
                                        baseUrl = "https://ollama.com/api"
                                    }
                                }
                            )
                        }
                    }
                }

                OutlinedTextField(
                    value = name,
                    onValueChange = { name = it },
                    label = { Text("Provider Name") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )

                OutlinedTextField(
                    value = baseUrl,
                    onValueChange = { baseUrl = it },
                    label = { Text("Base API Endpoint / URL") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )

                if (type == ProviderType.OLLAMA) {
                    SuggestionChip(
                        onClick = { baseUrl = "https://ollama.com/api" },
                        label = { Text("Default: https://ollama.com/api", fontSize = 11.sp) },
                        icon = { Icon(Icons.Outlined.Link, contentDescription = null, modifier = Modifier.size(14.dp)) }
                    )
                }

                OutlinedTextField(
                    value = apiKey,
                    onValueChange = { apiKey = it },
                    label = { Text(if (type == ProviderType.OLLAMA) "API Key / Token (Optional)" else "API Key") },
                    singleLine = true,
                    visualTransformation = PasswordVisualTransformation(),
                    modifier = Modifier.fillMaxWidth()
                )

                HorizontalDivider()
                Text("Request config", style = MaterialTheme.typography.titleSmall)
                OutlinedTextField(maxTokens, { maxTokens = it }, label = { Text("Maximum output tokens") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    supportingText = { if (maxTokens.toIntOrNull()?.let { it > 0 } != true) Text("Enter a positive whole number.") },
                    singleLine = true, isError = maxTokens.toIntOrNull()?.let { it > 0 } != true,
                    modifier = Modifier.fillMaxWidth())
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically) {
                    Text("Stream responses", modifier = Modifier.weight(1f).padding(end = 12.dp))
                    Switch(checked = supportStream, onCheckedChange = { supportStream = it })
                }
                OutlinedTextField(headersText, { headersText = it }, label = { Text("Request headers (JSON)") },
                    supportingText = { if (!headersValid) Text("Use a JSON object with valid header names and text values.") },
                    isError = !headersValid, minLines = 2, maxLines = 5, modifier = Modifier.fillMaxWidth())

                OutlinedButton(
                    onClick = {
                        isTestingConnection = true
                        testResult = null
                        val testTarget = initialProvider.copy(
                            name = name.trim().ifEmpty { "Provider" },
                            type = type,
                            baseUrl = baseUrl.trim(),
                            auth = initialProvider.auth.copy(key = apiKey.trim(), value = apiKey.trim()),
                            config = requestConfig()
                        )
                        coroutineScope.launch {
                            val res = onTestConnection?.invoke(testTarget) ?: Result.success("Endpoint reachable")
                            isTestingConnection = false
                            if (res.isSuccess) {
                                testIsSuccess = true
                                testResult = res.getOrNull() ?: "Connected successfully!"
                            } else {
                                testIsSuccess = false
                                testResult = res.exceptionOrNull()?.localizedMessage ?: "Connection failed"
                            }
                        }
                    },
                    modifier = Modifier.fillMaxWidth(),
                    enabled = !isTestingConnection && baseUrl.isNotBlank() && requestValid
                ) {
                    if (isTestingConnection) {
                        CircularProgressIndicator(modifier = Modifier.size(16.dp), strokeWidth = 2.dp)
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Testing...")
                    } else {
                        Icon(Icons.Outlined.NetworkCheck, contentDescription = null, modifier = Modifier.size(18.dp))
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Test Connection")
                    }
                }

                // Test result banner
                if (testResult != null) {
                    Surface(
                        shape = RoundedCornerShape(8.dp),
                        color = if (testIsSuccess) MaterialTheme.colorScheme.primaryContainer else MaterialTheme.colorScheme.errorContainer,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Row(
                            modifier = Modifier.padding(10.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                imageVector = if (testIsSuccess) Icons.Default.CheckCircle else Icons.Default.Error,
                                contentDescription = null,
                                tint = if (testIsSuccess) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.error,
                                modifier = Modifier.size(18.dp)
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = testResult ?: "",
                                style = MaterialTheme.typography.bodySmall,
                                color = if (testIsSuccess) MaterialTheme.colorScheme.onPrimaryContainer else MaterialTheme.colorScheme.onErrorContainer
                            )
                        }
                    }
                }
            }
        },
        confirmButton = {
            Button(
                enabled = requestValid && baseUrl.isNotBlank(),
                onClick = {
                    val updated = initialProvider.copy(
                        name = name.trim().ifEmpty { type.displayName },
                        type = type,
                        baseUrl = baseUrl.trim(),
                        auth = initialProvider.auth.copy(key = apiKey.trim(), value = apiKey.trim()),
                            config = requestConfig()
                    )
                    onSave(updated)
                }
            ) {
                Text("Save")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}
