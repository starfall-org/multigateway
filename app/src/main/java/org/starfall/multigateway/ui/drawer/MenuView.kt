package org.starfall.multigateway.ui.drawer

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForwardIos
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.starfall.multigateway.data.model.ChatProfile

@Composable
fun MenuView(
    selectedProfile: ChatProfile?,
    onNavigateToProfiles: () -> Unit,
    onEditProfile: (ChatProfile) -> Unit,
    onNavigateToProviders: () -> Unit,
    onNavigateToMcp: () -> Unit,
    onNavigateToSpeech: () -> Unit,
    onNavigateToSettings: () -> Unit,
    onNavigateToSystemTools: () -> Unit,
    onNavigateToStorage: () -> Unit,
    onCloseMenu: () -> Unit,
    modifier: Modifier = Modifier
) {
    Surface(
        modifier = modifier
            .fillMaxSize()
            .windowInsetsPadding(WindowInsets.systemBars),
        color = MaterialTheme.colorScheme.surface
    ) {
        Column(modifier = Modifier.fillMaxSize()) {
            // Header: Close icon + "Menu" title
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = onCloseMenu) {
                    Icon(
                        imageVector = Icons.Default.Close,
                        contentDescription = "Close",
                        tint = MaterialTheme.colorScheme.onSurface
                    )
                }
                Spacer(modifier = Modifier.width(4.dp))
                Text(
                    text = "Menu",
                    style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.SemiBold),
                    color = MaterialTheme.colorScheme.onSurface
                )
            }

            HorizontalDivider(
                color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.3f),
                thickness = 0.5.dp
            )

            LazyColumn(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth(),
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                item {
                    // Active Profile Section Card
                    ActiveProfileSection(
                        selectedProfile = selectedProfile,
                        onOpenProfiles = {
                            onNavigateToProfiles()
                            onCloseMenu()
                        },
                        onEditProfile = {
                            if (selectedProfile != null) {
                                onEditProfile(selectedProfile)
                                onCloseMenu()
                            }
                        }
                    )
                }

                item {
                    // Section Title: AI Features
                    Text(
                        text = "AI Features",
                        style = MaterialTheme.typography.labelLarge.copy(
                            fontWeight = FontWeight.SemiBold,
                            letterSpacing = 0.5.sp
                        ),
                        color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.7f),
                        modifier = Modifier.padding(start = 8.dp, bottom = 4.dp)
                    )
                }

                item {
                    MenuItemTile(
                        icon = Icons.Outlined.CloudQueue,
                        title = "LLM Providers",
                        subtitle = "Configure API keys & endpoints",
                        onClick = {
                            onNavigateToProviders()
                            onCloseMenu()
                        }
                    )
                }

                item {
                    MenuItemTile(
                        icon = Icons.Outlined.Extension,
                        title = "MCP Manage",
                        subtitle = "Model Context Protocol servers",
                        onClick = {
                            onNavigateToMcp()
                            onCloseMenu()
                        }
                    )
                }

                item {
                    MenuItemTile(icon = Icons.Outlined.Build, title = "Default Models", subtitle = "Image and video generation", onClick = { onNavigateToSystemTools(); onCloseMenu() })
                }
                item {
                    MenuItemTile(icon = Icons.Outlined.Storage, title = "Storage", subtitle = "Tool files, images and videos", onClick = { onNavigateToStorage(); onCloseMenu() })
                }

                item {
                    MenuItemTile(
                        icon = Icons.Outlined.RecordVoiceOver,
                        title = "Speech Services",
                        subtitle = "Text-to-speech configuration",
                        onClick = {
                            onNavigateToSpeech()
                            onCloseMenu()
                        }
                    )
                }

                item {
                    MenuItemTile(
                        icon = Icons.Outlined.Settings,
                        title = "General Settings",
                        subtitle = "Appearance, preferences & data",
                        onClick = {
                            onNavigateToSettings()
                            onCloseMenu()
                        }
                    )
                }
            }
        }
    }
}

