import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:signals/signals.dart';

/// Hive-backed base repository to replace SharedPreferences storage for core stores.
/// Keeps the existing API (class name and methods) so current repositories continue to work
/// without refactors. Under the hood, each repository uses a dedicated Hive Box keyed by its prefix.
///
/// Storage model:
/// - Box name: repo_{prefix}
/// - Record key: itemId (from getItemId)

// - Record value: Map<String, dynamic> returned by serializeToFields(item)
///
/// Notes:
/// - Box opening is async; we eagerly open in the constructor (fire-and-forget).
/// - Synchronous getters (getItem/getItems) will return null/[] if the box is not yet open.
///   As soon as the box opens (or after first write), streams and subsequent calls will see data.
/// - No TypeAdapters required because we store plain Map/List primitives.
abstract class HiveBaseStorage<T> {
  HiveBaseStorage() {
    // Eagerly initialize Hive box (non-blocking)
    _initBox();
  }

  // Required by repositories
  String get prefix;
  String getItemId(T item);
  Map<String, dynamic> serializeToFields(T item);
  T deserializeFromFields(String id, Map<String, dynamic> fields);

  // Reactive signal for change notifications
  final changeSignal = signal<int>(0);

  // Internal
  static bool _hiveInitialized = false;

  String get _boxName => 'storage_$prefix';

  Future<void> _ensureHive() async {
    if (!_hiveInitialized) {
      // Hive is initialized in main.dart
      // We avoid calling Hive.initFlutter() again to prevent path conflicts
      _hiveInitialized = true;
    }
  }

  Future<Box> _openBox() async {
    await _ensureHive();
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }
    return await Hive.openBox(_boxName);
  }

  void _initBox() {
    // Fire-and-forget open to minimize latency for first sync reads
    unawaited(_openBox());
  }

  @protected
  List<String> getItemIds() {
    if (!Hive.isBoxOpen(_boxName)) return <String>[];
    final box = Hive.box(_boxName);
    return box.keys
        .map((k) => k.toString())
        .where((k) => !k.startsWith('__'))
        .toList();
  }

  // CRUD

  Future<void> saveItem(T item) async {
    final id = getItemId(item);
    final fields = serializeToFields(item);

    final box = await _openBox();
    await box.put(id, fields);

    // Notify listeners
    changeSignal.value++;
  }

  T? getItem(String id) {
    if (!Hive.isBoxOpen(_boxName)) {
      // Try to wait briefly for box to open if initialization is in progress
      return null;
    }
    final box = Hive.box(_boxName);
    final raw = box.get(id);
    if (raw == null) return null;

    try {
      // Ensure map is a Map<String, dynamic>
      final map = raw is String
          ? (json.decode(raw) as Map<String, dynamic>)
          : (json.decode(json.encode(raw)) as Map<String, dynamic>);

      return deserializeFromFields(id, map);
    } catch (_) {
      return null;
    }
  }

  /// Get items synchronously. Returns empty list if box not ready.
  /// For reactive UI, use getItemsAsync() or itemsStream instead.
  List<T> getItems() {
    if (!Hive.isBoxOpen(_boxName)) {
      // Box not open yet, return empty list
      // Callers should use await getItemsAsync() or itemsStream for reliable data
      return <T>[];
    }
    final box = Hive.box(_boxName);
    return _getItemsFromBox(box);
  }

  /// Get items asynchronously, ensuring box is opened first
  Future<List<T>> getItemsAsync() async {
    final box = await _openBox();
    return _getItemsFromBox(box);
  }

  List<T> _getItemsFromBox(Box box) {
    final items = <T>[];

    for (final key in box.keys) {
      final id = key.toString();
      if (id.startsWith('__')) continue;
      final raw = box.get(id);
      if (raw == null) continue;
      try {
        final map = raw is String
            ? (json.decode(raw) as Map<String, dynamic>)
            : (json.decode(json.encode(raw)) as Map<String, dynamic>);
        final item = deserializeFromFields(id, map);
        items.add(item);
      } catch (e, stack) {
        debugPrint('Error deserializing item $id in $_boxName: $e\n$stack');
        // skip malformed entry
      }
    }

    // Apply persistent order if available
    final order = getOrder();
    if (order.isNotEmpty) {
      final itemMap = {for (var item in items) getItemId(item): item};
      final sortedItems = <T>[];
      for (var id in order) {
        if (itemMap.containsKey(id)) {
          sortedItems.add(itemMap[id] as T);
          itemMap.remove(id);
        }
      }
      // append remaining items (if any new ones were added but not yet in order list)
      sortedItems.addAll(itemMap.values);
      return sortedItems;
    }

    return items;
  }

  Future<void> saveOrder(List<String> ids) async {
    final box = await _openBox();
    await box.put('__order__', ids);
    changeSignal.value++;
  }

  List<String> getOrder() {
    if (!Hive.isBoxOpen(_boxName)) {
      // Try to get existing box synchronously
      try {
        final box = Hive.box(_boxName);
        final raw = box.get('__order__');
        if (raw is List) {
          return raw.cast<String>();
        }
      } catch (_) {
        // ignore
      }
      return <String>[];
    }
    final box = Hive.box(_boxName);
    final raw = box.get('__order__');
    if (raw is List) {
      return raw.cast<String>();
    }
    return <String>[];
  }

  Future<void> deleteItem(String id) async {
    final box = await _openBox();
    await box.delete(id);
    changeSignal.value++;
  }

  Future<void> clear() async {
    final box = await _openBox();
    await box.clear();
    changeSignal.value++;
  }

  // Reactive streams

  /// Stream that emits on every change. Starts by emitting once on subscribe.
  Stream<void> get changes {
    final controller = StreamController<void>.broadcast();
    EffectCleanup? cleanup;

    controller.onListen = () {
      controller.add(null); // initial tick

      // Watch signal changes
      cleanup = effect(() {
        changeSignal.value; // Track signal
        controller.add(null);
      });

      // Also attach to Hive watch (async)
      () async {
        final box = await _openBox();
        box.watch().listen((_) {
          controller.add(null);
        });
      }();
    };

    controller.onCancel = () {
      cleanup?.call();
    };

    return controller.stream;
  }

  /// Emits current items immediately and re-emits on each change.
  Stream<List<T>> get itemsStream {
    final controller = StreamController<List<T>>.broadcast();
    StreamSubscription? hiveSub;
    EffectCleanup? cleanup;

    Future<void> emit() async {
      // Ensure box is open before enumerating
      await _openBox();
      controller.add(getItems());
    }

    controller.onListen = () {
      // initial emit
      unawaited(emit());

      // listen to signal changes
      cleanup = effect(() {
        changeSignal.value; // Track signal
        unawaited(emit());
      });

      // listen to hive events
      () async {
        final box = await _openBox();
        hiveSub = box.watch().listen((_) {
          unawaited(emit());
        });
      }();
    };

    controller.onCancel = () async {
      cleanup?.call();
      await hiveSub?.cancel();
      hiveSub = null;
    };

    return controller.stream;
  }

  // Aliases for compatibility with previous base
  Future<void> addItem(T item) => saveItem(item);
  Future<void> updateItem(T item) => saveItem(item);

  /// Ensures the box is fully opened and ready for operations.
  /// This method should be called in the storage's init() method.
  Future<void> ensureBoxReady() async {
    await _openBox();
  }
}
