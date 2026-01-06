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
    final ids = getItemIds();
    await _saveItemIds(ids..remove(id));
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
      final fieldPath = parentPath.isEmpty ? entry.key : '$parentPath:${entry.key}';
      final fullKey = '$prefix:$id:$fieldPath';
      final value = entry.value;

      if (value == null) continue;
      
      if (value is Map) {
        await _saveFields(id, value.cast<String, dynamic>(), fieldPath);
      } else if (value is String) {
        await prefs.setString(fullKey, value);
      } else if (value is int) {
        await prefs.setInt(fullKey, value);
      } else if (value is double) {
        await prefs.setDouble(fullKey, value);
      } else if (value is bool) {
        await prefs.setBool(fullKey, value);
      } else {
        await prefs.setString(fullKey, json.encode(value));
      }
    }
  }

  /// Get a specific item by ID
  T? getItem(String id) {
    if (!getItemIds().contains(id)) return null;
    final fields = _loadFields(id);
    return fields.isEmpty ? null : deserializeFromFields(id, fields);
  }

  /// Load all fields for a specific item
  Map<String, dynamic> _loadFields(String id) {
    final itemPrefix = '$prefix:$id:';
    final fields = <String, dynamic>{};

    for (final key in prefs.getKeys().where((k) => k.startsWith(itemPrefix))) {
      final value = _getValue(key);
      if (value != null) {
        _setNestedValue(fields, key.substring(itemPrefix.length), value);
      }
    }

    return fields;
  }

  /// Get value from SharedPreferences by key
  dynamic _getValue(String key) {
    final value = prefs.get(key);
    if (value is String && (value.startsWith('[') || value.startsWith('{'))) {
      try {
        return json.decode(value);
      } catch (_) {}
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
    return getItemIds()
        .map((id) => getItem(id))
        .whereType<T>()
        .toList();
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
    for (final id in getItemIds()) {
      for (final key in _getItemKeys(id)) {
        await prefs.remove(key);
      }
    }
    await prefs.remove(_indexKey);
    changeNotifier.value++;
  }

  /// Stream of changes (emits when data changes)
  Stream<void> get changes => changeNotifier.toStream().map((_) {});

  /// Stream of all items, emits immediately and on each change.
  Stream<List<T>> get itemsStream {
    final controller = StreamController<List<T>>.broadcast();
    StreamSubscription<void>? sub;
    
    controller.onListen = () {
      controller.add(getItems());
      sub = changes.listen((_) => controller.add(getItems()));
    };
    controller.onCancel = () => sub?.cancel();
    
    return controller.stream;
  }

  /// Alias methods for compatibility
  Future<void> addItem(T item) => saveItem(item);
  Future<void> updateItem(T item) => saveItem(item);
}

/// Extension to convert ValueNotifier to a broadcast Stream
extension ValueNotifierStream<T> on ValueNotifier<T> {
  Stream<T> toStream() {
    late VoidCallback listener;
    final controller = StreamController<T>.broadcast();
    
    controller.onListen = () {
      controller.add(value);
      listener = () => controller.add(value);
      addListener(listener);
    };
    controller.onCancel = () => removeListener(listener);
    
    return controller.stream;
  }
}
