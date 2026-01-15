import '../../domain/repositories/grocery_repository.dart';
import '../models/grocery_item_model.dart';
import '../models/category_model.dart';
import '../datasources/hive_service.dart';

/// Implementation of GroceryRepository using Hive
/// Handles all data operations for grocery items
class GroceryRepositoryImpl implements GroceryRepository {
  final HiveService _hiveService;

  GroceryRepositoryImpl(this._hiveService);

  @override
  Future<void> addItem(GroceryItemModel item) async {
    await _hiveService.addItem(item);
  }

  @override
  List<GroceryItemModel> getAllItems() {
    return _hiveService.getAllItems();
  }

  @override
  List<GroceryItemModel> getActiveItems() {
    return _hiveService.getActiveItems();
  }

  @override
  List<GroceryItemModel> getCompletedItems() {
    return _hiveService.getCompletedItems();
  }

  @override
  Map<GroceryCategory, List<GroceryItemModel>> getItemsByCategory() {
    final items = getActiveItems();
    final Map<GroceryCategory, List<GroceryItemModel>> categorizedItems = {};

    for (final item in items) {
      if (!categorizedItems.containsKey(item.category)) {
        categorizedItems[item.category] = [];
      }
      categorizedItems[item.category]!.add(item);
    }

    // Sort items within each category by creation date
    for (final category in categorizedItems.keys) {
      categorizedItems[category]!.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );
    }

    return categorizedItems;
  }

  @override
  Future<void> updateItem(GroceryItemModel item) async {
    await _hiveService.updateItem(item);
  }

  @override
  Future<void> deleteItem(String id) async {
    await _hiveService.deleteItem(id);
  }

  @override
  Future<void> toggleItemStatus(String id) async {
    final items = _hiveService.getAllItems();
    final item = items.firstWhere((item) => item.id == id);
    
    final updatedItem = item.copyWith(
      isDone: !item.isDone,
      completedAt: !item.isDone ? DateTime.now() : null,
    );
    
    await _hiveService.updateItem(updatedItem);
  }

  @override
  Future<void> clearAllItems() async {
    await _hiveService.clearAllItems();
  }

  @override
  Future<void> clearCompletedItems() async {
    await _hiveService.clearCompletedItems();
  }

  @override
  List<GroceryItemModel> searchItems(String query) {
    if (query.isEmpty) return getAllItems();
    
    final lowerQuery = query.toLowerCase();
    return getAllItems().where((item) {
      return item.name.toLowerCase().contains(lowerQuery) ||
          item.category.displayName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Map<String, dynamic> getStatistics() {
    final allItems = getAllItems();
    final activeItems = getActiveItems();
    final completedItems = getCompletedItems();

    // Count items by category
    final Map<GroceryCategory, int> categoryCount = {};
    for (final item in allItems) {
      categoryCount[item.category] = (categoryCount[item.category] ?? 0) + 1;
    }

    // Find most frequent category
    GroceryCategory? mostFrequentCategory;
    int maxCount = 0;
    categoryCount.forEach((category, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequentCategory = category;
      }
    });

    return {
      'totalItems': allItems.length,
      'activeItems': activeItems.length,
      'completedItems': completedItems.length,
      'completionRate': allItems.isEmpty
          ? 0.0
          : (completedItems.length / allItems.length) * 100,
      'categoryCount': categoryCount,
      'mostFrequentCategory': mostFrequentCategory,
    };
  }
}