@Composable
fun ActiveProfileSection(
    selectedProfile: ChatProfile?,
    onOpenProfiles: () -> Unit,
    onEditProfile: () -> Unit,
    modifier: Modifier = Modifier
) {
    Surface(
        shape = RoundedCornerShape(16.dp),
        color = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.2f),
        border = androidx.compose.foundation.BorderStroke(
            width = 1.dp,
            color = MaterialTheme.colorScheme.primary.copy(alpha = 0.2f)
        ),
        modifier = modifier.fillMaxWidth()
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            // Header row with ACTIVE PROFILE and Active badge
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "ACTIVE PROFILE",
                    style = MaterialTheme.typography.labelSmall.copy(
                        color = MaterialTheme.colorScheme.primary,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.2.sp
                    )
                )

                if (selectedProfile != null) {
                    Surface(
                        shape = RoundedCornerShape(12.dp),
                        color = MaterialTheme.colorScheme.primary.copy(alpha = 0.15f)
                    ) {
                        Text(
                            text = "Active",
                            style = MaterialTheme.typography.labelSmall.copy(
                                fontWeight = FontWeight.Bold,
                                fontSize = 10.sp
                            ),
                            color = MaterialTheme.colorScheme.primary,
                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 2.dp)
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(14.dp))

            // Profile info card
            Surface(
                shape = RoundedCornerShape(12.dp),
                color = MaterialTheme.colorScheme.surface,
                border = androidx.compose.foundation.BorderStroke(
                    width = 1.dp,
                    color = MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.5f)
                ),
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable(onClick = onOpenProfiles)
            ) {
                Row(
                    modifier = Modifier.padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .size(44.dp)
                            .clip(RoundedCornerShape(12.dp))
                            .background(MaterialTheme.colorScheme.surfaceContainerHigh),
                        contentAlignment = Alignment.Center
                    ) {
                        val initials = selectedProfile?.name
                            ?.split(" ")
                            ?.filter { it.isNotBlank() }
                            ?.take(2)
                            ?.map { it.first().uppercaseChar() }
                            ?.joinToString("") ?: "SG"
                        Text(
                            text = initials,
                            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                            color = MaterialTheme.colorScheme.primary
                        )
                    }

                    Spacer(modifier = Modifier.width(14.dp))

                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = selectedProfile?.name ?: "Standard Gateway",
                            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                            color = MaterialTheme.colorScheme.onSurface,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                        Text(
                            text = selectedProfile?.config?.systemPrompt?.ifBlank { "No system prompt" }
                                ?: "No system prompt",
                            style = MaterialTheme.typography.bodySmall.copy(fontSize = 11.sp),
                            color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.7f),
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }

                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.ArrowForwardIos,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.outline.copy(alpha = 0.6f),
                        modifier = Modifier.size(12.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Action buttons row: Profiles & Edit
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                OutlinedButton(
                    onClick = onOpenProfiles,
                    shape = RoundedCornerShape(8.dp),
                    contentPadding = PaddingValues(horizontal = 8.dp, vertical = 6.dp),
                    modifier = Modifier.weight(1f).height(36.dp)
                ) {
                    Icon(
                        imageVector = Icons.Outlined.GridView,
                        contentDescription = null,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text("Profiles", style = MaterialTheme.typography.labelSmall)
                }

                OutlinedButton(
                    onClick = onEditProfile,
                    shape = RoundedCornerShape(8.dp),
                    contentPadding = PaddingValues(horizontal = 8.dp, vertical = 6.dp),
                    modifier = Modifier.weight(1f).height(36.dp),
                    enabled = selectedProfile != null
                ) {
                    Icon(
                        imageVector = Icons.Outlined.Tune,
                        contentDescription = null,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text("Edit", style = MaterialTheme.typography.labelSmall)
                }
            }
        }
    }
}

@Composable
fun MenuItemTile(
    icon: ImageVector,
    title: String,
    subtitle: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Surface(
        shape = RoundedCornerShape(12.dp),
        color = MaterialTheme.colorScheme.surfaceContainerLow,
        modifier = modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
    ) {
        Row(
            modifier = Modifier.padding(14.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Surface(
                shape = RoundedCornerShape(10.dp),
                color = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.5f),
                modifier = Modifier.size(40.dp)
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Icon(
                        imageVector = icon,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.size(22.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.width(14.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
                    color = MaterialTheme.colorScheme.onSurface
                )
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.bodySmall.copy(fontSize = 11.sp),
                    color = MaterialTheme.colorScheme.outline
                )
            }

            Icon(
                imageVector = Icons.AutoMirrored.Filled.ArrowForwardIos,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.outline.copy(alpha = 0.4f),
                modifier = Modifier.size(12.dp)
            )
        }
    }
}
