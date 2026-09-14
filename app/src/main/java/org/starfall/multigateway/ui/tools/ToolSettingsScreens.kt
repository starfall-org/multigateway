package org.starfall.multigateway.ui.tools

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.launch
import org.starfall.multigateway.data.model.*

@Composable
fun ToolSwitch(label: String, checked: Boolean, enabled: Boolean = true, onChange: (Boolean) -> Unit) {
    Row(Modifier.fillMaxWidth().heightIn(min=48.dp),verticalAlignment=Alignment.CenterVertically) {
        Text(label,Modifier.weight(1f).padding(end=8.dp))
        Switch(checked=checked,onCheckedChange=onChange,enabled=enabled)
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SystemToolsScreen(providers: List<LlmProviderInfo>, settings: ToolSettings, onSave: (String,SystemToolConfig)->Unit, onBack:()->Unit) {
    var choosing by remember { mutableStateOf<String?>(null) }
    BackHandler(onBack=onBack)
    Scaffold(topBar={ TopAppBar(title={Text("System tools")},navigationIcon={IconButton(onClick=onBack){Icon(Icons.AutoMirrored.Filled.ArrowBack,"Back")}}) }) { padding ->
        LazyColumn(Modifier.fillMaxSize().padding(padding),contentPadding=PaddingValues(16.dp),verticalArrangement=Arrangement.spacedBy(16.dp)) {
            items(listOf("generate_image","generate_video")) { name ->
                val config=settings.system[name] ?: SystemToolConfig()
                val provider=providers.find { it.id==config.providerId }
                val model=provider?.config?.modelConfigs?.get(config.modelId)
                Card(Modifier.fillMaxWidth()) { Column(Modifier.padding(16.dp)) {
                    ToolSwitch(if(name=="generate_image") "Create image" else "Create video",config.enabled) { onSave(name,config.copy(enabled=it)) }
                    Text(if(model==null) "Select a model" else "${provider.name} / ${model.displayName.ifBlank { config.modelId }}",style=MaterialTheme.typography.bodyMedium)
                    TextButton(onClick={choosing=name}) { Text("Choose model") }
                } }
            }
        }
    }
    choosing?.let { name ->
        val type=if(name=="generate_image") ModelType.IMAGE_GENERATION else ModelType.VIDEO_GENERATION
        val choices=providers.flatMap { p -> p.config.modelConfigs.filter { (id,c) -> c.modelType==type && p.config.modelIds?.contains(id)!=false }.map { (id,c) -> Triple(p,id,c) } }
        ModalBottomSheet(onDismissRequest={choosing=null}) {
            LazyColumn(Modifier.fillMaxWidth().fillMaxHeight(0.75f),contentPadding=PaddingValues(16.dp)) {
                item { Text("Choose ${type.displayName}",style=MaterialTheme.typography.titleLarge) }
                if(choices.isEmpty()) item { Text("Add a model with this type in LLM Providers first.") }
                items(choices) { (p,id,c) ->
                    val supported=p.type==ProviderType.OPENAI || p.type==ProviderType.GOOGLE
                    TextButton(enabled=supported,onClick={onSave(name,(settings.system[name]?:SystemToolConfig()).copy(providerId=p.id,modelId=id));choosing=null}) {
                        Text("${p.name} / ${c.displayName.ifBlank { id }}${if(!supported) " (media API unsupported)" else ""}")
                    }
                }
            }
        }
    }
}

@Composable
fun ProfileMcpPermissions(servers: List<McpInfo>, access: Map<String,McpAccess>, discover: suspend (McpInfo)->List<ToolDefinition>, onChange:(Map<String,McpAccess>)->Unit) {
    val scope=rememberCoroutineScope()
    val catalogs=remember { mutableStateMapOf<String,List<ToolDefinition>>() }
    val errors=remember { mutableStateMapOf<String,String>() }
    val loading=remember { mutableStateMapOf<String,Boolean>() }
    Text("MCP permissions",style=MaterialTheme.typography.titleMedium)
    if(servers.isEmpty()) Text("Add servers in MCP Manage first.")
    servers.forEach { server ->
        val policy=access[server.id] ?: McpAccess()
        HorizontalDivider()
        ToolSwitch(server.name,policy.enabled) { onChange(access+(server.id to policy.copy(enabled=it))) }
        if(policy.enabled) {
            TextButton(enabled=loading[server.id]!=true,onClick={
                scope.launch {
                    loading[server.id]=true; errors.remove(server.id)
                    try { catalogs[server.id]=discover(server) }
                    catch(e:CancellationException){throw e}
                    catch(e:Exception){errors[server.id]=e.message.orEmpty().take(300)}
                    finally{loading[server.id]=false}
                }
            }) { Text(if(loading[server.id]==true) "Loading tools…" else "Load / refresh tools") }
            errors[server.id]?.let { Text(it,color=MaterialTheme.colorScheme.error) }
            catalogs[server.id]?.let { tools ->
                if(tools.isEmpty()) Text("No tools available.")
                tools.forEach { tool ->
                    ToolSwitch(tool.originalName,policy.tools[tool.originalName]!=false) {
                        onChange(access+(server.id to policy.copy(tools=policy.tools+(tool.originalName to it))))
                    }
                }
            }
        }
    }
}
