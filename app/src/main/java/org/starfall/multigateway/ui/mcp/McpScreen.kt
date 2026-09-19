package org.starfall.multigateway.ui.mcp
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context

import androidx.compose.animation.animateContentSize
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.text.selection.SelectionContainer
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.GridView
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.List
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material.icons.outlined.Edit
import androidx.compose.material.icons.outlined.Extension
import androidx.compose.material.icons.outlined.ErrorOutline
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.window.DialogWindowProvider
import androidx.core.view.WindowCompat
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.launch
import kotlinx.serialization.json.*
import org.starfall.multigateway.data.model.McpAuthMethod
import org.starfall.multigateway.data.model.McpAuthorization
import org.starfall.multigateway.data.model.McpInfo
import org.starfall.multigateway.data.model.McpProtocol
import org.starfall.multigateway.data.model.ToolDefinition
import org.starfall.multigateway.data.model.ToolSettings
import java.util.UUID
import org.starfall.multigateway.ui.components.ItemOverflowMenu
import org.starfall.multigateway.ui.components.MorphingCardLayout
import org.starfall.multigateway.ui.components.longPressReorder
import org.starfall.multigateway.ui.components.moved

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun McpScreen(
    mcpServers: List<McpInfo>,
    isGridView: Boolean = false,
    onToggleGridView: ((Boolean) -> Unit)? = null,
    toolsCache: Map<String, List<ToolDefinition>>,
    toolErrors: Map<String, String>,
    toolsLoading: Set<String>,
    toolSettings: ToolSettings,
    onSetToolEnabled: (String, String, Boolean) -> Unit,
    onSaveMcpServer: (McpInfo) -> Unit,
    onDeleteMcpServer: (String) -> Unit,
    onReorderMcpServers: (List<String>) -> Unit,
    onRefreshTools: suspend (McpInfo) -> Result<List<ToolDefinition>>,
    onBack: () -> Unit
) {
    var editingServer by remember { mutableStateOf<McpInfo?>(null) }
    var isCreatingNew by remember { mutableStateOf(false) }
    var newServerId by remember { mutableStateOf(UUID.randomUUID().toString()) }
    var deletingServerId by remember { mutableStateOf<String?>(null) }
    var selectedToolError by remember { mutableStateOf<Pair<String, String>?>(null) }
    var orderedServers by remember(mcpServers) { mutableStateOf(mcpServers) }
    val context = LocalContext.current

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(
                            text = "MCP Servers",
                            style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.SemiBold)
                        )
                        Text(
                            text = "Model Context Protocol tools",
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
                    IconButton(onClick = { onToggleGridView?.invoke(!isGridView) }) {
                        Icon(
                            imageVector = if (isGridView) Icons.Default.List else Icons.Default.GridView,
                            contentDescription = "Toggle Grid/List"
                        )
                    }
                    IconButton(onClick = {
                        newServerId = UUID.randomUUID().toString()
                        isCreatingNew = true
                    }) {
                        Icon(Icons.Default.Add, contentDescription = "Add Server")
                    }
                }
            )
        }
    ) { padding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 16.dp, vertical = 8.dp)
        ) {
            if (mcpServers.isEmpty()) {
                Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            imageVector = Icons.Outlined.Extension,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.outline,
                            modifier = Modifier.size(48.dp)
                        )
                        Spacer(Modifier.height(12.dp))
                        Text("No MCP Servers", style = MaterialTheme.typography.titleMedium)
                        Text(
                            "Tap + to connect Model Context Protocol servers",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.outline
                        )
                    }
                }
            } else {
                LazyVerticalGrid(
                    columns = GridCells.Fixed(if (isGridView) 2 else 1),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp),
                    modifier = Modifier.fillMaxSize()
                ) {
                    items(orderedServers, key = { it.id }) { server ->
                        val index = orderedServers.indexOfFirst { it.id == server.id }
                        McpUnifiedCard(
                            server = server,
                            isGrid = isGridView,
                            modifier = Modifier
                                .animateItem(
                                    placementSpec = spring(
                                        dampingRatio = Spring.DampingRatioNoBouncy,
                                        stiffness = Spring.StiffnessMediumLow
                                    )
                                )
                                .longPressReorder(
                                    index = index,
                                    itemCount = orderedServers.size,
                                    columns = if (isGridView) 2 else 1,
                                    onMove = { from, to -> orderedServers = orderedServers.moved(from, to) },
                                    onDrop = { onReorderMcpServers(orderedServers.map { it.id }) }
                                ),
                            toolCount = (toolsCache[server.id] ?: server.cachedTools)?.size,
                            toolError = toolErrors[server.id],
                            loading = server.id in toolsLoading,
                            onToolErrorClick = { error -> selectedToolError = server.name to error },
                            onEdit = { editingServer = server },
                            onDelete = { deletingServerId = server.id }
                        )
                    }
                }
            }
        }
    }

    if (editingServer != null || isCreatingNew) {
        val target = editingServer ?: McpInfo(
            id = newServerId,
            name = "",
            protocol = McpProtocol.STREAMABLE_HTTP,
            url = null,
            headers = emptyMap()
        )

        AddOrEditMcpDialog(
            initialServer = target,
            isNew = isCreatingNew,
            onRefreshTools = onRefreshTools,
            cachedTools = toolsCache[target.id] ?: target.cachedTools,
            cachedError = toolErrors[target.id],
            cachedLoading = target.id in toolsLoading,
            toolSettings = toolSettings,
            onSetToolEnabled = onSetToolEnabled,
            onDismiss = {
                editingServer = null
                isCreatingNew = false
            },
            onSave = { saved ->
                onSaveMcpServer(saved)
                editingServer = null
                isCreatingNew = false
            }
        )
    }

    if (deletingServerId != null) {
        AlertDialog(
            onDismissRequest = { deletingServerId = null },
            title = { Text("Delete MCP Server") },
            text = { Text("Are you sure you want to delete this MCP connection?") },
            confirmButton = {
                Button(
                    onClick = {
                        deletingServerId?.let(onDeleteMcpServer)
                        deletingServerId = null
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.error)
                ) { Text("Delete") }
            },
            dismissButton = {
                TextButton(onClick = { deletingServerId = null }) { Text("Cancel") }
            }
        )
    }

    selectedToolError?.let { (serverName, error) ->
        AlertDialog(
            onDismissRequest = { selectedToolError = null },
            title = { Text("Tool discovery error · $serverName") },
            text = {
                Box(
                    Modifier
                        .fillMaxWidth()
                        .heightIn(max = 420.dp)
                        .verticalScroll(rememberScrollState())
                ) {
                    SelectionContainer {
                        Text(error, style = MaterialTheme.typography.bodySmall)
                    }
                }
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                        clipboard.setPrimaryClip(ClipData.newPlainText("MCP tool discovery error", error))
                    }
                ) { Text("Copy") }
            },
            dismissButton = {
                TextButton(onClick = { selectedToolError = null }) { Text("Close") }
            }
        )
    }
}

