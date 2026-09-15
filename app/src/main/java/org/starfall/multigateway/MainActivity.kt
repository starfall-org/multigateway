package org.starfall.multigateway

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.luminance
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import org.starfall.multigateway.ui.MainScreen
import org.starfall.multigateway.ui.theme.MultiGatewayTheme
import org.starfall.multigateway.ui.viewmodel.MainViewModel

class MainActivity : ComponentActivity() {

    private val viewModel: MainViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            val appPrefs by viewModel.appPreferences.collectAsStateWithLifecycle()
            MultiGatewayTheme(
                themeMode = appPrefs.themeMode,
                dynamicColor = appPrefs.useDynamicColor,
                colorSchemeName = appPrefs.colorSchemeName
            ) {
                val darkBars = MaterialTheme.colorScheme.background.luminance() < 0.5f
                SideEffect {
                    val transparent = android.graphics.Color.TRANSPARENT
                    val style = if (darkBars) SystemBarStyle.dark(transparent)
                        else SystemBarStyle.light(transparent, transparent)
                    enableEdgeToEdge(statusBarStyle = style, navigationBarStyle = style)
                    if (android.os.Build.VERSION.SDK_INT >= 29) {
                        window.isNavigationBarContrastEnforced = false
                        window.isStatusBarContrastEnforced = false
                    }
                }
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    MainScreen(viewModel = viewModel)
                }
            }
        }
    }
}
