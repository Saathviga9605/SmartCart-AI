import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:smartcart_ai/data/repositories/grocery_repository_impl.dart';
import 'package:smartcart_ai/data/datasources/hive_service.dart';
import 'package:smartcart_ai/data/models/grocery_item_model.dart';
import 'package:smartcart_ai/data/models/category_model.dart';
import 'package:smartcart_ai/core/error/exceptions.dart';

// Generate mocks
@GenerateMocks([HiveService])
import 'grocery_repository_impl_test.mocks.dart';

void main() {
  late GroceryRepositoryImpl repository;
  late MockHiveService mockHiveService;

  setUp(() {
    mockHiveService = MockHiveService();
    repository = GroceryRepositoryImpl(mockHiveService);
  });

  final tItem = GroceryItemModel(
    id: '1',
    name: 'Test Item',
    category: GroceryCategory.fruits,
    quantity: 1,
    createdAt: DateTime.now(),
    isDone: false,
  );

  final tCompletedItem = GroceryItemModel(
    id: '2',
    name: 'Completed Item',
    category: GroceryCategory.vegetables,
    quantity: 2,
    createdAt: DateTime.now(),
    isDone: true,
    completedAt: DateTime.now(),
  );

  group('getAllItems', () {
    test('should return list of items from HiveService', () {
      // Arrange
      when(mockHiveService.getAllItems()).thenReturn([tItem]);

      // Act
      final result = repository.getAllItems();

      // Assert
      expect(result, equals([tItem]));
      verify(mockHiveService.getAllItems());
      verifyNoMoreInteractions(mockHiveService);
    });

    test('should throw CacheException when HiveService fails', () {
      // Arrange
      when(mockHiveService.getAllItems()).thenThrow(
        const CacheException(message: 'Error'),
      );

      // Act & Assert
      expect(() => repository.getAllItems(), throwsA(isA<CacheException>()));
    });
  });

  group('getActiveItems', () {
    test('should return only active items', () {
      // Arrange
      when(mockHiveService.getActiveItems()).thenReturn([tItem]);

      // Act
      final result = repository.getActiveItems();

      // Assert
      expect(result, equals([tItem]));
      verify(mockHiveService.getActiveItems());
    });
  });

  group('getCompletedItems', () {
    test('should return only completed items', () {
      // Arrange
      when(mockHiveService.getCompletedItems()).thenReturn([tCompletedItem]);

      // Act
      final result = repository.getCompletedItems();

      // Assert
      expect(result, equals([tCompletedItem]));
      verify(mockHiveService.getCompletedItems());
    });
  });

  group('addItem', () {
    test('should call addItem on HiveService', () async {
      // Arrange
      when(mockHiveService.addItem(any)).thenAnswer((_) async => {});

      // Act
      await repository.addItem(tItem);

      // Assert
      verify(mockHiveService.addItem(tItem));
    });

    test('should propagate CacheException', () async {
      // Arrange
      when(mockHiveService.addItem(any)).thenThrow(
        const CacheException(message: 'Error'),
      );

      // Act & Assert
      expect(
        () => repository.addItem(tItem),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('toggleItemStatus', () {
    test('should toggle item status and update in HiveService', () async {
      // Arrange
      when(mockHiveService.getAllItems()).thenReturn([tItem]);
      when(mockHiveService.updateItem(any)).thenAnswer((_) async => {});

      // Act
      await repository.toggleItemStatus(tItem.id);

      // Assert
      verify(mockHiveService.getAllItems());
      final captured = verify(mockHiveService.updateItem(captureAny)).captured;
      final updatedItem = captured.first as GroceryItemModel;
      expect(updatedItem.id, tItem.id);
      expect(updatedItem.isDone, true);
      expect(updatedItem.completedAt, isNotNull);
    });
  });

  group('getStatistics', () {
    test('should return correct statistics', () {
      // Arrange
      when(mockHiveService.getAllItems()).thenReturn([tItem, tCompletedItem]);
      when(mockHiveService.getActiveItems()).thenReturn([tItem]);
      when(mockHiveService.getCompletedItems()).thenReturn([tCompletedItem]);

      // Act
      final result = repository.getStatistics();

      // Assert
      expect(result['totalItems'], 2);
      expect(result['activeItems'], 1);
      expect(result['completedItems'], 1);
      expect(result['completionRate'], 50.0);
      expect(result['mostFrequentCategory'], isNotNull);
    });
  });
}
