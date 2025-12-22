import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../sys/app_services.dart';
import '../../core/models/ai/ai_profile.dart';
import '../../core/models/ai/ai_model.dart';
import '../../core/models/mcp/mcp_server.dart';
import '../../core/models/provider.dart';

void initIcons() {
  final hasInitialized = AppServices
      .instance
      .PreferencesSp
      .currentPreferences
      .hasInitializedIcons;
  if (!hasInitialized) {
    // Run in background, don't await
    _cacheAllIcons().then((_) async {
      await AppServices.instance.PreferencesSp.setInitializedIcons(
        true,
      );
    });
  }
}

Future<void> _cacheAllIcons() async {
  try {
    String objPath = "assets/brand_icons.json";
    final String jsonString = await rootBundle.loadString(objPath);
    final List<dynamic> data = json.decode(jsonString);

    for (var item in data) {
      final List<dynamic> patterns = item['pattern'];
      for (var pattern in patterns) {
        await _cacheBrandIcon(pattern);
      }
    }
  } catch (e) {
    debugPrint("Error caching icons: $e");
  }
}

Widget buildLogoIcon(dynamic item, {double size = 24}) {
  if (item is Provider) {
    if (item.logoUrl.isNotEmpty) {
      return Image.network(
        item.logoUrl,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) => SizedBox(
          width: size,
          height: size,
          child: _buildProviderBrandLogo(item),
        ),
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: _buildProviderBrandLogo(item),
    );
  } else if (item is AIModel) {
    String? brand = _detectBrand(item.name);
    if (brand != null) {
      return SizedBox(width: size, height: size, child: buildBrandLogo(brand));
    }
    return Icon(Icons.token, size: size);
  } else if (item is MCPServer) {
    String? brand = _detectBrand(item.name);
    if (brand == null && item.httpConfig?.url != null) {
      brand = _detectBrand(item.httpConfig!.url);
    }
    if (brand != null) {
      return SizedBox(width: size, height: size, child: buildBrandLogo(brand));
    }
    return Icon(Icons.dns_outlined, size: size);
  } else if (item is AIProfile) {
    String? brand = _detectBrand(item.name);
    if (brand != null) {
      return SizedBox(width: size, height: size, child: buildBrandLogo(brand));
    }
    return Icon(Icons.token, size: size);
  }

  return SizedBox(
    width: size,
    height: size,
    child: const Icon(Icons.category_outlined),
  );
}

Widget _buildProviderBrandLogo(Provider provider) {
  String? brand = _detectBrand(provider.name);
  if (brand == null && provider.baseUrl.isNotEmpty) {
    brand = _detectBrand(provider.baseUrl);
  }
  return buildBrandLogo(brand ?? provider.name);
}

String? _detectBrand(String text) {
  final t = text.toLowerCase();
  if (t.contains('gpt') ||
      t.contains('dall-e') ||
      t.contains('whisper') ||
      t.contains('o1') ||
      t.contains('openai')) {
    return 'openai';
  } else if (t.contains('claude') || t.contains('anthropic')) {
    return 'anthropic';
  } else if (t.contains('gemini') ||
      t.contains('palm') ||
      t.contains('google') ||
      t.contains('vertex')) {
    return 'google';
  } else if (t.contains('llama') || t.contains('meta')) {
    return 'meta';
  } else if (t.contains('mistral')) {
    return 'mistral';
  } else if (t.contains('command') || t.contains('cohere')) {
    return 'cohere';
  } else if (t.contains('ollama')) {
    return 'ollama';
  } else if (t.contains('azure')) {
    return 'azureai'; // Maps to assets/brand_logos/azureai-color.png if exists, or handled by json
  }
  return null;
}

Widget buildBrandLogo(String name) {
  return FutureBuilder<File?>(
    future: _getLocalIconFile(name),
    builder: (context, snapshot) {
      if (snapshot.hasData &&
          snapshot.data != null &&
          snapshot.data!.existsSync()) {
        return Image.file(
          snapshot.data!,
          height: 24,
          width: 24,
          errorBuilder: (context, error, stackTrace) =>
              _buildAssetFallback(name),
        );
      }

      // Trigger download if not cached
      _cacheBrandIcon(name);

      return _buildAssetFallback(name);
    },
  );
}

Widget _buildAssetFallback(String name) {
  return Image.asset(
    'assets/brand_logos/fallback.png',
    height: 24,
    width: 24,
    errorBuilder: (context, error, stackTrace) {
      return const Icon(Icons.token, size: 24);
    },
  );
}

Future<File?> _getLocalIconFile(String name) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final cleanName = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    return File('${directory.path}/brand_logos/$cleanName.png');
  } catch (e) {
    return null;
  }
}

Future<void> _cacheBrandIcon(String name) async {
  try {
    final file = await _getLocalIconFile(name);
    if (file == null || await file.exists()) return;

    final url = await _findIcon(name);
    if (url != null) {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.parent.create(recursive: true);
        await file.writeAsBytes(response.bodyBytes);
      }
    }
  } catch (e) {
    debugPrint('Error caching brand icon: $e');
  }
}

Future<String?> _findIcon(String query) async {
  try {
    String objPath = "assets/brand_icons.json";
    final String jsonString = await rootBundle.loadString(objPath);
    final List<dynamic> data = json.decode(jsonString);
    final String search = query.toLowerCase();

    for (var item in data) {
      final List<dynamic> patterns = item['pattern'];
      if (patterns.any((p) => search.contains(p.toString().toLowerCase()))) {
        return item['url'] as String?;
      }
    }
  } catch (e) {
    debugPrint('Error finding icon: $e');
  }
  return null;
}
