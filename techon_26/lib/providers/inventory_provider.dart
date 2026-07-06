import 'package:flutter/material.dart'; // Required for ThemeMode
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/inventory_item.dart';
import '../data/repositories/inventory_repository.dart';

// Assuming StockStatus is defined in your models, if not, here is the enum:
// enum StockStatus { inStock, lowStock, outOfStock }

enum InventorySortOption { name, quantity, category }

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository();
});

final inventoryStreamProvider = StreamProvider<List<InventoryItem>>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.watchInventory();
});

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

final searchQueryProvider = StateProvider<String>((ref) => '');

final categoryFilterProvider = StateProvider<String?>((ref) => null);

final stockStatusFilterProvider = StateProvider<StockStatus?>((ref) => null);

final inventorySortProvider = StateProvider<InventorySortOption>((ref) => InventorySortOption.name);

final customCategoriesProvider = StateProvider<List<String>>((ref) => []);

final filteredInventoryProvider = Provider<AsyncValue<List<InventoryItem>>>((ref) {
  final inventoryAsync = ref.watch(inventoryStreamProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final selectedCategory = ref.watch(categoryFilterProvider);
  final selectedStatus = ref.watch(stockStatusFilterProvider);
  final sortBy = ref.watch(inventorySortProvider);

  return inventoryAsync.whenData((items) {
    // 1. Filter the items
    final filtered = items.where((item) {
      final matchesSearch = query.isEmpty || item.itemName.toLowerCase().contains(query);

      final matchesCategory = selectedCategory == null || 
          item.category.toLowerCase() == selectedCategory.toLowerCase();

      final matchesStatus = selectedStatus == null || item.status == selectedStatus;

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();

    // 2. Sort the filtered items cascades/in-place
    switch (sortBy) {
      case InventorySortOption.name:
        filtered.sort((a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));
        break;
      case InventorySortOption.quantity:
        filtered.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case InventorySortOption.category:
        filtered.sort((a, b) => a.category.toLowerCase().compareTo(b.category.toLowerCase()));
        break;
    }

    return filtered;
  });
});