@Composable
fun McpUnifiedCard(
    server: McpInfo,
    isGrid: Boolean,
    modifier: Modifier = Modifier,
    toolCount: Int?,
    toolError: String?,
    loading: Boolean,
    onToolErrorClick: (String) -> Unit,
    onEdit: () -> Unit,
    onDelete: () -> Unit
) {
    val shapeCorner by animateDpAsState(
        targetValue = if (isGrid) 20.dp else 16.dp,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioNoBouncy,
            stiffness = Spring.StiffnessMediumLow
        ),
        label = "mcpShapeCorner"
    )

    Surface(
        shape = RoundedCornerShape(shapeCorner),
        color = MaterialTheme.colorScheme.surfaceContainerLow,
        border = BorderStroke(1.5.dp, MaterialTheme.colorScheme.outlineVariant),
        modifier = modifier
            .fillMaxWidth()
            .clickable { onEdit() }
    ) {
        MorphingCardLayout(
            isGrid = isGrid,
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp),
            icon = {
                Box(
                    modifier = Modifier
                        .size(42.dp)
                        .clip(CircleShape)
                        .background(MaterialTheme.colorScheme.primaryContainer),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Outlined.Extension,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.size(22.dp)
                    )
                }
            },
            actions = {
                ItemOverflowMenu(
                    onEdit = onEdit,
                    onDelete = onDelete,
                    deleteColor = MaterialTheme.colorScheme.error
                )
            },
            content = {
                Column(
                    modifier = Modifier.fillMaxWidth(),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Text(
                        text = server.name,
                        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Text(
                        text = "Protocol: ${server.protocol}",
                        style = MaterialTheme.typography.bodySmall.copy(fontSize = 11.sp),
                        color = MaterialTheme.colorScheme.primary
                    )
                    Text(
                        text = server.url ?: "No endpoint",
                        style = MaterialTheme.typography.bodySmall.copy(fontSize = 11.sp),
                        color = MaterialTheme.colorScheme.outline,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    when {
                        toolError != null -> {
                            Row(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(6.dp))
                                    .background(MaterialTheme.colorScheme.errorContainer.copy(alpha = 0.5f))
                                    .clickable { onToolErrorClick(toolError) }
                                    .padding(horizontal = 6.dp, vertical = 2.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(
                                    Icons.Outlined.ErrorOutline,
                                    contentDescription = null,
                                    tint = MaterialTheme.colorScheme.error,
                                    modifier = Modifier.size(12.dp)
                                )
                                Spacer(Modifier.width(4.dp))
                                Text(
                                    "Error · Tap for details",
                                    style = MaterialTheme.typography.labelSmall.copy(fontSize = 10.sp),
                                    color = MaterialTheme.colorScheme.error
                                )
                            }
                        }
                        loading -> Text(
                            "Loading tools…",
                            style = MaterialTheme.typography.bodySmall.copy(fontSize = 11.sp),
                            color = MaterialTheme.colorScheme.primary
                        )
                        toolCount != null -> Text(
                            "$toolCount tools cached",
                            style = MaterialTheme.typography.bodySmall.copy(fontSize = 11.sp),
                            color = MaterialTheme.colorScheme.outline
                        )
                    }
                }
            }
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddOrEditMcpDialog(
    initialServer: McpInfo,
    isNew: Boolean,
    onRefreshTools: suspend (McpInfo) -> Result<List<ToolDefinition>>,
    cachedTools: List<ToolDefinition>?,
    cachedError: String?,
    cachedLoading: Boolean,
    toolSettings: ToolSettings,
    onSetToolEnabled: (String, String, Boolean) -> Unit,
    onDismiss: () -> Unit,
    onSave: (McpInfo) -> Unit
) {
    var name by remember(initialServer.id) { mutableStateOf(initialServer.name) }
    var protocol by remember(initialServer.id) { mutableStateOf(initialServer.protocol) }
    var url by remember(initialServer.id) { mutableStateOf(initialServer.url.orEmpty()) }
    var headers by remember(initialServer.id) { mutableStateOf(initialServer.headers.orEmpty().toList()) }
    var authMethod by remember(initialServer.id) { mutableStateOf(initialServer.auth.method) }
    var authKey by remember(initialServer.id) { mutableStateOf(initialServer.auth.key.orEmpty()) }
    var authValue by remember(initialServer.id) { mutableStateOf(initialServer.auth.value.orEmpty()) }
    var selectedTab by remember(initialServer.id) { mutableStateOf(0) }
    val scope = rememberCoroutineScope()

    fun currentAuth() = McpAuthorization(
        method = authMethod,
        key = if (authMethod in listOf(McpAuthMethod.CUSTOM_HEADER, McpAuthMethod.QUERY_PARAM)) authKey.trim() else null,
        value = if (authMethod == McpAuthMethod.NONE) null else authValue.trim()
    )

    fun currentServer(): McpInfo = initialServer.copy(
        name = name.trim(),
        protocol = protocol,
        url = url.trim().ifEmpty { null },
        headers = headers.map { it.first.trim() to it.second }
            .filter { it.first.isNotEmpty() }
            .toMap()
            .ifEmpty { null },
        auth = currentAuth()
    )

    val authValid = authMethod !in listOf(McpAuthMethod.CUSTOM_HEADER, McpAuthMethod.QUERY_PARAM) ||
        (authKey.isNotBlank() && !authKey.contains(':') && authKey.none { it <= ' ' || it.code >= 127 })
    val canSave = name.isNotBlank() && url.isNotBlank() && authValid && headers.all {
        it.first.isNotBlank() && !it.first.contains(':') &&
            !it.first.any { ch -> ch == '\r' || ch == '\n' } &&
            !it.second.any { ch -> ch == '\r' || ch == '\n' }
    }

    fun refreshTools() {
        if (!canSave || cachedLoading) return
        scope.launch { onRefreshTools(currentServer()) }
    }

    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(
            usePlatformDefaultWidth = false,
            decorFitsSystemWindows = false
        )
    ) {
        val view = LocalView.current
        SideEffect {
            (view.parent as? DialogWindowProvider)?.window?.let { window ->
                WindowCompat.setDecorFitsSystemWindows(window, false)
                window.statusBarColor = android.graphics.Color.TRANSPARENT
                window.navigationBarColor = android.graphics.Color.TRANSPARENT
                if (android.os.Build.VERSION.SDK_INT >= 29) {
                    window.isNavigationBarContrastEnforced = false
                    window.isStatusBarContrastEnforced = false
                }
            }
        }

        Surface(modifier = Modifier.fillMaxSize(), color = MaterialTheme.colorScheme.background) {
            Scaffold(
                topBar = {
                    TopAppBar(
                        title = {
                            Text(
                                if (isNew) "Add MCP Server" else "Configure MCP Server",
                                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold)
                            )
                        },
                        navigationIcon = {
                            IconButton(onClick = onDismiss) {
                                Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                            }
                        },
                        actions = {
                            TextButton(
                                onClick = { onSave(currentServer()) },
                                enabled = canSave
                            ) {
                                Text("Save", fontWeight = FontWeight.SemiBold)
                            }
                        }
                    )
                }
            ) { innerPadding ->
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(innerPadding)
                        .imePadding()
                ) {

                TabRow(selectedTabIndex = selectedTab) {
                    Tab(selectedTab == 0, { selectedTab = 0 }, text = { Text("Basic Settings", fontWeight = FontWeight.SemiBold) })
                    Tab(selectedTab == 1, { selectedTab = 1 }, text = { Text("Tools", fontWeight = FontWeight.SemiBold) })
                }

                if (selectedTab == 0) {
                    McpBasicSettings(
                        name = name,
                        onNameChange = { name = it },
                        protocol = protocol,
                        onProtocolChange = { protocol = it },
                        url = url,
                        onUrlChange = { url = it },
                        authMethod = authMethod,
                        onAuthMethodChange = { method ->
                            authMethod = method
                            if (method == McpAuthMethod.QUERY_PARAM && authKey.isBlank()) authKey = "key"
                        },
                        authKey = authKey,
                        onAuthKeyChange = { authKey = it },
                        authValue = authValue,
                        onAuthValueChange = { authValue = it },
                        authValid = authValid,
                        headers = headers,
                        onHeadersChange = { headers = it },
                        modifier = Modifier.weight(1f)
                    )
                } else {
                    McpToolsTab(
                        serverId = initialServer.id,
                        tools = cachedTools,
                        loading = cachedLoading,
                        error = cachedError,
                        ready = canSave,
                        toolSettings = toolSettings,
                        onSetToolEnabled = onSetToolEnabled,
                        onRefresh = ::refreshTools,
                        modifier = Modifier.weight(1f)
                    )
                }
            }
        }
    }
}
}

