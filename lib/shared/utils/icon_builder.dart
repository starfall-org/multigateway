import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:multigateway/app/config/services.dart';
import 'package:path_provider/path_provider.dart';

/// Widget helper để điều chỉnh màu nền icon theo theme
Widget _buildThemeAwareImage({
  required Widget child,
  required BuildContext context,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  // Trong chế độ tối: tăng độ sáng một chút để hình ảnh trắng không bị khó nhìn
  // Trong chế độ sáng: ám đen một chút để hình ảnh đen không bị khó nhìn
  return ColorFiltered(
    colorFilter: ColorFilter.mode(
      isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.1),
      BlendMode.overlay,
    ),
    child: child,
  );
}

void initIcons() {
  final hasInitialized =
      AppServices.instance.preferencesSp.currentPreferences.hasInitializedIcons;
  if (!hasInitialized) {
    // Run in background, don't await
    _cacheAllIcons().then((_) async {
      await AppServices.instance.preferencesSp.setInitializedIcons(true);
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
        return _buildThemeAwareImage(
          context: context,
          child: Image.asset(
            'assets/brand_logos/$name.png',
            width: size,
            height: size,
          ),
        );
      }

      return SizedBox(width: size, height: size, child: Icon(Icons.token));
    },
  );
}

Widget buildIcon(String name) {
  return FutureBuilder<File?>(
    future: _getLocalIconFile(name),
    builder: (context, snapshot) {
      if (snapshot.hasData &&
          snapshot.data != null &&
          snapshot.data!.existsSync()) {
        return _buildThemeAwareImage(
          context: context,
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
  return _buildThemeAwareImage(
    context: context,
    child: Image.asset(
      'assets/brand_logos/fallback.png',
      height: 24,
      width: 24,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.token, size: 24);
      },
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
