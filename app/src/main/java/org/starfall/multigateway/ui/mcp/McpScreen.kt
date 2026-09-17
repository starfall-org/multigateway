package org.starfall.multigateway.ui.mcp

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
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.GridView
import androidx.compose.material.icons.filled.List
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material.icons.outlined.Edit
import androidx.compose.material.icons.outlined.Extension
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.launch
import org.starfall.multigateway.data.model.McpInfo
import org.starfall.multigateway.data.model.McpProtocol
import org.starfall.multigateway.data.model.ToolDefinition
import java.util.UUID

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun McpScreen(
    mcpServers: List<McpInfo>,
    onSaveMcpServer: (McpInfo) -> Unit,
    onDeleteMcpServer: (String) -> Unit,
    onDiscoverTools: suspend (McpInfo) -> List<ToolDefinition>,
    onBack: () -> Unit
) {
    var editingServer by remember { mutableStateOf<McpInfo?>(null) }
    var isCreatingNew by remember { mutableStateOf(false) }
    var deletingServerId by remember { mutableStateOf<String?>(null) }
    var isGridView by remember { mutableStateOf(false) }

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
                    IconButton(onClick = { isGridView = !isGridView }) {
                        Icon(
                            imageVector = if (isGridView) Icons.Default.List else Icons.Default.GridView,
                            contentDescription = "Toggle Grid/List"
                        )
                    }
                    IconButton(onClick = { isCreatingNew = true }) {
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
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            imageVector = Icons.Outlined.Extension,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.outline,
                            modifier = Modifier.size(48.dp)
                        )
                        Spacer(modifier = Modifier.height(12.dp))
                        Text(
                            text = "No MCP Servers",
                            style = MaterialTheme.typography.titleMedium,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                        Text(
                            text = "Tap + to connect Model Context Protocol servers",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.outline
                        )
                    }
                }
            } else if (isGridView) {
                LazyVerticalGrid(
                    columns = GridCells.Fixed(2),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    items(mcpServers, key = { it.id }) { server ->
                        McpGridCard(
                            server = server,
                            onEdit = { editingServer = server },
                            onDelete = { deletingServerId = server.id }
                        )
                    }
                }
            } else {
                LazyColumn(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    items(mcpServers, key = { it.id }) { server ->
                        McpListCard(
                            server = server,
                            onEdit = { editingServer = server },
                            onDelete = { deletingServerId = server.id }
                        )
                    }
                }
            }
        }
    if (editingServer != null || isCreatingNew) {
        val target = editingServer ?: McpInfo(
            id = UUID.randomUUID().toString(),
            name = "",
            protocol = McpProtocol.STREAMABLE_HTTP,
            url = null,
            headers = emptyMap()
        )

        AddOrEditMcpDialog(
            initialServer = target,
            isNew = isCreatingNew,
            onDiscoverTools = onDiscoverTools,
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
                        deletingServerId?.let { onDeleteMcpServer(it) }
                        deletingServerId = null
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.error)
                ) {
                    Text("Delete")
                }
            },
            dismissButton = {
                TextButton(onClick = { deletingServerId = null }) {
                    Text("Cancel")
                }
            }
        )
    }
}
}

@Composable
fun McpListCard(
    server: McpInfo,
    onEdit: () -> Unit,
    onDelete: () -> Unit
) {
    Surface(
        shape = RoundedCornerShape(16.dp),
        color = MaterialTheme.colorScheme.surfaceContainerLow,
        border = androidx.compose.foundation.BorderStroke(1.dp, MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.5f)),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier.padding(14.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(44.dp)
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

            Spacer(modifier = Modifier.width(14.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = server.name,
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
                    color = MaterialTheme.colorScheme.onSurface
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
            }

            Row {
                IconButton(onClick = onEdit, modifier = Modifier.size(36.dp)) {
                    Icon(Icons.Outlined.Edit, contentDescription = "Edit", modifier = Modifier.size(18.dp))
                }
                IconButton(onClick = onDelete, modifier = Modifier.size(36.dp)) {
                    Icon(Icons.Outlined.Delete, contentDescription = "Delete", tint = MaterialTheme.colorScheme.error, modifier = Modifier.size(18.dp))
                }
            }
        }
    }
}

