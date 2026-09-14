package org.starfall.multigateway.ui.chat

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import org.starfall.multigateway.data.model.ToolActivity
import org.starfall.multigateway.data.tools.ToolFiles
import org.starfall.multigateway.ui.tools.MediaFileCard

@Composable
fun ToolActivityCards(activities:List<ToolActivity>) {
    val context=LocalContext.current
    val store=remember{ToolFiles(context)}
    activities.forEach { activity ->
        key(activity.id) {
            var expanded by remember{mutableStateOf(false)}
            Card(Modifier.fillMaxWidth().padding(vertical=4.dp)) {
                Column(Modifier.padding(12.dp)) {
                    Row {
                        if(activity.status=="running") {CircularProgressIndicator(Modifier.size(16.dp),strokeWidth=2.dp);Spacer(Modifier.width(8.dp))}
                        Text(activity.name,Modifier.weight(1f),style=MaterialTheme.typography.labelLarge,maxLines=2)
                        Text(activity.status,style=MaterialTheme.typography.labelSmall)
                    }
                    if(activity.summary.isNotEmpty() || activity.files.isNotEmpty()) {
                        TextButton(onClick={expanded=!expanded}){Text(if(expanded) "Hide details" else "Details")}
                    }
                    if(expanded) {
                        Text(activity.summary.take(500),style=MaterialTheme.typography.bodySmall)
                        activity.files.filter{it.endsWith(".txt")}.take(1).forEach{MediaFileCard(store,it)}
                    }
                    activity.files.filter{!it.endsWith(".txt")}.take(2).forEach{MediaFileCard(store,it)}
                    if(activity.files.count{!it.endsWith(".txt")}>2) Text("More files are available in Storage.",style=MaterialTheme.typography.bodySmall)
                }
            }
        }
    }
}