@Composable
private fun McpBasicSettings(
    name: String,
    onNameChange: (String) -> Unit,
    protocol: McpProtocol,
    onProtocolChange: (McpProtocol) -> Unit,
    url: String,
    onUrlChange: (String) -> Unit,
    authMethod: McpAuthMethod,
    onAuthMethodChange: (McpAuthMethod) -> Unit,
    authKey: String,
    onAuthKeyChange: (String) -> Unit,
    authValue: String,
    onAuthValueChange: (String) -> Unit,
    authValid: Boolean,
    headers: List<Pair<String, String>>,
    onHeadersChange: (List<Pair<String, String>>) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text("Display name", style = MaterialTheme.typography.titleSmall)
        OutlinedTextField(
            value = name,
            onValueChange = onNameChange,
            placeholder = { Text("Name") },
            singleLine = true,
            modifier = Modifier.fillMaxWidth()
        )

        McpDivider()
        Text("Transport Type", style = MaterialTheme.typography.titleMedium)
        Text(
            "Select the transport protocol type for the MCP server",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        McpTransportSelector(protocol, onProtocolChange)

        McpDivider()
        Text("Server URL", style = MaterialTheme.typography.titleMedium)
        Text(
            "URL address for ${if (protocol == McpProtocol.STREAMABLE_HTTP) "Streamable HTTP" else "SSE"} server",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        OutlinedTextField(
            value = url,
            onValueChange = onUrlChange,
            placeholder = { Text("URL") },
            singleLine = true,
            modifier = Modifier.fillMaxWidth()
        )
        if (url.trim().startsWith("http://", true)) {
            Text(
                "HTTP is unencrypted. Headers, credentials and tool data are visible on the network.",
                color = MaterialTheme.colorScheme.error,
                style = MaterialTheme.typography.bodySmall
            )
        }

        McpDivider()
        Text("Auth", style = MaterialTheme.typography.titleMedium)
        Text(
            "Authentication used for MCP requests",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        var authExpanded by remember { mutableStateOf(false) }
        Box {
            OutlinedButton(onClick = { authExpanded = true }) {
                Text("Type: ${mcpAuthLabel(authMethod)}")
            }
            DropdownMenu(expanded = authExpanded, onDismissRequest = { authExpanded = false }) {
                McpAuthMethod.entries.forEach { method ->
                    DropdownMenuItem(
                        text = { Text(mcpAuthLabel(method)) },
                        onClick = {
                            onAuthMethodChange(method)
                            authExpanded = false
                        }
                    )
                }
            }
        }
        if (authMethod in listOf(McpAuthMethod.CUSTOM_HEADER, McpAuthMethod.QUERY_PARAM)) {
            OutlinedTextField(
                value = authKey,
                onValueChange = onAuthKeyChange,
                label = { Text(if (authMethod == McpAuthMethod.CUSTOM_HEADER) "Header name" else "Query parameter name") },
                isError = !authValid,
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )
        }
        if (authMethod != McpAuthMethod.NONE) {
            OutlinedTextField(
                value = authValue,
                onValueChange = onAuthValueChange,
                label = {
                    Text(
                        when (authMethod) {
                            McpAuthMethod.OAUTH2 -> "OAuth2 access token"
                            McpAuthMethod.BEARER_TOKEN -> "Bearer token"
                            else -> "Value"
                        }
                    )
                },
                singleLine = true,
                visualTransformation = PasswordVisualTransformation(),
                modifier = Modifier.fillMaxWidth()
            )
        }

        McpDivider()
        Text("Custom Headers", style = MaterialTheme.typography.titleMedium)
        Text(
            "Add custom HTTP headers for MCP server requests",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        headers.forEachIndexed { index, header ->
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                OutlinedTextField(
                    value = header.first,
                    onValueChange = { value ->
                        onHeadersChange(headers.toMutableList().also { it[index] = value to header.second })
                    },
                    placeholder = { Text("Header") },
                    singleLine = true,
                    modifier = Modifier.weight(1f)
                )
                OutlinedTextField(
                    value = header.second,
                    onValueChange = { value ->
                        onHeadersChange(headers.toMutableList().also { it[index] = header.first to value })
                    },
                    placeholder = { Text("Value") },
                    singleLine = true,
                    modifier = Modifier.weight(1f)
                )
                IconButton(onClick = { onHeadersChange(headers.filterIndexed { i, _ -> i != index }) }) {
                    Icon(Icons.Outlined.Delete, contentDescription = "Remove header")
                }
            }
        }
        Button(
            onClick = { onHeadersChange(headers + ("" to "")) },
            modifier = Modifier.fillMaxWidth()
        ) {
            Icon(Icons.Default.Add, contentDescription = null)
            Spacer(Modifier.width(8.dp))
            Text("Add Header")
        }
        Spacer(Modifier.height(4.dp))
    }
}

@Composable
private fun McpToolsTab(
    serverId: String,
    tools: List<ToolDefinition>?,
    loading: Boolean,
    error: String?,
    ready: Boolean,
    toolSettings: ToolSettings,
    onSetToolEnabled: (String, String, Boolean) -> Unit,
    onRefresh: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(Modifier.weight(1f)) {
                Text("Available tools", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)
                Text(
                    if (tools == null) "No cached tool list" else "${tools.size} cached tools",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            TextButton(onClick = onRefresh, enabled = ready && !loading) {
                Text(if (loading) "Refreshing..." else "Refresh")
            }
        }

        if (loading) {
            LinearProgressIndicator(modifier = Modifier.fillMaxWidth())
        }

        if (!ready) {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text(
                    "Enter a server name and URL in Basic Settings first.",
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(24.dp)
                )
            }
            return@Column
        }

        if (error != null) {
            Text(
                text = error.lineSequence().firstOrNull().orEmpty(),
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.error,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
            )
        }

        when {
            tools == null -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text(
                    "No cached tools yet. Tap Refresh to request the tool list.",
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(24.dp)
                )
            }
            tools.isEmpty() -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text(
                    "This server reported no tools.",
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            else -> LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(horizontal = 12.dp, vertical = 4.dp),
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                items(tools, key = { it.name }) { tool ->
                    McpToolItem(
                        tool = tool,
                        enabled = toolSettings.mcpTools[serverId]?.get(tool.originalName) != false,
                        onEnabledChange = { onSetToolEnabled(serverId, tool.originalName, it) }
                    )
                }
            }
        }
    }
}