@Composable
fun McpGridCard(
    server: McpInfo,
    onEdit: () -> Unit,
    onDelete: () -> Unit
) {
    Surface(
        shape = RoundedCornerShape(16.dp),
        color = MaterialTheme.colorScheme.surfaceContainerLow,
        border = androidx.compose.foundation.BorderStroke(1.dp, MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.5f)),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(36.dp)
                        .clip(CircleShape)
                        .background(MaterialTheme.colorScheme.primaryContainer),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Outlined.Extension,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.size(20.dp)
                    )
                }
                Row {
                    IconButton(onClick = onEdit, modifier = Modifier.size(28.dp)) {
                        Icon(Icons.Outlined.Edit, contentDescription = "Edit", modifier = Modifier.size(16.dp))
                    }
                    IconButton(onClick = onDelete, modifier = Modifier.size(28.dp)) {
                        Icon(Icons.Outlined.Delete, contentDescription = "Delete", tint = MaterialTheme.colorScheme.error, modifier = Modifier.size(16.dp))
                    }
                }
            }

            Spacer(modifier = Modifier.height(10.dp))

            Text(
                text = server.name,
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )

            Text(
                text = server.protocol.name,
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.primary
            )

            Text(
                text = server.url ?: "No endpoint",
                style = MaterialTheme.typography.bodySmall.copy(fontSize = 11.sp),
                color = MaterialTheme.colorScheme.outline,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddOrEditMcpDialog(
    initialServer: McpInfo,
    isNew: Boolean,
    onDiscoverTools: suspend (McpInfo) -> List<ToolDefinition>,
    onDismiss: () -> Unit,
    onSave: (McpInfo) -> Unit
) {
    var name by remember(initialServer.id) { mutableStateOf(initialServer.name) }
    var protocol by remember(initialServer.id) { mutableStateOf(initialServer.protocol) }
    var url by remember(initialServer.id) { mutableStateOf(initialServer.url.orEmpty()) }
    var headers by remember(initialServer.id) { mutableStateOf(initialServer.headers.orEmpty().toList()) }
    var selectedTab by remember(initialServer.id) { mutableStateOf(0) }
    var tools by remember(initialServer.id) { mutableStateOf<List<ToolDefinition>?>(null) }
    var toolsLoading by remember(initialServer.id) { mutableStateOf(false) }
    var toolsError by remember(initialServer.id) { mutableStateOf<String?>(null) }
    var toolRefresh by remember(initialServer.id) { mutableIntStateOf(0) }

    fun currentServer(): McpInfo = initialServer.copy(
        name = name.trim(), protocol = protocol, url = url.trim().ifEmpty { null },
        headers = headers.map { it.first.trim() to it.second }.filter { it.first.isNotEmpty() }.toMap().ifEmpty { null }
    )
    val canSave = name.isNotBlank() && url.isNotBlank() && headers.all {
        it.first.isNotBlank() && !it.first.contains(':') && !it.first.any { ch -> ch == '\r' || ch == '\n' } &&
            !it.second.any { ch -> ch == '\r' || ch == '\n' }
    }

    LaunchedEffect(selectedTab, toolRefresh) {
        if (selectedTab != 1) return@LaunchedEffect
        if (!canSave) { tools = null; toolsError = null; toolsLoading = false; return@LaunchedEffect }
        toolsLoading = true; toolsError = null
        try { tools = onDiscoverTools(currentServer()) }
        catch (e: CancellationException) { throw e }
        catch (e: Exception) { tools = null; toolsError = e.localizedMessage ?: "Unable to load tools" }
        finally { toolsLoading = false }
    }

    Dialog(onDismissRequest = onDismiss, properties = DialogProperties(usePlatformDefaultWidth = false)) {
        Surface(modifier = Modifier.fillMaxSize(), color = MaterialTheme.colorScheme.background) {
            Column(Modifier.fillMaxSize().systemBarsPadding().imePadding()) {
                Row(Modifier.fillMaxWidth().padding(horizontal = 12.dp, vertical = 8.dp), verticalAlignment = Alignment.CenterVertically) {
                    IconButton(onClick = onDismiss) { Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back") }
                    Text(if (isNew) "Add MCP Server" else "Configure MCP Server",
                        style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.SemiBold), modifier = Modifier.weight(1f))
                }
                TabRow(selectedTabIndex = selectedTab) {
                    Tab(selectedTab == 0, { selectedTab = 0 }, text = { Text("Basic Settings", fontWeight = FontWeight.SemiBold) })
                    Tab(selectedTab == 1, { selectedTab = 1 }, text = { Text("Tools", fontWeight = FontWeight.SemiBold) })
                }
                if (selectedTab == 0) {
                    McpBasicSettings(
                        name, { name = it }, protocol, { protocol = it }, url, { url = it }, headers, { headers = it },
                        modifier = Modifier.weight(1f)
                    )
                } else {
                    McpToolsTab(
                        tools, toolsLoading, toolsError, canSave, { toolRefresh++ },
                        modifier = Modifier.weight(1f)
                    )
                }
                Row(
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 20.dp, vertical = 12.dp),
                    horizontalArrangement = Arrangement.End,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    TextButton(onClick = { onSave(currentServer()) }, enabled = canSave) {
                        Text("Save", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)
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
    headers: List<Pair<String, String>>,
    onHeadersChange: (List<Pair<String, String>>) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier.verticalScroll(rememberScrollState()).padding(horizontal = 20.dp),
        verticalArrangement = Arrangement.spacedBy(0.dp)
    ) {
        Spacer(Modifier.height(28.dp))
        Text("Display name for the MCP server", style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant)
        Spacer(Modifier.height(12.dp))
        OutlinedTextField(
            value = name, onValueChange = onNameChange, placeholder = { Text("Name") }, singleLine = true,
            modifier = Modifier.fillMaxWidth().heightIn(min = 64.dp), shape = RoundedCornerShape(10.dp)
        )

        McpDivider()
        Text("Transport Type", style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.SemiBold))
        Spacer(Modifier.height(6.dp))
        Text("Select the transport protocol type for the MCP server", style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant)
        Spacer(Modifier.height(14.dp))
        McpTransportSelector(protocol, onProtocolChange)

        McpDivider()
        Text("Server URL", style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.SemiBold))
        Spacer(Modifier.height(6.dp))
        Text("URL address for ${if (protocol == McpProtocol.STREAMABLE_HTTP) "Streamable HTTP" else "SSE"} server",
            style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
        Spacer(Modifier.height(14.dp))
        OutlinedTextField(
            value = url, onValueChange = onUrlChange, placeholder = { Text("URL") }, singleLine = true,
            modifier = Modifier.fillMaxWidth().heightIn(min = 64.dp), shape = RoundedCornerShape(10.dp)
        )
        if (url.trim().startsWith("http://", true)) {
            Spacer(Modifier.height(6.dp))
            Text("HTTP is unencrypted. Headers, credentials and tool data are visible on the network.",
                color = MaterialTheme.colorScheme.error, style = MaterialTheme.typography.bodySmall)
        }

        McpDivider()
        Text("Custom Headers", style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.SemiBold))
        Spacer(Modifier.height(6.dp))
        Text("Add custom HTTP headers for MCP server requests", style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant)
        Spacer(Modifier.height(12.dp))

        headers.forEachIndexed { index, header ->
            Row(
                modifier = Modifier.fillMaxWidth().padding(bottom = 10.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                OutlinedTextField(
                    value = header.first,
                    onValueChange = { value -> onHeadersChange(headers.toMutableList().also { it[index] = value to header.second }) },
                    placeholder = { Text("Header") }, singleLine = true, modifier = Modifier.weight(1f)
                )
                OutlinedTextField(
                    value = header.second,
                    onValueChange = { value -> onHeadersChange(headers.toMutableList().also { it[index] = header.first to value }) },
                    placeholder = { Text("Value") }, singleLine = true, modifier = Modifier.weight(1f)
                )
                IconButton(onClick = { onHeadersChange(headers.filterIndexed { i, _ -> i != index }) }) {
                    Icon(Icons.Outlined.Delete, contentDescription = "Remove header")
                }
            }
        }

        Button(
            onClick = { onHeadersChange(headers + ("" to "")) },
            modifier = Modifier.fillMaxWidth().height(56.dp),
            shape = RoundedCornerShape(28.dp)
        ) {
            Icon(Icons.Default.Add, contentDescription = null)
            Spacer(Modifier.width(8.dp))
            Text("Add Header", style = MaterialTheme.typography.titleMedium)
        }
        Spacer(Modifier.height(24.dp))
    }
}

@Composable
private fun McpToolsTab(
    tools: List<ToolDefinition>?,
    loading: Boolean,
    error: String?,
    ready: Boolean,
    onRefresh: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier.fillMaxWidth()) {
    Column(modifier = Modifier.weight(1f).fillMaxWidth()) {
        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 20.dp, vertical = 16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(Modifier.weight(1f)) {
                Text("Available tools", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.SemiBold)
                Text("Tools exposed by this MCP server", style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            TextButton(onClick = onRefresh, enabled = ready && !loading) { Text("Refresh") }
        }
        when {
            !ready -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text("Enter a server name and URL in Basic Settings first.",
                    color = MaterialTheme.colorScheme.onSurfaceVariant, modifier = Modifier.padding(24.dp))
            }
            loading -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) { CircularProgressIndicator() }
            error != null -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.padding(24.dp)) {
                    Text(error, color = MaterialTheme.colorScheme.error)
                    Spacer(Modifier.height(8.dp))
                    TextButton(onClick = onRefresh) { Text("Retry") }
                }
            }
            tools.isNullOrEmpty() -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text("No tools reported by this server.", color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            else -> LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(horizontal = 12.dp, vertical = 4.dp)
            ) {
                items(tools, key = { it.name }) { tool ->
                    ListItem(
                        headlineContent = { Text(tool.name, fontWeight = FontWeight.Medium) },
                        supportingContent = {
                            if (tool.description.isNotBlank()) Text(tool.description, maxLines = 3, overflow = TextOverflow.Ellipsis)
                        },
                        leadingContent = { Icon(Icons.Outlined.Extension, contentDescription = null) }
                    )
                    HorizontalDivider()
                }
            }
        }
    }
    }
}

@Composable
private fun McpDivider() {
    HorizontalDivider(modifier = Modifier.padding(vertical = 20.dp))
}

@Composable
private fun McpTransportSelector(protocol: McpProtocol, onSelect: (McpProtocol) -> Unit) {
    Row(modifier = Modifier.fillMaxWidth().height(52.dp)) {
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
