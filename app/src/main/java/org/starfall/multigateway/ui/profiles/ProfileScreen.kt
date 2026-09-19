package org.starfall.multigateway.ui.profiles

import org.starfall.multigateway.data.model.McpInfo
import org.starfall.multigateway.data.model.McpAccess
import org.starfall.multigateway.data.model.ToolDefinition
import org.starfall.multigateway.data.model.ToolSettings
import org.starfall.multigateway.ui.tools.ProfileMcpPermissions
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.background
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
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material.icons.outlined.Edit
import androidx.compose.material.icons.outlined.PersonOff
import androidx.compose.material.icons.outlined.Tune
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.starfall.multigateway.data.model.ChatProfile
import org.starfall.multigateway.data.model.LlmChatConfig
import java.util.UUID
import org.starfall.multigateway.ui.components.ItemOverflowMenu
import org.starfall.multigateway.ui.components.longPressReorder
import org.starfall.multigateway.ui.components.moved

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileScreen(
    profiles: List<ChatProfile>,
    mcpServers: List<McpInfo>,
    mcpToolsCache: Map<String, List<ToolDefinition>>,
    toolSettings: ToolSettings,
    selectedProfileId: String?,
    onSelectProfile: (String?) -> Unit,
    onSaveProfile: (ChatProfile) -> Unit,
    onDeleteProfile: (String) -> Unit,
    onReorderProfiles: (List<String>) -> Unit,
    onBack: () -> Unit
) {
    var isGridView by remember { mutableStateOf(false) }
    var showDialog by remember { mutableStateOf(false) }
    var editingProfile by remember { mutableStateOf<ChatProfile?>(null) }
    var deletingProfileId by remember { mutableStateOf<String?>(null) }
    var orderedProfiles by remember(profiles) { mutableStateOf(profiles) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(
                            text = "Chat Profiles",
                            style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.SemiBold)
                        )
                        Text(
                            text = "Manage chat profiles",
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
                            contentDescription = "Toggle View"
                        )
                    }
                    IconButton(
                        onClick = {
                            editingProfile = null
                            showDialog = true
                        }
                    ) {
                        Icon(Icons.Default.Add, contentDescription = "New Profile")
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
            if (isGridView) {
                LazyVerticalGrid(
                    columns = GridCells.Adaptive(minSize = 180.dp),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    items(orderedProfiles, key = { it.id }) { profile ->
                        val isSelected = profile.id == selectedProfileId
                        val index = orderedProfiles.indexOfFirst { it.id == profile.id }
                        ProfileGridCard(
                            profile = profile,
                            modifier = Modifier.longPressReorder(
                                index = index, itemCount = orderedProfiles.size, columns = 2,
                                onMove = { from, to -> orderedProfiles = orderedProfiles.moved(from, to) },
                                onDrop = { onReorderProfiles(orderedProfiles.map { it.id }) }
                            ),
                            isSelected = isSelected,
                            onSelect = { onSelectProfile(profile.id) },
                            onEdit = {
                                editingProfile = profile
                                showDialog = true
                            },
                            onDelete = { deletingProfileId = profile.id }
                        )
                    }
                }
            } else {
                LazyColumn(
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    // Option: No Profile
                    item {
                        val isNoProfileSelected = selectedProfileId == null
                        Surface(
                            shape = RoundedCornerShape(16.dp),
                            color = if (isNoProfileSelected) MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.5f)
                            else MaterialTheme.colorScheme.surfaceContainerLow,
                            border = androidx.compose.foundation.BorderStroke(
                                1.dp,
                                if (isNoProfileSelected) MaterialTheme.colorScheme.primary.copy(alpha = 0.5f)
                                else MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.5f)
                            ),
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable { onSelectProfile(null) }
                        ) {
                            Row(
                                modifier = Modifier.padding(14.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Box(
                                    modifier = Modifier
                                        .size(44.dp)
                                        .clip(CircleShape)
                                        .background(MaterialTheme.colorScheme.surfaceContainerHighest),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Icon(
                                        Icons.Outlined.PersonOff,
                                        contentDescription = null,
                                        tint = MaterialTheme.colorScheme.outline,
                                        modifier = Modifier.size(20.dp)
                                    )
                                }
                                Spacer(modifier = Modifier.width(14.dp))
                                Column(modifier = Modifier.weight(1f)) {
                                    Text(
                                        text = "Standard Gateway",
                                        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
                                        color = MaterialTheme.colorScheme.onSurface
                                    )
                                    Text(
                                        text = "Use the default system prompt",
                                        style = MaterialTheme.typography.bodySmall.copy(fontSize = 11.sp),
                                        color = MaterialTheme.colorScheme.outline
                                    )
                                }
                                if (isNoProfileSelected) {
                                    Icon(
                                        Icons.Default.Check,
                                        contentDescription = "Selected",
                                        tint = MaterialTheme.colorScheme.primary
                                    )
                                }
                            }
                        }
                    }

                    items(orderedProfiles, key = { it.id }) { profile ->
                        val isSelected = profile.id == selectedProfileId
                        val index = orderedProfiles.indexOfFirst { it.id == profile.id }
                        ProfileListCard(
                            profile = profile,
                            modifier = Modifier.longPressReorder(
                                index = index, itemCount = orderedProfiles.size, columns = 1,
                                onMove = { from, to -> orderedProfiles = orderedProfiles.moved(from, to) },
                                onDrop = { onReorderProfiles(orderedProfiles.map { it.id }) }
                            ),
                            isSelected = isSelected,
                            onSelect = { onSelectProfile(profile.id) },
                            onEdit = {
                                editingProfile = profile
                                showDialog = true
                            },
                            onDelete = { deletingProfileId = profile.id }
                        )
                    }
                }
            }
        }
    }

    if (showDialog) {
        AddOrEditProfileDialog(
            profile = editingProfile,
            mcpServers = mcpServers,
            mcpToolsCache = mcpToolsCache,
            toolSettings = toolSettings,
            onDismiss = { showDialog = false },
            onSave = {
                onSaveProfile(it)
                showDialog = false
            }
        )
    }

    if (deletingProfileId != null) {
        AlertDialog(
            onDismissRequest = { deletingProfileId = null },
            title = { Text("Delete Profile") },
            text = { Text("Are you sure you want to delete this profile?") },
            confirmButton = {
                Button(
                    onClick = {
                        deletingProfileId?.let { onDeleteProfile(it) }
                        deletingProfileId = null
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.error)
                ) {
                    Text("Delete")
                }
            },
            dismissButton = {
                TextButton(onClick = { deletingProfileId = null }) {
                    Text("Cancel")
                }
            }
        )
    }
}

