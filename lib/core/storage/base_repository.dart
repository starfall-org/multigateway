import 'package:hive_flutter/hive_flutter.dart';

abstract class BaseRepository<T> {
  final Box<String> box;

  /// The name of the Hive box
  String get boxName;

  BaseRepository(this.box);

  /// Deserializes a JSON string into an item of type T
  T deserializeItem(String json);

  /// Serializes an item of type T into a JSON string
  String serializeItem(T item);

  /// Gets the unique identifier for the item
  String getItemId(T item);

  /// Retrieves all items from storage
  List<T> getItems() {
    return box.values.map((str) => deserializeItem(str)).toList();
  }

  /// Retrieves a specific item by its ID
  T? getItem(String id) {
    // We assume the key in the box is the ID.
    // However, if the box keys are not guaranteed to be ids (e.g. integer auto-increment),
    // we should check. In this implementation, we will perform saveItem by using ID as key.
    if (box.containsKey(id)) {
      final json = box.get(id);
      if (json != null) {
        return deserializeItem(json);
      }
    }
    return null;
  }

  /// Adds or updates an item in storage
  Future<void> saveItem(T item) async {
    final id = getItemId(item);
    await box.put(id, serializeItem(item));
  }

  /// Alias for saveItem to maintain backward compatibility with some naming in subclasses
  Future<void> addItem(T item) => saveItem(item);

  /// Alias for saveItem
  Future<void> updateItem(T item) => saveItem(item);

  /// Deletes an item by its ID
  Future<void> deleteItem(String id) async {
    await box.delete(id);
  }

  Future<void> clear() async {
    await box.clear();
  }

  /// Stream that emits events when the box is modified
  Stream<void> get changes => box.watch().map((_) {});
}
