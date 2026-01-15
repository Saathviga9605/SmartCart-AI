import '../../data/models/grocery_item_model.dart';
import '../../data/models/category_model.dart';

/// Repository interface for grocery operations
/// Defines the contract for data operations (Clean Architecture)
abstract class GroceryRepository {
  /// Add a new item
  Future<void> addItem(GroceryItemModel item);

  /// Get all items
  List<GroceryItemModel> getAllItems();

  /// Get active items (not completed)
  List<GroceryItemModel> getActiveItems();

  /// Get completed items
  List<GroceryItemModel> getCompletedItems();

  /// Get items grouped by category
  Map<GroceryCategory, List<GroceryItemModel>> getItemsByCategory();

  /// Update an existing item
  Future<void> updateItem(GroceryItemModel item);

  /// Delete an item
  Future<void> deleteItem(String id);

  /// Toggle item completion status
  Future<void> toggleItemStatus(String id);

  /// Clear all items
  Future<void> clearAllItems();

  /// Clear completed items only
  Future<void> clearCompletedItems();

  /// Search items by name
  List<GroceryItemModel> searchItems(String query);

  /// Get statistics
  Map<String, dynamic> getStatistics();
}