@Composable
fun ProfileListCard(
    profile: ChatProfile,
    modifier: Modifier = Modifier,
    isSelected: Boolean,
    onSelect: () -> Unit,
    onEdit: () -> Unit,
    onDelete: () -> Unit
) {
    Surface(
        shape = RoundedCornerShape(16.dp),
        color = if (isSelected) MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.5f)
        else MaterialTheme.colorScheme.surfaceContainerLow,
        border = androidx.compose.foundation.BorderStroke(
            1.dp,
            if (isSelected) MaterialTheme.colorScheme.primary.copy(alpha = 0.5f)
            else MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.5f)
        ),
        modifier = modifier
            .fillMaxWidth()
            .clickable(onClick = onSelect)
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
                val initials = profile.name
                    .split(" ")
                    .filter { it.isNotBlank() }
                    .take(2)
                    .map { it.first().uppercaseChar() }
                    .joinToString("")
                Text(
                    text = initials,
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                    color = MaterialTheme.colorScheme.primary
                )
            }

            Spacer(modifier = Modifier.width(14.dp))

            Column(modifier = Modifier.weight(1f)) {
                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text(
                        text = profile.name,
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis,
                        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    if (isSelected) {
                        Spacer(modifier = Modifier.width(8.dp))
                        Surface(
                            shape = RoundedCornerShape(8.dp),
                            color = MaterialTheme.colorScheme.primary.copy(alpha = 0.2f)
                        ) {
                            Text(
                                text = "Active",
                                style = MaterialTheme.typography.labelSmall.copy(fontSize = 10.sp, fontWeight = FontWeight.Bold),
                                color = MaterialTheme.colorScheme.primary,
                                modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                            )
                        }
                    }
                }
                Text(
                    text = profile.config.systemPrompt.ifBlank { "No system prompt" },
                    style = MaterialTheme.typography.bodySmall.copy(fontSize = 11.sp),
                    color = MaterialTheme.colorScheme.outline,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )

            }

            ItemOverflowMenu(
                onEdit = onEdit,
                onDelete = onDelete,
                deleteColor = MaterialTheme.colorScheme.error
            )

        }
    }
}

