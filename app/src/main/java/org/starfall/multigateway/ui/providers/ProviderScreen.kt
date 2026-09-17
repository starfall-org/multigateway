package org.starfall.multigateway.ui.providers

import androidx.activity.compose.BackHandler
import kotlinx.coroutines.CancellationException
import org.starfall.multigateway.data.model.ModelConfiguration
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
import org.starfall.multigateway.data.model.withType
import org.starfall.multigateway.data.model.ProviderType

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProviderScreen(
    providers: List<LlmProviderInfo>,
    onSaveProvider: (LlmProviderInfo) -> Unit,
    onDeleteProvider: (String) -> Unit,
    onTestConnection: (suspend (LlmProviderInfo) -> Result<String>)? = null,
    onFetchModels: (suspend (LlmProviderInfo) -> List<String>)? = null,
    onBack: () -> Unit
) {
    var isGridView by remember { mutableStateOf(false) }
    var editingProvider by remember { mutableStateOf<LlmProviderInfo?>(null) }
    var isCreatingNew by remember { mutableStateOf(false) }
    var deletingProviderId by remember { mutableStateOf<String?>(null) }

    if (editingProvider != null || isCreatingNew) {
        val targetProvider = editingProvider ?: remember { LlmProviderInfo(
            id = "custom_${System.currentTimeMillis()}",
            name = "Ollama",
            type = ProviderType.OLLAMA,
            baseUrl = "https://ollama.com/api",
            auth = Authorization(method = AuthMethod.OTHER, key = "", value = "")
        ) }

        ProviderEditScreen(
            initialProvider = targetProvider,
            isNew = isCreatingNew,
            onTestConnection = onTestConnection,
            onFetchModels = onFetchModels,
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
        return
    }

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
                            text = provider.type.displayName,
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
fun ProviderEditScreen(
    initialProvider: LlmProviderInfo,
    isNew: Boolean,
    onTestConnection: (suspend (LlmProviderInfo) -> Result<String>)? = null,
    onFetchModels: (suspend (LlmProviderInfo) -> List<String>)? = null,
    onDismiss: () -> Unit,
    onSave: (LlmProviderInfo) -> Unit
) {
    val coroutineScope = rememberCoroutineScope()

    var name by remember { mutableStateOf(initialProvider.name) }
    var type by remember { mutableStateOf(initialProvider.type) }
    var baseUrl by remember { mutableStateOf(initialProvider.baseUrl) }
    var authMethod by remember { mutableStateOf(initialProvider.auth.method) }
    var authName by remember { mutableStateOf(if (initialProvider.auth.method in listOf(AuthMethod.CUSTOM_HEADER, AuthMethod.QUERY_PARAM)) initialProvider.auth.key.orEmpty() else "") }
    var apiKey by remember { mutableStateOf(if (initialProvider.auth.method in listOf(AuthMethod.CUSTOM_HEADER, AuthMethod.QUERY_PARAM)) initialProvider.auth.value.orEmpty() else initialProvider.auth.token) }
    fun authorization() = Authorization(authMethod, if (authMethod in listOf(AuthMethod.CUSTOM_HEADER, AuthMethod.QUERY_PARAM)) authName.trim() else null, apiKey.trim())
    var isTestingConnection by remember { mutableStateOf(false) }
    var testResult by remember { mutableStateOf<String?>(null) }
    var testIsSuccess by remember { mutableStateOf(false) }
    var typeExpanded by remember { mutableStateOf(false) }
    var supportStream by remember { mutableStateOf(initialProvider.config.supportStream) }
    var headersText by remember { mutableStateOf(Json.encodeToString(initialProvider.config.headers)) }
    var selectedTab by remember { mutableStateOf(0) }
    var modelConfigs by remember {
        mutableStateOf(initialProvider.config.modelIds?.associateWith {
            initialProvider.config.modelConfigs[it] ?: ModelConfiguration()
        } ?: initialProvider.config.modelConfigs)
    }
    var configuringModel by remember { mutableStateOf<String?>(null) }
    var showModelCatalog by remember { mutableStateOf(false) }
    BackHandler(onBack = onDismiss)
    val parsedHeaders = runCatching { Json.decodeFromString<Map<String, String>>(headersText) }.getOrNull()
    val headersValid = parsedHeaders != null && parsedHeaders.all { (key, value) ->
        key.isNotBlank() && key.none { it <= ' ' || it == ':' || it.code >= 127 } && value.none { it == '\r' || it == '\n' }
    }
    val urlValid = runCatching { org.starfall.multigateway.data.tools.providerBase(initialProvider.copy(baseUrl = baseUrl)) }.isSuccess
    val authValid = authMethod !in listOf(AuthMethod.CUSTOM_HEADER, AuthMethod.QUERY_PARAM) ||
        (authName.isNotBlank() && authName.none { it <= ' ' || it == ':' || it.code >= 127 })
    val requestValid = urlValid && authValid && headersValid
    fun requestConfig() = initialProvider.config.copy(
        supportStream = supportStream, headers = parsedHeaders ?: initialProvider.config.headers,
        modelConfigs = modelConfigs, modelIds = modelConfigs.keys.toList()
    )

    val editingModelId = configuringModel
    if (editingModelId != null) {
        key(editingModelId) {
            ModelEditScreen(
                provider = initialProvider.copy(type = type, config = requestConfig()),
                initialModelId = editingModelId,
                existingModelIds = modelConfigs.keys,
                onSave = { newId, config ->
                    modelConfigs = modelConfigs.entries.associate { (id, value) ->
                        if (id == editingModelId) newId to config else id to value
                    }
                    configuringModel = null
                },
                onBack = { configuringModel = null }
            )
        }
        return
    }

    Scaffold(
        modifier = Modifier.fillMaxSize().imePadding(),
        floatingActionButton = {
            if (selectedTab == 1) {
                FloatingActionButton(onClick = { showModelCatalog = true }) {
                    Icon(Icons.Default.Add, contentDescription = "Add models")
                }
            }
        },
        topBar = {
            TopAppBar(
                title = { Text(if (isNew) "Add LLM Provider" else "LLM Provider Edit") },
                navigationIcon = {
                    IconButton(onClick = onDismiss) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    TextButton(
                        enabled = requestValid && baseUrl.isNotBlank(),
                        onClick = {
                            onSave(initialProvider.copy(
                                name = name.trim().ifEmpty { type.defaultName },
                                type = type,
                                baseUrl = baseUrl.trim(),
                                auth = authorization(),
                                config = requestConfig()
                            ))
                        }
                    ) { Text("Save") }
                }
            )
        }
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding)) {
            TabRow(selectedTabIndex = selectedTab) {
                listOf("Settings", "Models").forEachIndexed { index, label ->
                    Tab(selected = selectedTab == index, onClick = { selectedTab = index }, text = { Text(label) })
                }
            }
            if (selectedTab == 0) {
                Column(
                    modifier = Modifier.weight(1f).fillMaxWidth().verticalScroll(rememberScrollState()).padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
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
                                        val updated = initialProvider.copy(name = name, type = type, baseUrl = baseUrl).withType(t)
                                        name = updated.name
                                        baseUrl = updated.baseUrl
                                        type = updated.type
                                        typeExpanded = false
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
                        isError = !urlValid,
                        supportingText = { if (!urlValid) Text("Use an HTTP(S) base URL without query, fragment or embedded credentials.") },
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

                    if (baseUrl.trim().startsWith("http://", true)) {
                        Text("HTTP is unencrypted. API keys, headers and messages can be read on the network. Use HTTPS outside a trusted local network.", color = MaterialTheme.colorScheme.error, style = MaterialTheme.typography.bodySmall)
                    }
                    var authExpanded by remember { mutableStateOf(false) }
                    Box {
                        OutlinedButton(onClick = { authExpanded = true }) { Text("Authorization: ${authMethod.name}") }
                        DropdownMenu(expanded = authExpanded, onDismissRequest = { authExpanded = false }) {
                            AuthMethod.entries.forEach { method ->
                                DropdownMenuItem(text = { Text(method.name) }, onClick = { authMethod = method; authExpanded = false })
                            }
                        }
                    }
                    if (authMethod in listOf(AuthMethod.CUSTOM_HEADER, AuthMethod.QUERY_PARAM)) {
                        OutlinedTextField(authName, { authName = it }, label = { Text(if (authMethod == AuthMethod.CUSTOM_HEADER) "Header name" else "Query parameter name") },
                            isError = !authValid, singleLine = true, modifier = Modifier.fillMaxWidth())
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
                                auth = authorization(),
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
            } else {
                val models = modelConfigs.keys.toList()
                LazyColumn(
                    modifier = Modifier.weight(1f).fillMaxWidth(),
                    contentPadding = PaddingValues(start = 16.dp, top = 16.dp, end = 16.dp, bottom = 96.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    if (models.isEmpty()) {
                        item { Text("No models added. Tap + to browse available models.") }
                    }
                    items(models, key = { it }) { modelId ->
                        ListItem(
                            headlineContent = { Text(modelConfigs[modelId]?.displayName?.ifBlank { modelId } ?: modelId,
                                overflow = TextOverflow.Ellipsis, maxLines = 2) },
                            supportingContent = { Text("$modelId · ${modelConfigs[modelId]?.modelType?.displayName.orEmpty()}") },
                            trailingContent = {
                                IconButton(onClick = { configuringModel = modelId }) {
                                    Icon(Icons.Outlined.Tune, contentDescription = "Configure $modelId")
                                }
                            },
                            modifier = Modifier.clickable { configuringModel = modelId }
                        )
                    }
                }
            }
        }
    }
    if (showModelCatalog) {
        ProviderModelCatalogSheet(
            provider = initialProvider.copy(
                name = name, type = type, baseUrl = baseUrl.trim(),
                auth = authorization(),
                config = requestConfig()
            ),
            selectedModels = modelConfigs.keys,
            onFetchModels = onFetchModels,
            onToggle = { id ->
                modelConfigs = if (id in modelConfigs) modelConfigs - id else modelConfigs + (id to ModelConfiguration())
            },
            onSetSelection = { ids, selected ->
                modelConfigs = if (selected) {
                    modelConfigs + ids.associateWith { modelConfigs[it] ?: ModelConfiguration() }
                } else {
                    modelConfigs - ids.toSet()
                }
            },
            onDismiss = { showModelCatalog = false }
        )
    }

}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ProviderModelCatalogSheet(
    provider: LlmProviderInfo,
    selectedModels: Set<String>,
    onFetchModels: (suspend (LlmProviderInfo) -> List<String>)?,
    onToggle: (String) -> Unit,
    onSetSelection: (List<String>, Boolean) -> Unit,
    onDismiss: () -> Unit
) {
    var models by remember { mutableStateOf<List<String>>(emptyList()) }
    var loading by remember { mutableStateOf(true) }
    var loadError by remember { mutableStateOf<String?>(null) }
    var refresh by remember { mutableStateOf(0) }
    var query by remember { mutableStateOf("") }
    LaunchedEffect(refresh) {
        loading = true
        loadError = null
        try {
            models = (onFetchModels ?: error("Model discovery is unavailable"))(provider).distinct()
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            loadError = e.localizedMessage ?: "Unable to load models"
        } finally {
            loading = false
        }
    }
    // The list and bulk action use exactly the same filtered IDs.
    val visibleModels = (models + selectedModels).distinct().filter { it.contains(query, ignoreCase = true) }
    val allVisibleSelected = visibleModels.isNotEmpty() && visibleModels.all { it in selectedModels }
    ModalBottomSheet(onDismissRequest = onDismiss, sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)) {
        Column(Modifier.fillMaxWidth().fillMaxHeight(0.85f).imePadding().padding(horizontal = 16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                IconButton(onClick = { refresh++ }, enabled = !loading) {
                    Icon(Icons.Outlined.Refresh, contentDescription = "Refresh models")
                }
                OutlinedTextField(query, { query = it }, label = { Text("Search models") },
                    singleLine = true, modifier = Modifier.weight(1f))
                IconButton(
                    onClick = { onSetSelection(visibleModels, !allVisibleSelected) },
                    enabled = visibleModels.isNotEmpty()
                ) {
                    Icon(
                        imageVector = if (allVisibleSelected) Icons.Outlined.Close else Icons.Outlined.SelectAll,
                        contentDescription = if (allVisibleSelected) "Remove all visible models" else "Select all visible models",
                        tint = when {
                            visibleModels.isEmpty() -> MaterialTheme.colorScheme.onSurface.copy(alpha = 0.38f)
                            allVisibleSelected -> MaterialTheme.colorScheme.error
                            else -> MaterialTheme.colorScheme.primary
                        }
                    )
                }
            }
            if (loading) LinearProgressIndicator(Modifier.fillMaxWidth())
            loadError?.let {
                Text(it, color = MaterialTheme.colorScheme.error)
                TextButton(onClick = { refresh++ }, enabled = !loading) { Text("Retry") }
            }
            LazyColumn(Modifier.weight(1f), contentPadding = PaddingValues(bottom = 24.dp)) {
                if (visibleModels.isEmpty() && !loading && loadError == null) {
                    item { Text(if (query.isBlank()) "No models returned." else "No matching models.", modifier = Modifier.padding(16.dp)) }
                }
                items(visibleModels, key = { it }) { id ->
                    val added = id in selectedModels
                    ListItem(
                        headlineContent = { Text(id, maxLines = 2, overflow = TextOverflow.Ellipsis) },
                        supportingContent = { Text(if (added) "Added" else "Not added") },
                        trailingContent = {
                            IconButton(onClick = { onToggle(id) }) {
                                Icon(if (added) Icons.Outlined.Close else Icons.Default.Add,
                                    contentDescription = if (added) "Remove $id" else "Add $id",
                                    tint = if (added) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.primary)
                            }
                        }
                    )
                }
            }
        }
    }
}
