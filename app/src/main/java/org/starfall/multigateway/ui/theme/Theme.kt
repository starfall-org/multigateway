package org.starfall.multigateway.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext

private val DefaultLight = lightColorScheme(
    primary = Color(0xFF0B57D0),
    onPrimary = Color.White,
    primaryContainer = Color(0xFFD3E3FD),
    onPrimaryContainer = Color(0xFF041E49),
    secondary = Color(0xFF00639B),
    onSecondary = Color.White,
    secondaryContainer = Color(0xFFC2E7FF),
    onSecondaryContainer = Color(0xFF001D33),
    surface = Color(0xFFF8F9FA),
    onSurface = Color(0xFF1F1F1F),
    surfaceVariant = Color(0xFFE1E3E1),
    onSurfaceVariant = Color(0xFF444746),
    background = Color(0xFFF8F9FA),
    onBackground = Color(0xFF1F1F1F)
)

private val DefaultDark = darkColorScheme(
    primary = Color(0xFFA8C7FA),
    onPrimary = Color(0xFF002F6C),
    primaryContainer = Color(0xFF041E49),
    onPrimaryContainer = Color(0xFFD3E3FD),
    secondary = Color(0xFF7FCFFF),
    onSecondary = Color(0xFF003355),
    secondaryContainer = Color(0xFF004B75),
    onSecondaryContainer = Color(0xFFC2E7FF),
    surface = Color(0xFF141218),
    onSurface = Color(0xFFE6E0E9),
    surfaceVariant = Color(0xFF444746),
    onSurfaceVariant = Color(0xFFC4C7C5),
    background = Color(0xFF141218),
    onBackground = Color(0xFFE6E0E9)
)

private val AmoledDark = darkColorScheme(
    primary = Color(0xFFA8C7FA),
    onPrimary = Color(0xFF002F6C),
    primaryContainer = Color(0xFF1A1A1A),
    onPrimaryContainer = Color(0xFFD3E3FD),
    secondary = Color(0xFF7FCFFF),
    onSecondary = Color(0xFF003355),
    surface = Color(0xFF000000),
    onSurface = Color(0xFFFFFFFF),
    surfaceVariant = Color(0xFF1E1E1E),
    onSurfaceVariant = Color(0xFFCCCCCC),
    background = Color(0xFF000000),
    onBackground = Color(0xFFFFFFFF)
)

// Emerald palette
private val EmeraldLight = lightColorScheme(
    primary = Color(0xFF006C4C),
    onPrimary = Color.White,
    primaryContainer = Color(0xFF89F8C7),
    onPrimaryContainer = Color(0xFF002114),
    secondary = Color(0xFF4D6356),
    onSecondary = Color.White,
    surface = Color(0xFFF6FBF6),
    onSurface = Color(0xFF181D1A),
    background = Color(0xFFF6FBF6),
    onBackground = Color(0xFF181D1A)
)

private val EmeraldDark = darkColorScheme(
    primary = Color(0xFF6CDBAC),
    onPrimary = Color(0xFF003825),
    primaryContainer = Color(0xFF005138),
    onPrimaryContainer = Color(0xFF89F8C7),
    secondary = Color(0xFFB4CCBD),
    onSecondary = Color(0xFF1F3529),
    surface = Color(0xFF0F1512),
    onSurface = Color(0xFFDFE4DF),
    background = Color(0xFF0F1512),
    onBackground = Color(0xFFDFE4DF)
)

// Sunset palette
private val SunsetLight = lightColorScheme(
    primary = Color(0xFFA04000),
    onPrimary = Color.White,
    primaryContainer = Color(0xFFFFDBCF),
    onPrimaryContainer = Color(0xFF380D00),
    secondary = Color(0xFF77574C),
    onSecondary = Color.White,
    surface = Color(0xFFFFF8F6),
    onSurface = Color(0xFF231916),
    background = Color(0xFFFFF8F6),
    onBackground = Color(0xFF231916)
)

private val SunsetDark = darkColorScheme(
    primary = Color(0xFFFFB59D),
    onPrimary = Color(0xFF5B1B00),
    primaryContainer = Color(0xFF7D2C00),
    onPrimaryContainer = Color(0xFFFFDBCF),
    secondary = Color(0xFFE7BEAF),
    onSecondary = Color(0xFF442A21),
    surface = Color(0xFF1A110E),
    onSurface = Color(0xFFF1DFD9),
    background = Color(0xFF1A110E),
    onBackground = Color(0xFFF1DFD9)
)

// Crimson palette
private val CrimsonLight = lightColorScheme(
    primary = Color(0xFFB3261E),
    onPrimary = Color.White,
    primaryContainer = Color(0xFFF9DEDC),
    onPrimaryContainer = Color(0xFF410E0B),
    secondary = Color(0xFF775656),
    onSecondary = Color.White,
    surface = Color(0xFFFFF8F7),
    onSurface = Color(0xFF201A1A),
    background = Color(0xFFFFF8F7),
    onBackground = Color(0xFF201A1A)
)

private val CrimsonDark = darkColorScheme(
    primary = Color(0xFFF2B8B5),
    onPrimary = Color(0xFF601410),
    primaryContainer = Color(0xFF8C1D18),
    onPrimaryContainer = Color(0xFFF9DEDC),
    secondary = Color(0xFFE6BDBC),
    onSecondary = Color(0xFF442929),
    surface = Color(0xFF191212),
    onSurface = Color(0xFFEDE0DF),
    background = Color(0xFF191212),
    onBackground = Color(0xFFEDE0DF)
)

// Violet palette
private val VioletLight = lightColorScheme(
    primary = Color(0xFF6B4FA0),
    onPrimary = Color.White,
    primaryContainer = Color(0xFFEBDDFF),
    onPrimaryContainer = Color(0xFF25025A),
    secondary = Color(0xFF635B70),
    onSecondary = Color.White,
    surface = Color(0xFFFEF7FF),
    onSurface = Color(0xFF1D1B20),
    background = Color(0xFFFEF7FF),
    onBackground = Color(0xFF1D1B20)
)

private val VioletDark = darkColorScheme(
    primary = Color(0xFFD4BBFF),
    onPrimary = Color(0xFF3C1D70),
    primaryContainer = Color(0xFF533687),
    onPrimaryContainer = Color(0xFFEBDDFF),
    secondary = Color(0xFFCDC2DB),
    onSecondary = Color(0xFF342D40),
    surface = Color(0xFF151218),
    onSurface = Color(0xFFE7E0E8),
    background = Color(0xFF151218),
    onBackground = Color(0xFFE7E0E8)
)

@Composable
fun MultiGatewayTheme(
    themeMode: String = "SYSTEM",
    amoledMode: Boolean = false,
    dynamicColor: Boolean = true,
    colorSchemeName: String = "DEFAULT",
    content: @Composable () -> Unit
) {
    val systemDark = isSystemInDarkTheme()
    val isDark = when (themeMode) {
        "LIGHT" -> false
        "DARK" -> true
        else -> systemDark
    }
    val isAmoled = amoledMode && isDark

    val colorScheme = when {
        isAmoled -> AmoledDark
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (isDark) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }
        colorSchemeName == "EMERALD" -> if (isDark) EmeraldDark else EmeraldLight
        colorSchemeName == "SUNSET" -> if (isDark) SunsetDark else SunsetLight
        colorSchemeName == "CRIMSON" -> if (isDark) CrimsonDark else CrimsonLight
        colorSchemeName == "VIOLET" -> if (isDark) VioletDark else VioletLight
        else -> if (isDark) DefaultDark else DefaultLight
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography(),
        content = content
    )
}