@Composable
private fun McpToolItem(
    tool: ToolDefinition,
    enabled: Boolean,
    onEnabledChange: (Boolean) -> Unit
) {
    var expanded by remember(tool.name) { mutableStateOf(false) }
    val properties = tool.schema["properties"] as? JsonObject ?: JsonObject(emptyMap())
    val required = (tool.schema["required"] as? JsonArray)
        ?.mapNotNull { (it as? JsonPrimitive)?.contentOrNull }
        ?.toSet()
        .orEmpty()

    Surface(
        shape = RoundedCornerShape(10.dp),
        color = MaterialTheme.colorScheme.surfaceContainerLow,
        modifier = Modifier
            .fillMaxWidth()
            .clickable { expanded = !expanded }
    ) {
        Column {
            ListItem(
                headlineContent = {
                    Text(tool.originalName, fontWeight = FontWeight.Medium)
                },
                supportingContent = {
                    if (tool.description.isNotBlank()) {
                        Text(
                            tool.description,
                            maxLines = if (expanded) Int.MAX_VALUE else 2,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                },
                leadingContent = {
                    Icon(Icons.Outlined.Extension, contentDescription = null)
                },
                trailingContent = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Switch(
                            checked = enabled,
                            onCheckedChange = onEnabledChange
                        )
                        Spacer(Modifier.width(6.dp))
                        Icon(
                            if (expanded) Icons.Default.KeyboardArrowDown else Icons.Default.KeyboardArrowRight,
                            contentDescription = if (expanded) "Collapse tool details" else "Expand tool details"
                        )
                    }
                }
            )

            if (expanded) {
                HorizontalDivider()
                Column(
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    if (tool.description.isNotBlank()) {
                        Text("Description", style = MaterialTheme.typography.labelLarge)
                        Text(
                            tool.description,
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }

                    Text("Parameters", style = MaterialTheme.typography.labelLarge)

                    if (properties.isEmpty()) {
                        Text(
                            "No parameters.",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    } else {
                        properties.forEach { (name, rawSchema) ->
                            val schema = rawSchema as? JsonObject ?: JsonObject(emptyMap())
                            val type = schema["type"]?.jsonPrimitive?.contentOrNull
                                ?: if (schema["enum"] is JsonArray) "enum" else "any"
                            val description = schema["description"]?.jsonPrimitive?.contentOrNull
                            val enumValues = (schema["enum"] as? JsonArray)
                                ?.joinToString(", ") { value ->
                                    (value as? JsonPrimitive)?.contentOrNull ?: value.toString()
                                }

                            Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Text(name, style = MaterialTheme.typography.bodyMedium, fontWeight = FontWeight.SemiBold)
                                    Spacer(Modifier.width(6.dp))
                                    Text(
                                        type,
                                        style = MaterialTheme.typography.labelSmall,
                                        color = MaterialTheme.colorScheme.primary
                                    )
                                    if (name in required) {
                                        Spacer(Modifier.width(6.dp))
                                        Text(
                                            "required",
                                            style = MaterialTheme.typography.labelSmall,
                                            color = MaterialTheme.colorScheme.error
                                        )
                                    }
                                }
                                if (!description.isNullOrBlank()) {
                                    Text(
                                        description,
                                        style = MaterialTheme.typography.bodySmall,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                }
                                if (!enumValues.isNullOrBlank()) {
                                    Text(
                                        "Allowed: $enumValues",
                                        style = MaterialTheme.typography.bodySmall,
                                        color = MaterialTheme.colorScheme.outline
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
@Composable
private fun McpDivider() {
    HorizontalDivider()
}

@Composable
private fun McpTransportSelector(protocol: McpProtocol, onSelect: (McpProtocol) -> Unit) {
    Row(modifier = Modifier.fillMaxWidth().height(48.dp)) {
        McpTransportOption(
            label = "Streamable HTTP",
            selected = protocol == McpProtocol.STREAMABLE_HTTP,
            shape = RoundedCornerShape(topStart = 26.dp, bottomStart = 26.dp),
            modifier = Modifier.weight(1f),
            onClick = { onSelect(McpProtocol.STREAMABLE_HTTP) }
        )
        McpTransportOption(
            label = "SSE",
            selected = protocol == McpProtocol.SSE,
            shape = RoundedCornerShape(topEnd = 26.dp, bottomEnd = 26.dp),
            modifier = Modifier.weight(1f),
            onClick = { onSelect(McpProtocol.SSE) }
        )
    }
}

@Composable
private fun McpTransportOption(
    label: String,
    selected: Boolean,
    shape: RoundedCornerShape,
    modifier: Modifier,
    onClick: () -> Unit
) {
    Surface(
        modifier = modifier.fillMaxHeight().clickable(onClick = onClick),
        shape = shape,
        color = if (selected) MaterialTheme.colorScheme.secondaryContainer else MaterialTheme.colorScheme.surface,
        border = BorderStroke(1.dp, MaterialTheme.colorScheme.outline)
    ) {
        Row(
            modifier = Modifier.fillMaxSize().padding(horizontal = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center
        ) {
            if (selected) {
                Icon(Icons.Default.Check, contentDescription = null, modifier = Modifier.size(20.dp))
                Spacer(Modifier.width(8.dp))
            }
            Text(label, fontWeight = if (selected) FontWeight.SemiBold else FontWeight.Medium)
        }
    }
}

private fun mcpAuthLabel(method: McpAuthMethod): String = when (method) {
    McpAuthMethod.NONE -> "None"
    McpAuthMethod.BEARER_TOKEN -> "Bearer token"
    McpAuthMethod.QUERY_PARAM -> "Query parameter"
    McpAuthMethod.CUSTOM_HEADER -> "Custom header"
    McpAuthMethod.OAUTH2 -> "OAuth2"
}
