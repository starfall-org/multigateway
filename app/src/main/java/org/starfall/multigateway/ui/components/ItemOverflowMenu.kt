package org.starfall.multigateway.ui.components

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.outlined.Delete
import androidx.compose.material.icons.outlined.Edit
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.graphics.Color

@Composable
fun ItemOverflowMenu(
    onEdit: () -> Unit,
    onDelete: () -> Unit,
    deleteColor: Color
) {
    var expanded by remember { mutableStateOf(false) }

    IconButton(onClick = { expanded = true }) {
        Icon(Icons.Default.MoreVert, contentDescription = "More options")
    }

    DropdownMenu(
        expanded = expanded,
        onDismissRequest = { expanded = false }
    ) {
        DropdownMenuItem(
            text = { Text("Edit") },
            leadingIcon = { Icon(Icons.Outlined.Edit, contentDescription = null) },
            onClick = {
                expanded = false
                onEdit()
            }
        )
        DropdownMenuItem(
            text = { Text("Delete", color = deleteColor) },
            leadingIcon = {
                Icon(
                    Icons.Outlined.Delete,
                    contentDescription = null,
                    tint = deleteColor
                )
            },
            onClick = {
                expanded = false
                onDelete()
            }
        )
    }
}
