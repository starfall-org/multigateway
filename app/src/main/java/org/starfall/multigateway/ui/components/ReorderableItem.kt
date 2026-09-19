package org.starfall.multigateway.ui.components

import androidx.compose.foundation.gestures.detectDragGesturesAfterLongPress
import androidx.compose.ui.Modifier
import androidx.compose.ui.composed
import androidx.compose.ui.input.pointer.pointerInput
import kotlin.math.abs

fun Modifier.longPressReorder(
    index: Int,
    itemCount: Int,
    columns: Int = 1,
    onMove: (from: Int, to: Int) -> Unit,
    onDrop: () -> Unit
): Modifier = composed {
    pointerInput(index, itemCount, columns) {
        var currentIndex = index
        var accumulatedX = 0f
        var accumulatedY = 0f
        val threshold = 48f

        detectDragGesturesAfterLongPress(
            onDragStart = {
                currentIndex = index
                accumulatedX = 0f
                accumulatedY = 0f
            },
            onDragCancel = onDrop,
            onDragEnd = onDrop,
            onDrag = { change, dragAmount ->
                change.consume()
                accumulatedX += dragAmount.x
                accumulatedY += dragAmount.y

                val horizontal = abs(accumulatedX) > abs(accumulatedY)
                val delta = when {
                    horizontal && abs(accumulatedX) >= threshold ->
                        if (accumulatedX > 0) 1 else -1
                    !horizontal && abs(accumulatedY) >= threshold ->
                        if (accumulatedY > 0) columns else -columns
                    else -> 0
                }

                if (delta != 0) {
                    val target = (currentIndex + delta).coerceIn(0, itemCount - 1)
                    if (target != currentIndex) {
                        onMove(currentIndex, target)
                        currentIndex = target
                    }
                    if (horizontal) accumulatedX = 0f else accumulatedY = 0f
                }
            }
        )
    }
}

fun <T> List<T>.moved(from: Int, to: Int): List<T> {
    if (from == to || from !in indices || to !in indices) return this
    val mutable = toMutableList()
    val item = mutable.removeAt(from)
    mutable.add(to, item)
    return mutable
}
