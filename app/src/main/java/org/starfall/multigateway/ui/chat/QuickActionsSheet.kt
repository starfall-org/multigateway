package org.starfall.multigateway.ui.chat

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import org.starfall.multigateway.data.model.*
import org.starfall.multigateway.ui.tools.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun QuickActionsSheet(onDismiss: () -> Unit) {
    val controls=LocalToolControls.current
    ModalBottomSheet(onDismissRequest=onDismiss) {
        LazyColumn(Modifier.fillMaxWidth().fillMaxHeight(0.7f),contentPadding=PaddingValues(20.dp),verticalArrangement=Arrangement.spacedBy(8.dp)) {
            item { Text("Tools",style=MaterialTheme.typography.titleLarge) }
            item { Text("System tools",style=MaterialTheme.typography.titleMedium) }
            items(listOf("generate_image","generate_video")) { name ->
                val cfg=controls.settings.system[name] ?: SystemToolConfig()
                val available = systemMediaToolAvailable(name, cfg, controls.providers)
                ToolSwitch(
                    if(name=="generate_image") "Create image" else "Create video",
                    cfg.enabled,
                    enabled = available
                ) { controls.setSystem(name,cfg.copy(enabled=it)) }
                if(!available) Text("Choose a model in System tools.",style=MaterialTheme.typography.bodySmall)
            }
            item { HorizontalDivider(); Text("MCP servers",style=MaterialTheme.typography.titleMedium) }
            if(controls.profile==null) item { Text("Select a profile and enable its MCP permissions first.") }
            items(controls.servers,key={it.id}) { server ->
                val permitted=controls.profile?.config?.mcpAccess?.get(server.id)?.enabled==true
                ToolSwitch(server.name,permitted && controls.settings.quickMcp[server.id]!=false,enabled=permitted) { controls.setMcp(server.id,it) }
                if(!permitted) Text("Disabled by profile",style=MaterialTheme.typography.bodySmall)
            }
        }
    }
}
