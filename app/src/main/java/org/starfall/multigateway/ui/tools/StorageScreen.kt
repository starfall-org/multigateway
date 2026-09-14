package org.starfall.multigateway.ui.tools

import android.content.Intent
import android.graphics.BitmapFactory
import android.widget.MediaController
import android.widget.VideoView
import android.widget.Toast
import androidx.activity.compose.BackHandler
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.compose.ui.window.Dialog
import androidx.core.content.FileProvider
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.starfall.multigateway.data.tools.ToolFiles
import java.io.File

private fun File.mime() = when(extension.lowercase()) { "png"->"image/png"; "jpg"->"image/jpeg"; "gif"->"image/gif"; "webp"->"image/webp"; "mp4"->"video/mp4"; "webm"->"video/webm"; "txt"->"text/plain"; else->"application/octet-stream" }
private suspend fun thumbnail(file: File, size: Int) = withContext(Dispatchers.IO) {
    runCatching {
        val bounds=BitmapFactory.Options().apply{inJustDecodeBounds=true}
        BitmapFactory.decodeFile(file.path,bounds)
        var sample=1
        while(bounds.outWidth/sample>size || bounds.outHeight/sample>size) sample*=2
        BitmapFactory.decodeFile(file.path,BitmapFactory.Options().apply{inSampleSize=sample})?.asImageBitmap()
    }.getOrNull()
}
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun StorageScreen(store: ToolFiles,onBack:()->Unit) {
    val revision by ToolFiles.revision.collectAsState()
    var files by remember { mutableStateOf<List<File>>(emptyList()) }
    var selected by remember { mutableStateOf<Set<String>>(emptySet()) }
    var confirm by remember { mutableStateOf(false) }
    val scope=rememberCoroutineScope()
    LaunchedEffect(revision){files=withContext(Dispatchers.IO){store.list()};selected=selected.intersect(files.map{it.name}.toSet())}
    BackHandler(onBack=onBack)
    Scaffold(topBar={TopAppBar(title={Text("Storage")},navigationIcon={IconButton(onClick=onBack){Icon(Icons.AutoMirrored.Filled.ArrowBack,"Back")}})}) { padding ->
        LazyColumn(Modifier.fillMaxSize().padding(padding),contentPadding=PaddingValues(16.dp),verticalArrangement=Arrangement.spacedBy(8.dp)) {
            item { Text("${files.size} files · ${android.text.format.Formatter.formatFileSize(LocalContext.current,files.sumOf{it.length()})}") }
            item { Row {
                TextButton(onClick={selected=if(selected.size==files.size) emptySet() else files.map{it.name}.toSet()}){Text(if(selected.size==files.size && files.isNotEmpty()) "Clear selection" else "Select all")}
                TextButton(enabled=selected.isNotEmpty(),onClick={confirm=true}){Text("Delete (${selected.size})")}
            } }
            if(files.isEmpty()) item { Text("No tool files stored.") }
            items(files,key={it.name}) { file ->
                Row {
                    Checkbox(checked=file.name in selected,onCheckedChange={selected=if(it) selected+file.name else selected-file.name})
                    Column(Modifier.weight(1f)) {
                        MediaFileCard(store,file.name)
                        Text(android.text.format.Formatter.formatFileSize(LocalContext.current,file.length()),style=MaterialTheme.typography.bodySmall)
                    }
                }
            }
        }
    }
    if(confirm) AlertDialog(onDismissRequest={confirm=false},title={Text("Delete ${selected.size} files?")},text={Text("Messages will remain, but these files will no longer be available in chat.")},
        confirmButton={TextButton(onClick={val ids=selected;scope.launch{withContext(Dispatchers.IO){store.delete(ids)}};selected=emptySet();confirm=false}){Text("Delete")}},
        dismissButton={TextButton(onClick={confirm=false}){Text("Cancel")}})
}

