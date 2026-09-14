package org.starfall.multigateway.ui.chat

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.outlined.SmartToy
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.starfall.multigateway.data.model.ChatProfile
import org.starfall.multigateway.data.model.Conversation

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChatAppBar(
    currentSession: Conversation?,
    selectedProfile: ChatProfile?,
    onOpenDrawer: () -> Unit,
    onOpenEndDrawer: () -> Unit,
    modifier: Modifier = Modifier
) {
    TopAppBar(
        title = {
            Column(
                modifier = Modifier.fillMaxWidth().padding(end = 8.dp),
                verticalArrangement = Arrangement.Center
            ) {
                Text(
                    text = currentSession?.title ?: "New Chat",
                    style = MaterialTheme.typography.titleMedium.copy(
                        fontWeight = FontWeight.SemiBold,
                        fontSize = 16.sp
                    ),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = selectedProfile?.name ?: "No Profile",
                    style = MaterialTheme.typography.bodySmall.copy(
                        fontWeight = FontWeight.Normal,
                        fontSize = 12.sp
                    ),
                    color = MaterialTheme.colorScheme.primary,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        },
        navigationIcon = {
            IconButton(onClick = onOpenDrawer) {
                Icon(
                    imageVector = Icons.Default.Menu,
                    contentDescription = "Open Conversations Drawer",
                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        },
        actions = {
            Box(
                modifier = Modifier
                    .padding(end = 12.dp)
                    .size(48.dp)
                    .clip(CircleShape)
                    .background(MaterialTheme.colorScheme.primaryContainer)
                    .clickable(onClick = onOpenEndDrawer),
                contentAlignment = Alignment.Center
            ) {
                val initials = selectedProfile?.name
                    ?.split(" ")
                    ?.filter { it.isNotBlank() }
                    ?.take(2)
                    ?.map { it.first().uppercaseChar() }
                    ?.joinToString("") ?: ""

                if (initials.isNotEmpty()) {
                    Text(
                        text = initials,
                        style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold),
                        color = MaterialTheme.colorScheme.onPrimaryContainer
                    )
                } else {
                    Icon(
                        imageVector = Icons.Outlined.SmartToy,
                        contentDescription = "Profile",
                        tint = MaterialTheme.colorScheme.onPrimaryContainer,
                        modifier = Modifier.size(18.dp)
                    )
                }
            }
        },
        colors = TopAppBarDefaults.topAppBarColors(
            containerColor = MaterialTheme.colorScheme.surface
        ),
        modifier = modifier
    )
}