@Composable
fun ProfileGridCard(
    profile: ChatProfile,
    modifier: Modifier = Modifier,
    isSelected: Boolean,
    onSelect: () -> Unit,
    onEdit: () -> Unit,
    onDelete: () -> Unit
) {
    Surface(
        shape = RoundedCornerShape(16.dp),
        color = if (isSelected) MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.5f)
        else MaterialTheme.colorScheme.surfaceContainerLow,
        border = androidx.compose.foundation.BorderStroke(
            1.dp,
            if (isSelected) MaterialTheme.colorScheme.primary.copy(alpha = 0.5f)
            else MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.5f)
        ),
        modifier = modifier
            .fillMaxWidth()
            .clickable(onClick = onSelect)
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
                    val initials = profile.name
                        .split(" ")
                        .filter { it.isNotBlank() }
                        .take(2)
                        .map { it.first().uppercaseChar() }
                        .joinToString("")
                    Text(
                        text = initials,
                        style = MaterialTheme.typography.labelMedium.copy(fontWeight = FontWeight.Bold),
                        color = MaterialTheme.colorScheme.primary
                    )
                }

                ItemOverflowMenu(
                    onEdit = onEdit,
                    onDelete = onDelete,
                    deleteColor = MaterialTheme.colorScheme.error
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = profile.name,
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )

            Text(
                text = profile.config.systemPrompt.ifBlank { "No system prompt" },
                style = MaterialTheme.typography.bodySmall.copy(fontSize = 11.sp),
                color = MaterialTheme.colorScheme.outline,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )

            if (isSelected) {
                Spacer(modifier = Modifier.height(8.dp))
                Surface(
                    shape = RoundedCornerShape(6.dp),
                    color = MaterialTheme.colorScheme.primary.copy(alpha = 0.2f)
                ) {
                    Text(
                        text = "Active",
                        style = MaterialTheme.typography.labelSmall.copy(fontSize = 10.sp, fontWeight = FontWeight.Bold),
                        color = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                    )
                }
            }
        }
    }
}

@Composable
fun AddOrEditProfileDialog(
    profile: ChatProfile?,
    mcpServers: List<McpInfo>,
    mcpToolsCache: Map<String, List<ToolDefinition>>,
    toolSettings: ToolSettings,
    onDismiss: () -> Unit,
    onSave: (ChatProfile) -> Unit
) {
    var name by remember { mutableStateOf(profile?.name ?: "") }
    var mcpAccess by remember { mutableStateOf(profile?.config?.mcpAccess ?: emptyMap<String, McpAccess>()) }
    var systemPrompt by remember { mutableStateOf(profile?.config?.systemPrompt ?: "") }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(if (profile == null) "New Profile" else "Edit Profile") },
        text = {
            Column(
                modifier = Modifier.fillMaxWidth().verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                OutlinedTextField(
                    value = name,
                    onValueChange = { name = it },
                    label = { Text("Profile Name") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )

                OutlinedTextField(
                    value = systemPrompt,
                    onValueChange = { systemPrompt = it },
                    label = { Text("System Prompt") },
                    modifier = Modifier.fillMaxWidth(),
                    minLines = 2,
                    maxLines = 4
                )
                ProfileMcpPermissions(
                    servers = mcpServers,
                    access = mcpAccess,
                    toolsCache = mcpToolsCache,
                    settings = toolSettings
                ) { mcpAccess = it }
            }
        },
        confirmButton = {
            Button(
                enabled = name.isNotBlank(),
                onClick = {
                    if (name.isNotBlank()) {
                        val newProfile = ChatProfile(
                            id = profile?.id ?: UUID.randomUUID().toString(),
                            name = name.trim(),
                            icon = profile?.icon,
                            config = LlmChatConfig(
                                systemPrompt = systemPrompt.trim(), mcpAccess = mcpAccess
                            )
                        )
                        onSave(newProfile)
                    }
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