@Composable
fun MediaFileCard(store:ToolFiles,name:String) {
    val revision by ToolFiles.revision.collectAsState()
    val file=remember(name,revision){store.resolve(name)}
    var view by remember(name){mutableStateOf(false)}
    var bitmap by remember(name){mutableStateOf<androidx.compose.ui.graphics.ImageBitmap?>(null)}
    LaunchedEffect(name,revision){bitmap=if(file?.mime()?.startsWith("image/")==true) thumbnail(file,256) else null}
    Card(Modifier.fillMaxWidth().clickable(enabled=file!=null){view=true}) {
        Column(Modifier.padding(8.dp)) {
            if(file==null) Text("File deleted",style=MaterialTheme.typography.bodySmall)
            else {
                bitmap?.let{Image(it,"Generated image",Modifier.fillMaxWidth().heightIn(max=160.dp))}
                Text(if(file.mime().startsWith("video/")) "▶ View video" else if(file.extension=="txt") "View tool details" else "View ${file.extension.uppercase()} file",style=MaterialTheme.typography.labelLarge)
                Text(name,maxLines=1,style=MaterialTheme.typography.bodySmall)
            }
        }
    }
    if(view && file!=null) MediaViewer(store,file){view=false}
}

@Composable
private fun MediaViewer(store:ToolFiles,file:File,onDismiss:()->Unit) {
    val context=LocalContext.current
    val scope=rememberCoroutineScope()
    var bitmap by remember { mutableStateOf<androidx.compose.ui.graphics.ImageBitmap?>(null) }
    var details by remember { mutableStateOf("") }
    var video:VideoView? by remember { mutableStateOf(null) }
    var confirmDelete by remember { mutableStateOf(false) }
    val save=rememberLauncherForActivityResult(ActivityResultContracts.CreateDocument(file.mime())) { uri ->
        if(uri!=null) scope.launch {
            val result=withContext(Dispatchers.IO){runCatching{context.contentResolver.openOutputStream(uri)!!.use{out->file.inputStream().use{it.copyTo(out)}}}}
            Toast.makeText(context,if(result.isSuccess) "File saved" else "Could not save file",Toast.LENGTH_SHORT).show()
        }
    }
    LaunchedEffect(file.name){
        if(file.mime().startsWith("image/")) bitmap=thumbnail(file,1024)
        if(file.extension=="txt") details=withContext(Dispatchers.IO){runCatching{file.reader().use { r -> val c=CharArray(12000);val n=r.read(c);if(n>0) String(c,0,n) else "" }}.getOrDefault("File deleted")}
    }
    DisposableEffect(Unit){onDispose{video?.stopPlayback()}}
    Dialog(onDismissRequest=onDismiss) {
        Surface(shape=MaterialTheme.shapes.large) {
            Column(Modifier.fillMaxWidth().heightIn(max=620.dp).padding(12.dp)) {
                LazyColumn(Modifier.weight(1f,fill=false)) {
                    item {
                        bitmap?.let{Image(it,"Generated image",Modifier.fillMaxWidth().heightIn(max=420.dp))}
                        if(file.mime().startsWith("video/")) AndroidView(factory={ctx->VideoView(ctx).also{v->video=v;v.setVideoPath(file.path);v.setMediaController(MediaController(ctx));v.setOnPreparedListener{v.start()};v.setOnErrorListener{_,_,_->Toast.makeText(ctx,"Unable to play this video",Toast.LENGTH_SHORT).show();true}}},modifier=Modifier.fillMaxWidth().height(320.dp))
                        if(details.isNotEmpty()) Text(details,style=MaterialTheme.typography.bodySmall)
                    }
                }
                Row {
                    TextButton(onClick={save.launch(file.name)}){Text("Save")}
                    TextButton(onClick={
                        runCatching {
                            val uri=FileProvider.getUriForFile(context,"${context.packageName}.tool-files",file)
                            context.startActivity(Intent.createChooser(Intent(Intent.ACTION_SEND).setType(file.mime()).putExtra(Intent.EXTRA_STREAM,uri).addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION),"Share file"))
                        }.onFailure{Toast.makeText(context,"Could not share file",Toast.LENGTH_SHORT).show()}
                    }){Text("Share")}
                    TextButton(onClick={confirmDelete=true}){Text("Delete")}
                }
                TextButton(onClick=onDismiss){Text("Close")}
            }
        }
    }
    if(confirmDelete) AlertDialog(onDismissRequest={confirmDelete=false},title={Text("Delete file?")},text={Text("This file will no longer be available in chat.")},
        confirmButton={TextButton(onClick={video?.stopPlayback();scope.launch{withContext(Dispatchers.IO){store.delete(listOf(file.name))};onDismiss()};confirmDelete=false}){Text("Delete")}},
        dismissButton={TextButton(onClick={confirmDelete=false}){Text("Cancel")}})
}
