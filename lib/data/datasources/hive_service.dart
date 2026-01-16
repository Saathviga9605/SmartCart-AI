import 'package:hive_flutter/hive_flutter.dart';
import '../models/grocery_item_model.dart';
import '../models/category_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';

/// Hive service for local data persistence
/// Handles all database operations for grocery items
class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  Box<GroceryItemModel>? _groceryBox;
  Box? _settingsBox;
  Box? _historyBox;

  /// Initialize Hive and register adapters
  Future<void> init() async {
    try {
      await Hive.initFlutter();

      // Register type adapters
      if (!Hive.isAdapterRegistered(AppConstants.groceryItemTypeId)) {
        Hive.registerAdapter(GroceryItemModelAdapter());
      }
      if (!Hive.isAdapterRegistered(AppConstants.categoryTypeId)) {
        Hive.registerAdapter(GroceryCategoryAdapter());
      }

      // Open boxes
      _groceryBox = await Hive.openBox<GroceryItemModel>(
        AppConstants.groceryBoxName,
      );
      _settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
      _historyBox = await Hive.openBox(AppConstants.historyBoxName);
    } catch (e) {
      throw CacheException(
        message: 'Failed to initialize Hive',
        originalError: e,
      );
    }
  }

  /// Get grocery box
  Box<GroceryItemModel> get groceryBox {
    if (_groceryBox == null || !_groceryBox!.isOpen) {
      throw const CacheException(message: 'Grocery box not initialized');
    }
    return _groceryBox!;
  }

  /// Get settings box
  Box get settingsBox {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw const CacheException(message: 'Settings box not initialized');
    }
    return _settingsBox!;
  }

  /// Get history box
  Box get historyBox {
    if (_historyBox == null || !_historyBox!.isOpen) {
      throw const CacheException(message: 'History box not initialized');
    }
    return _historyBox!;
  }

  // CRUD Operations for Grocery Items

  /// Add a new grocery item
  Future<void> addItem(GroceryItemModel item) async {
    try {
      await groceryBox.put(item.id, item);
    } catch (e) {
      throw CacheException(
        message: 'Failed to add item: ${item.id}',
        originalError: e,
      );
    }
  }

  /// Get all grocery items
  List<GroceryItemModel> getAllItems() {
    try {
      return groceryBox.values.toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get all items',
        originalError: e,
      );
    }
  }

  /// Get active (not done) items
  List<GroceryItemModel> getActiveItems() {
    try {
      return groceryBox.values.where((item) => !item.isDone).toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get active items',
        originalError: e,
      );
    }
  }

  /// Get completed items
  List<GroceryItemModel> getCompletedItems() {
    try {
      return groceryBox.values.where((item) => item.isDone).toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get completed items',
        originalError: e,
      );
    }
  }

  /// Get items by category
  List<GroceryItemModel> getItemsByCategory(GroceryCategory category) {
    try {
      return groceryBox.values
          .where((item) => item.category == category)
          .toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get items by category: $category',
        originalError: e,
      );
    }
  }

  /// Update an existing item
  Future<void> updateItem(GroceryItemModel item) async {
    try {
      await groceryBox.put(item.id, item);
    } catch (e) {
      throw CacheException(
        message: 'Failed to update item: ${item.id}',
        originalError: e,
      );
    }
  }

  /// Delete an item
  Future<void> deleteItem(String id) async {
    try {
      await groceryBox.delete(id);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete item: $id',
        originalError: e,
      );
    }
  }

  /// Clear all items
  Future<void> clearAllItems() async {
    try {
      await groceryBox.clear();
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear all items',
        originalError: e,
      );
    }
  }

  /// Clear completed items
  Future<void> clearCompletedItems() async {
    try {
      final completedIds = groceryBox.values
          .where((item) => item.isDone)
          .map((item) => item.id)
          .toList();
      
      for (final id in completedIds) {
        await groceryBox.delete(id);
      }
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear completed items',
        originalError: e,
      );
    }
  }

  // Settings Operations

  /// Get a setting value
  T? getSetting<T>(String key, {T? defaultValue}) {
    try {
      return settingsBox.get(key, defaultValue: defaultValue) as T?;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get setting: $key',
        originalError: e,
      );
    }
  }

  /// Save a setting value
  Future<void> saveSetting(String key, dynamic value) async {
    try {
      await settingsBox.put(key, value);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save setting: $key',
        originalError: e,
      );
    }
  }

  // History Operations

  /// Save shopping list to history
  Future<void> saveToHistory(List<GroceryItemModel> items) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final historyData = {
        'timestamp': timestamp,
        'items': items.map((item) => item.toJson()).toList(),
      };
      await historyBox.add(historyData);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save history',
        originalError: e,
      );
    }
  }

  /// Get shopping history
  List<Map<String, dynamic>> getHistory() {
    try {
      return historyBox.values
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get history',
        originalError: e,
      );
    }
  }

  /// Clear history
  Future<void> clearHistory() async {
    try {
      await historyBox.clear();
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear history',
        originalError: e,
      );
    }
  }

  /// Close all boxes (cleanup)
  Future<void> close() async {
    try {
      await _groceryBox?.close();
      await _settingsBox?.close();
      await _historyBox?.close();
    } catch (e) {
      throw CacheException(
        message: 'Failed to close boxes',
        originalError: e,
      );
    }
  }
}
