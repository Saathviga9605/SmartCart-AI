import 'package:hive_flutter/hive_flutter.dart';
import '../models/grocery_item_model.dart';
import '../models/category_model.dart';
import '../../core/constants/app_constants.dart';

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
  }

  /// Get grocery box
  Box<GroceryItemModel> get groceryBox {
    if (_groceryBox == null || !_groceryBox!.isOpen) {
      throw Exception('Grocery box not initialized');
    }
    return _groceryBox!;
  }

  /// Get settings box
  Box get settingsBox {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw Exception('Settings box not initialized');
    }
    return _settingsBox!;
  }

  /// Get history box
  Box get historyBox {
    if (_historyBox == null || !_historyBox!.isOpen) {
      throw Exception('History box not initialized');
    }
    return _historyBox!;
  }

  // CRUD Operations for Grocery Items

  /// Add a new grocery item
  Future<void> addItem(GroceryItemModel item) async {
    await groceryBox.put(item.id, item);
  }

  /// Get all grocery items
  List<GroceryItemModel> getAllItems() {
    return groceryBox.values.toList();
  }

  /// Get active (not done) items
  List<GroceryItemModel> getActiveItems() {
    return groceryBox.values.where((item) => !item.isDone).toList();
  }

  /// Get completed items
  List<GroceryItemModel> getCompletedItems() {
    return groceryBox.values.where((item) => item.isDone).toList();
  }

  /// Get items by category
  List<GroceryItemModel> getItemsByCategory(GroceryCategory category) {
    return groceryBox.values
        .where((item) => item.category == category)
        .toList();
  }

  /// Update an existing item
  Future<void> updateItem(GroceryItemModel item) async {
    await groceryBox.put(item.id, item);
  }

  /// Delete an item
  Future<void> deleteItem(String id) async {
    await groceryBox.delete(id);
  }

  /// Clear all items
  Future<void> clearAllItems() async {
    await groceryBox.clear();
  }

  /// Clear completed items
  Future<void> clearCompletedItems() async {
    final completedIds = groceryBox.values
        .where((item) => item.isDone)
        .map((item) => item.id)
        .toList();
    
    for (final id in completedIds) {
      await groceryBox.delete(id);
    }
  }

  // Settings Operations

  /// Get a setting value
  T? getSetting<T>(String key, {T? defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  /// Save a setting value
  Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  // History Operations

  /// Save shopping list to history
  Future<void> saveToHistory(List<GroceryItemModel> items) async {
    final timestamp = DateTime.now().toIso8601String();
    final historyData = {
      'timestamp': timestamp,
      'items': items.map((item) => item.toJson()).toList(),
    };
    await historyBox.add(historyData);
  }

  /// Get shopping history
  List<Map<String, dynamic>> getHistory() {
    return historyBox.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// Clear history
  Future<void> clearHistory() async {
    await historyBox.clear();
  }

  /// Close all boxes (cleanup)
  Future<void> close() async {
    await _groceryBox?.close();
    await _settingsBox?.close();
    await _historyBox?.close();
  }
}
