import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:multigateway/shared/utils/app_version.dart';
import 'package:signals/signals.dart';

const _githubRepo = 'starfall-org/multigateway';
const _releasesEndpoint = 'https://api.github.com/repos/$_githubRepo/releases';
const _releasesPage = 'https://github.com/$_githubRepo/releases';

class ReleaseInfo {
  final String version;
  final String name;
  final String body;
  final DateTime? publishedAt;
  final Uri htmlUrl;
  final List<ReleaseAsset> assets;

  const ReleaseInfo({
    required this.version,
    required this.name,
    required this.body,
    required this.publishedAt,
    required this.htmlUrl,
    required this.assets,
  });

  List<String> get highlights {
    final lines = body
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) {
      if (line.startsWith('- ')) return line.substring(2).trim();
      if (line.startsWith('* ')) return line.substring(2).trim();
      return line;
    }).toList();

    if (lines.isEmpty) return const ['No release notes provided'];
    return lines.take(6).toList();
  }

  Uri? get primaryAssetUrl {
    for (final asset in assets) {
      if (asset.downloadUrl.toString().isNotEmpty) return asset.downloadUrl;
    }
    return null;
  }

  factory ReleaseInfo.fromGitHub(Map<String, dynamic> json) {
    final tag = json['tag_name'] as String? ?? '';
    final htmlUrl = json['html_url'] as String?;

    return ReleaseInfo(
      version: _normalizeVersion(tag),
      name: json['name'] as String? ?? '',
      body: json['body'] as String? ?? '',
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'] as String)
          : null,
      htmlUrl: Uri.parse(
        (htmlUrl != null && htmlUrl.isNotEmpty) ? htmlUrl : _releasesPage,
      ),
      assets: (json['assets'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ReleaseAsset.fromGitHub)
          .toList(),
    );
  }
}

class ReleaseAsset {
  final String name;
  final Uri downloadUrl;

  const ReleaseAsset({
    required this.name,
    required this.downloadUrl,
  });

  factory ReleaseAsset.fromGitHub(Map<String, dynamic> json) {
    final url = json['browser_download_url'] as String? ?? '';
    return ReleaseAsset(
      name: json['name'] as String? ?? '',
      downloadUrl: Uri.parse(url.isNotEmpty ? url : _releasesPage),
    );
  }
}

/// Controller quản lý trạng thái kiểm tra/cập nhật ứng dụng
class UpdateController {
  final isChecking = signal<bool>(false);
  final hasUpdate = signal<bool>(false);
  final currentVersion = signal<String>('0.0.0');
  final latestVersion = signal<String>('0.0.0');
  final lastCheckedAt = signal<DateTime?>(null);
  final latestRelease = signal<ReleaseInfo?>(null);
  final releases = signal<List<ReleaseInfo>>([]);
  final lastError = signal<String?>(null);

  Future<void> initialize() async {
    currentVersion.value = await getAppVersion();
    await checkForUpdates();
  }

  Future<void> checkForUpdates() async {
    if (isChecking.value) return;
    isChecking.value = true;
    lastError.value = null;
    try {
      final fetchedReleases = await _fetchReleases();
      releases.value = fetchedReleases;
      latestRelease.value = fetchedReleases.isNotEmpty ? fetchedReleases.first : null;

      if (latestRelease.value != null) {
        latestVersion.value = latestRelease.value!.version;
        hasUpdate.value = _isNewerVersion(
          latestRelease.value!.version,
          currentVersion.value,
        );
      } else {
        latestVersion.value = currentVersion.value;
        hasUpdate.value = false;
      }
    } catch (e) {
      hasUpdate.value = false;
      latestVersion.value = currentVersion.value;
      lastError.value = 'Failed to fetch releases: $e';
    } finally {
      lastCheckedAt.value = DateTime.now();
      isChecking.value = false;
    }
  }

  Future<Uri?> resolveDownloadUrl() async {
    final release = latestRelease.value;
    if (release == null) return null;
    return release.primaryAssetUrl ?? release.htmlUrl;
  }

  Uri get releasePageUrl => latestRelease.value?.htmlUrl ?? Uri.parse(_releasesPage);

  List<int> _parseVersionParts(String raw) {
    final sanitized = _normalizeVersion(raw);
    final versionOnly = sanitized.split('+').first;
    return versionOnly
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
  }

  bool _isNewerVersion(String latest, String current) {
    final latestParts = _parseVersionParts(latest);
    final currentParts = _parseVersionParts(current);
    final maxLength = math.max(latestParts.length, currentParts.length);

    for (var i = 0; i < maxLength; i++) {
      final latestValue = i < latestParts.length ? latestParts[i] : 0;
      final currentValue = i < currentParts.length ? currentParts[i] : 0;
      if (latestValue > currentValue) return true;
      if (latestValue < currentValue) return false;
    }

    return false;
  }

  void skipUpdate() {
    hasUpdate.value = false;
  }

  void dispose() {
    isChecking.dispose();
    hasUpdate.dispose();
    currentVersion.dispose();
    latestVersion.dispose();
    lastCheckedAt.dispose();
    latestRelease.dispose();
    releases.dispose();
    lastError.dispose();
  }

  Future<List<ReleaseInfo>> _fetchReleases() async {
    final response = await http.get(
      Uri.parse(_releasesEndpoint),
      headers: const {'Accept': 'application/vnd.github+json'},
    );

    if (response.statusCode != 200) {
      lastError.value =
          'GitHub returned status ${response.statusCode} while fetching releases';
      return [];
    }

    final data = jsonDecode(response.body);
    if (data is! List) {
      lastError.value = 'Unexpected release response shape';
      return [];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .where((release) => release['draft'] != true)
        .take(10)
        .map(ReleaseInfo.fromGitHub)
        .toList();
  }
}

String _normalizeVersion(String input) {
  return input.replaceFirst(RegExp(r'^v'), '').trim();
}
