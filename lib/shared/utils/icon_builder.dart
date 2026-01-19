import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:multigateway/app/storage/preferences_storage.dart';
import 'package:multigateway/shared/utils/theme_aware_image.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initIcons() async {
  final preferencesSp = await PreferencesStorage.instance;
  final hasInitialized = preferencesSp.currentPreferences.hasInitializedIcons;
  if (!hasInitialized) {
    // Run in background, don't await
    _cacheAllIcons().then((_) async {
      await (await PreferencesStorage.instance).setInitializedIcons(true);
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
        _cacheNetworkIcon(pattern);
      }
    }
  } catch (e) {
    debugPrint("Error caching icons: $e");
  }
}

Widget buildLogoIcon(String name, {double size = 24}) {
  return Builder(
    builder: (context) {
      if (name.isNotEmpty) {
        return ThemeAwareImage(
          child: Image.asset(
            'assets/brand_logos/$name.png',
            width: size,
            height: size,
            errorBuilder: (context, error, stackTrace) {
              return _buildLetterPlaceholderSized(name, context, size);
            },
          ),
        );
      }

      return _buildLetterPlaceholderSized(name, context, size);
    },
  );
}

Widget _buildLetterPlaceholderSized(
  String name,
  BuildContext context,
  double size,
) {
  final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: BoxShape.circle,
    ),
    alignment: Alignment.center,
    child: Text(
      letter,
      style: TextStyle(
        fontSize: size * 0.6,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    ),
  );
}

Widget buildIcon(String name) {
  return FutureBuilder<File?>(
    future: _getLocalIconFile(name),
    builder: (context, snapshot) {
      if (snapshot.hasData &&
      snapshot.data != null &&
      snapshot.data!.existsSync()) {
        return ThemeAwareImage(
          child: Image.file(
            snapshot.data!,
            height: 24,
            width: 24,
            errorBuilder: (context, error, stackTrace) =>
                _buildAssetFallback(name, context),
          ),
        );
      }

      // Trigger download if not cached
      _cacheNetworkIcon(name);

      return _buildAssetFallback(name, context);
    },
  );
}

Widget _buildAssetFallback(String name, BuildContext context) {
  return ThemeAwareImage(
    child: Image.asset(
      'assets/brand_logos/fallback.png',
      height: 24,
      width: 24,
      errorBuilder: (context, error, stackTrace) {
        return _buildLetterPlaceholder(name, context);
      },
    ),
  );
}

Widget _buildLetterPlaceholder(String name, BuildContext context) {
  final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
  return Container(
    width: 24,
    height: 24,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: BoxShape.circle,
    ),
    alignment: Alignment.center,
    child: Text(
      letter,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    ),
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

Future<void> _cacheNetworkIcon(String name) async {
  try {
    final file = await _getLocalIconFile(name);
    if (file == null || await file.exists()) return;

    final url = await _findIconUrl(name);
    if (url == null) return;

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await file.parent.create(recursive: true);
      await file.writeAsBytes(response.bodyBytes);
    }
  } catch (e) {
    debugPrint('Error caching brand icon: $e');
  }
}

Future<String?> _findIconUrl(String query) async {
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
