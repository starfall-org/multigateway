package org.starfall.multigateway.data.repository

import kotlinx.serialization.json.Json

internal val json = Json {
    ignoreUnknownKeys = true
    encodeDefaults = true
}
