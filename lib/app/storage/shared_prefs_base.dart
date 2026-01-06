import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Base repository for SharedPreferences with field-level storage.
/// Each field of a model is stored in a separate key using prefixes.
///
/// Key format: {prefix}:{item_id}:{field_path}
/// Example: profile:abc123:name, profile:abc123:config:temperature
abstract class SharedPreferencesBase<T> {
  final SharedPreferences prefs;

  /// Prefix for all keys in this repository
  String get prefix;

  /// Change notifier for reactive updates
  final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);

  SharedPreferencesBase(this.prefs);

  /// Serialize an item into field-level key-value pairs
  Map<String, dynamic> serializeToFields(T item);

  /// Deserialize field-level key-value pairs into an item
  T deserializeFromFields(String id, Map<String, dynamic> fields);

  /// Get the unique identifier for an item
  String getItemId(T item);

  /// Get the index key for storing list of item IDs
  String get _indexKey => '$prefix:_index';

  /// Get all item IDs from the index
  @protected
  List<String> getItemIds() {
    final indexJson = prefs.getString(_indexKey);
    if (indexJson == null || indexJson.isEmpty) return [];
    try {
      return (json.decode(indexJson) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  /// Save item IDs to the index
  Future<void> _saveItemIds(List<String> ids) async {
    await prefs.setString(_indexKey, json.encode(ids));
  }

  /// Add an item ID to the index
  Future<void> _addToIndex(String id) async {
    final ids = getItemIds();
    if (!ids.contains(id)) {
      await _saveItemIds([...ids, id]);
    }
  }

  /// Remove an item ID from the index
  Future<void> _removeFromIndex(String id) async {
    fina<void> _removeFromIndex(String id) async {
    final ids = _getItemIds();
    ids.remove(id);
    await _saveItemIds(ids);
  }

  /// Get all keys for a specific item
  List<String> _getItemKeys(String id) {
    final itemPrefix = '$prefix:$id:';
    return prefs.getKeys().where((key) => key.startsWith(itemPrefix)).toList();
  }

  /// Save an item by storing each field in a separate key
  Future<void> saveItem(T item) async {
    final id = getItemId(item);
    final fields = serializeToFields(item);

    // Delete existing keys for this item first
    final existingKeys = _getItemKeys(id);
    for (final key in existingKeys) {
      await prefs.remove(key);
    }

    // Save each field
    await _saveFields(id, fields);

    // Add to index
    await _addToIndex(id);

    // Notify listeners
    changeNotifier.value++;
  }

  /// Recursively save fields with proper prefixing
  Future<void> _saveFields(
    String id,
    Map<String, dynamic> fields, [
    String parentPath = '',
  ]) async {
    for (final entry in fields.entries) {
      final fieldPath = parentPath.isEmpty
          ? entry.key
          : '$parentPath:${entry.key}';
      final fullKey = '$prefix:$id:$fieldPath';
      final value = entry.value;

      if (value == null) {
        // Skip null values
        continue;
      } else if (value is String) {
        await prefs.setString(fullKey, value);
      } else if (value is int) {
        await prefs.setInt(fullKey, value);
      } else if (value is double) {
        await prefs.setDouble(fullKey, value);
      } else if (value is bool) {
        await prefs.setBool(fullKey, value);
      } else if (value is List) {
        // Store list as JSON string
        await prefs.setString(fullKey, json.encode(value));
      } else if (value is Map) {
        // For nested objects, recursively save fields
        await _saveFields(id, value.cast<String, dynamic>(), fieldPath);
      } else {
        // Fallback: store as JSON string
        await prefs.setString(fullKey, json.encode(value));
      }
    }
  }

  /// Get a specific item by ID
  T? getItem(String id) {
    final ids = _getItemIds();
    if (!ids.contains(id)) return null;

    final fields = _loadFields(id);
    if (fields.isEmpty) return null;

    return deserializeFromFields(id, fields);
  }

  /// Load all fields for a specific item
  Map<String, dynamic> _loadFields(String id) {
    final itemPrefix = '$prefix:$id:';
    final Map<String, dynamic> fields = {};

    for (final key in prefs.getKeys()) {
      if (!key.startsWith(itemPrefix)) continue;

      // Extract field path
      final fieldPath = key.substring(itemPrefix.length);
      final value = _getValue(key);

      if (value != null) {
        _setNestedValue(fields, fieldPath, value);
      }
    }

    return fields;
  }

  /// Get value from SharedPreferences by key
  dynamic _getValue(String key) {
    final value = prefs.get(key);
    if (value is String) {
      // Try to decode JSON if it's a list or map
      if (value.startsWith('[') || value.startsWith('{')) {
        try {
          return json.decode(value);
        } catch (_) {
          return value;
        }
      }
      return value;
    }
    return value;
  }

  /// Set a nested value in a map using a colon-separated path
  void _setNestedValue(Map<String, dynamic> map, String path, dynamic value) {
    final parts = path.split(':');
    Map<String, dynamic> current = map;

    for (int i = 0; i < parts.length - 1; i++) {
      final part = parts[i];
      if (!current.containsKey(part)) {
        current[part] = <String, dynamic>{};
      }
      current = current[part] as Map<String, dynamic>;
    }

    current[parts.last] = value;
  }

  /// Get all items
  List<T> getItems() {
    final ids = _getItemIds();
    final items = <T>[];

    for (final id in ids) {
      final item = getItem(id);
      if (item != null) {
        items.add(item);
      }
    }

    return items;
  }

  /// Delete an item by ID
  Future<void> deleteItem(String id) async {
    // Remove all keys for this item
    final keys = _getItemKeys(id);
    for (final key in keys) {
      await prefs.remove(key);
    }

    // Remove from index
    await _removeFromIndex(id);

    // Notify listeners
    changeNotifier.value++;
  }

  /// Clear all items in this repository
  Future<void> clear() async {
    final ids = _getItemIds();

    // Remove all item keys
    for (final id in ids) {
      final keys = _getItemKeys(id);
      for (final key in keys) {
        await prefs.remove(key);
      }
    }

    // Clear index
    await prefs.remove(_indexKey);

    // Notify listeners
    changeNotifier.value++;
  }

  /// Stream of changes (emits when data changes)
  /// Emits only when ValueNotifier changes; starts with current value.
  Stream<void> get changes =>
      changeNotifier.toStream().map((_) => null).cast<void>();

  /// Stream of all items, emits immediately and on each change.
  Stream<List<T>> get itemsStream {
    final controller = StreamController<List<T>>.broadcast();
    StreamSubscription<void>? sub;
    controller.onListen = () {
      // Emit current items immediately
      controller.add(getItems());
      // Re-emit items on every change
      sub = changes.listen((_) {
        controller.add(getItems());
      });
    };
    controller.onCancel = () async {
      await sub?.cancel();
      sub = null;
    };
    return controller.stream;
  }

  /// Alias methods for compatibility
  Future<void> addItem(T item) => saveItem(item);
  Future<void> updateItem(T item) => saveItem(item);
}

//// Extension to convert ValueNotifier to a broadcast Stream that only
/// emits on actual changes and starts with the current value.
extension ValueNotifierStream<T> on ValueNotifier<T> {
  Stream<T> toStream() {
    late VoidCallback listener;
    final controller = StreamController<T>.broadcast();
    controller.onListen = () {
      // Emit current value immediately for new subscribers
      controller.add(value);
      // Emit on each change
      listener = () => controller.add(value);
      addListener(listener);
    };
    controller.onCancel = () {
      removeListener(listener);
    };
    return controller.stream;
  }
}
