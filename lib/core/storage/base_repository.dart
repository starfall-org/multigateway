import 'package:shared_preferences/shared_preferences.dart';

abstract class BaseRepository<T> {
  final SharedPreferences prefs;

  /// The key used to store the list of items in SharedPreferences
  String get storageKey;

  BaseRepository(this.prefs);

  /// Deserializes a JSON string into an item of type T
  T deserializeItem(String json);

  /// Serializes an item of type T into a JSON string
  String serializeItem(T item);

  /// Gets the unique identifier for the item
  String getItemId(T item);

  /// Retrieves all items from storage
  List<T> getItems() {
    final List<String>? itemsJson = prefs.getStringList(storageKey);
    if (itemsJson == null || itemsJson.isEmpty) {
      return [];
    }
    return itemsJson.map((str) => deserializeItem(str)).toList();
  }

  /// Adds or updates an item in storage
  Future<void> saveItem(T item) async {
    final items = getItems();
    final id = getItemId(item);
    final index = items.indexWhere((i) => getItemId(i) == id);

    if (index != -1) {
      items[index] = item;
    } else {
      items.add(item);
    }
    await _saveItems(items);
  }

  /// Alias for saveItem to maintain backward compatibility with some naming in subclasses
  Future<void> addItem(T item) => saveItem(item);

  /// Alias for saveItem
  Future<void> updateItem(T item) => saveItem(item);

  /// Deletes an item by its ID
  Future<void> deleteItem(String id) async {
    final items = getItems();
    items.removeWhere((i) => getItemId(i) == id);
    await _saveItems(items);
  }

  Future<void> _saveItems(List<T> items) async {
    final List<String> itemsJson = items.map((i) => serializeItem(i)).toList();
    await prefs.setStringList(storageKey, itemsJson);
  }
}
