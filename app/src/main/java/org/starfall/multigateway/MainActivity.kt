package org.starfall.multigateway

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.luminance
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import org.starfall.multigateway.ui.MainScreen
import org.starfall.multigateway.ui.theme.MultiGatewayTheme
import org.starfall.multigateway.ui.chat.ChatViewModel
import org.starfall.multigateway.ui.configuration.ConfigurationViewModel
import org.starfall.multigateway.ui.settings.SettingsViewModel

class MainActivity : ComponentActivity() {

    private val container get() = (application as MultiGatewayApplication).container
    private val viewModel: ChatViewModel by viewModels { container.viewModelFactory }
    private val configurationViewModel: ConfigurationViewModel by viewModels { container.viewModelFactory }
    private val settingsViewModel: SettingsViewModel by viewModels { container.viewModelFactory }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            val appPrefs by settingsViewModel.preferences.collectAsStateWithLifecycle()
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
                    MainScreen(viewModel, configurationViewModel, settingsViewModel, container.toolFiles)
                }
            }
        }
    }
}
