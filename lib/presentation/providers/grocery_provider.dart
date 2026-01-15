import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../domain/repositories/grocery_repository.dart';
import '../../data/models/grocery_item_model.dart';
import '../../data/models/category_model.dart';

/// Provider for managing grocery list state
/// Handles all grocery-related operations and notifies listeners
class GroceryProvider with ChangeNotifier {
  final GroceryRepository _repository;
  final Uuid _uuid = const Uuid();

  GroceryProvider(this._repository);

  List<GroceryItemModel> _items = [];
  bool _isLoading = false;
  String _searchQuery = '';

  // Getters
  List<GroceryItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<GroceryItemModel> get activeItems =>
      _items.where((item) => !item.isDone).toList();

  List<GroceryItemModel> get completedItems =>
      _items.where((item) => item.isDone).toList();

  Map<GroceryCategory, List<GroceryItemModel>> get itemsByCategory {
    final Map<GroceryCategory, List<GroceryItemModel>> categorized = {};
    
    for (final item in activeItems) {
      if (!categorized.containsKey(item.category)) {
        categorized[item.category] = [];
      }
      categorized[item.category]!.add(item);
    }

    return categorized;
  }

  int get totalItems => _items.length;
  int get activeItemsCount => activeItems.length;
  int get completedItemsCount => completedItems.length;

  /// Initialize and load items from repository
  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = _repository.getAllItems();
    } catch (e) {
      debugPrint('Error loading items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new item
  Future<void> addItem({
    required String name,
    required GroceryCategory category,
    int quantity = 1,
    String? notes,
  }) async {
    try {
      final item = GroceryItemModel(
        id: _uuid.v4(),
        name: name,
        category: category,
        quantity: quantity,
        createdAt: DateTime.now(),
        notes: notes,
      );

      await _repository.addItem(item);
      _items.add(item);
      
      // Haptic feedback
      HapticFeedback.lightImpact();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding item: $e');
      rethrow;
    }
  }

  /// Update an existing item
  Future<void> updateItem(GroceryItemModel item) async {
    try {
      await _repository.updateItem(item);
      
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating item: $e');
      rethrow;
    }
  }

  /// Delete an item
  Future<void> deleteItem(String id) async {
    try {
      await _repository.deleteItem(id);
      _items.removeWhere((item) => item.id == id);
      
      // Haptic feedback
      HapticFeedback.mediumImpact();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting item: $e');
      rethrow;
    }
  }

  /// Toggle item completion status
  Future<void> toggleItemStatus(String id) async {
    try {
      await _repository.toggleItemStatus(id);
      
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        final item = _items[index];
        _items[index] = item.copyWith(
          isDone: !item.isDone,
          completedAt: !item.isDone ? DateTime.now() : null,
        );
        
        // Haptic feedback
        HapticFeedback.selectionClick();
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling item status: $e');
      rethrow;
    }
  }

  /// Clear all items
  Future<void> clearAllItems() async {
    try {
      await _repository.clearAllItems();
      _items.clear();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing items: $e');
      rethrow;
    }
  }

  /// Clear completed items
  Future<void> clearCompletedItems() async {
    try {
      await _repository.clearCompletedItems();
      _items.removeWhere((item) => item.isDone);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing completed items: $e');
      rethrow;
    }
  }

  /// Search items
  void searchItems(String query) {
    _searchQuery = query;
    
    if (query.isEmpty) {
      loadItems();
    } else {
      _items = _repository.searchItems(query);
      notifyListeners();
    }
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    return _repository.getStatistics();
  }

  /// Get items that are frequently bought together
  List<String> getFrequentlyBoughtTogether(String itemName) {
    // Placeholder for ML-based suggestions
    // In a real app, this would use purchase history analysis
    return [];
  }
}
