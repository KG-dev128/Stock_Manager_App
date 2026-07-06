import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/inventory_item.dart';
import '../../providers/inventory_provider.dart';
import '../common/app_drawer.dart';

class InventoryListScreen extends ConsumerWidget {
  const InventoryListScreen({super.key});

  static const List<String> categories = [
    'Electronics',
    'Apparel',
    'Groceries',
    'Home Goods',
    'Office Supplies',
    'Automotive',
    'Health & Beauty',
    'Toys & Games',
    'Books',
    'Sports & Outdoors',
    'Other'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredInventoryAsync = ref.watch(filteredInventoryProvider);
    final originalInventoryAsync = ref.watch(inventoryStreamProvider);

    final searchQuery = ref.watch(searchQueryProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);
    final selectedStatus = ref.watch(stockStatusFilterProvider);
    final currentSort = ref.watch(inventorySortProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: filteredInventoryAsync.maybeWhen(
          data: (items) => Text(
            'Inventory List (${items.length})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          orElse: () => const Text(
            'Inventory List',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              ref.watch(themeModeProvider) == ThemeMode.dark 
                  ? Icons.light_mode_rounded 
                  : Icons.dark_mode_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              final current = ref.read(themeModeProvider);
              ref.read(themeModeProvider.notifier).state = 
                  current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          PopupMenuButton<InventorySortOption>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort Items',
            initialValue: currentSort,
            onSelected: (sortOption) {
              ref.read(inventorySortProvider.notifier).state = sortOption;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: InventorySortOption.name,
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Sort by Name'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: InventorySortOption.quantity,
                child: Row(
                  children: [
                    Icon(Icons.format_list_numbered_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Sort by Quantity'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: InventorySortOption.category,
                child: Row(
                  children: [
                    Icon(Icons.category_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Sort by Category'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterControls(
            context,
            ref,
            searchQuery: searchQuery,
            selectedCategory: selectedCategory,
            selectedStatus: selectedStatus,
          ),

          Expanded(
            child: originalInventoryAsync.when(
              data: (allItems) {
                if (allItems.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'No Items Registered',
                    message: 'Your inventory database is currently empty. Tap the button below to add your first item.',
                    isFilterEmpty: false,
                  );
                }

                return filteredInventoryAsync.when(
                  data: (filteredItems) {
                    if (filteredItems.isEmpty) {
                      return const EmptyStateWidget(
                        title: 'No Matches Found',
                        message: 'No items match your active search or filter selection. Try adjusting your filters.',
                        isFilterEmpty: true,
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(inventoryStreamProvider);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return _buildInventoryListItem(context, ref, item);
                        },
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => _buildErrorWidget(context, ref, error),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorWidget(context, ref, error),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/manage_item');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterControls(
    BuildContext context,
    WidgetRef ref, {
    required String searchQuery,
    required String? selectedCategory,
    required StockStatus? selectedStatus,
  }) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
            decoration: InputDecoration(
              hintText: 'Search items by name...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCDB8E8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCDB8E8)),
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryDropdownFilter(context, ref, selectedCategory),
                const SizedBox(width: 8),

                _buildStatusChip(context, ref, 'All Statuses', null, selectedStatus == null),
                const SizedBox(width: 8),
                _buildStatusChip(context, ref, 'In Stock', StockStatus.inStock, selectedStatus == StockStatus.inStock),
                const SizedBox(width: 8),
                _buildStatusChip(context, ref, 'Low Stock', StockStatus.lowStock, selectedStatus == StockStatus.lowStock),
                const SizedBox(width: 8),
                _buildStatusChip(context, ref, 'Out of Stock', StockStatus.outOfStock, selectedStatus == StockStatus.outOfStock),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdownFilter(
    BuildContext context,
    WidgetRef ref,
    String? selectedCategory,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: selectedCategory != null 
            ? Theme.of(context).colorScheme.primaryContainer 
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selectedCategory != null 
              ? Theme.of(context).colorScheme.primary.withAlpha(128) 
              : const Color(0xFFE1BEE7),
        ),
      ),
      height: 36,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedCategory,
          dropdownColor: Theme.of(context).cardColor,
          hint: const Text(
            'All Categories',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF9E9E9E),
              fontWeight: FontWeight.w500,
            ),
          ),
          onChanged: (newValue) {
            ref.read(categoryFilterProvider.notifier).state = newValue;
          },
          style: TextStyle(
            fontSize: 13,
            color: selectedCategory != null
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: selectedCategory != null
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'All Categories',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            ...ref.watch(inventoryStreamProvider).maybeWhen(
                  data: (items) {
                    final customCats = ref.watch(customCategoriesProvider);
                    final unique = items.map((e) => e.category).toSet().toList()..sort();
                    return {...categories, ...customCats, ...unique}.toList()..sort();
                  },
                  orElse: () {
                    final customCats = ref.watch(customCategoriesProvider);
                    return {...categories, ...customCats}.toList()..sort();
                  },
                ).map((cat) {
              return DropdownMenuItem<String?>(
                value: cat,
                child: Text(
                  cat,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    StockStatus? status,
    bool isSelected,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(stockStatusFilterProvider.notifier).state = status;
        }
      },
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
      ),
      selectedColor: const Color(0xFF9B6FD4),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(80),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.transparent : const Color(0xFFCDB8E8),
        ),
      ),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildInventoryListItem(
    BuildContext context,
    WidgetRef ref,
    InventoryItem item,
  ) {
    Color statusColor;
    String statusText;
    switch (item.status) {
      case StockStatus.outOfStock:
        statusColor = const Color(0xFFE07DA0);
        statusText = 'Out of Stock';
        break;
      case StockStatus.lowStock:
        statusColor = const Color(0xFFD97706);
        statusText = 'Low Stock';
        break;
      case StockStatus.inStock:
        statusColor = const Color(0xFF4BA57A);
        statusText = 'In Stock';
        break;
    }

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context, item);
      },
      onDismissed: (direction) async {
        try {
          await ref.read(inventoryRepositoryProvider).deleteItem(item.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${item.itemName} deleted from inventory.')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete item: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              color: statusColor,
              size: 24,
            ),
          ),
          title: Text(
            item.itemName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Category: ${item.category}',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(140), fontSize: 13),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    'Qty: ',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(140), fontSize: 13),
                  ),
                  Text(
                    '${item.quantity}',
                    style: TextStyle(
                      color: item.status == StockStatus.outOfStock 
                          ? const Color(0xFFE07DA0) 
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    ' / Min: ${item.minimumStockLevel}',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(140), fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEF4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_rounded, size: 20, color: Color(0xFFE07DA0)),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    final confirm = await _showDeleteConfirmation(context, item);
                    if (confirm == true) {
                      try {
                        await ref.read(inventoryRepositoryProvider).deleteItem(item.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.itemName} deleted.'),
                              backgroundColor: const Color(0xFF9B6FD4),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/manage_item',
              arguments: item,
            );
          },
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, InventoryItem item) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
              const SizedBox(width: 8),
              const Text('Delete Item?'),
            ],
          ),
          content: Text.rich(
            TextSpan(
              text: 'Are you sure you want to permanently delete ',
              children: [
                TextSpan(
                  text: item.itemName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' from inventory? This action is irreversible.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          const Text('Error loading inventory list', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(error.toString(), style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(inventoryStreamProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class EmptyStateWidget extends ConsumerWidget {
  final String title;
  final String message;
  final bool isFilterEmpty;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    required this.isFilterEmpty,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isFilterEmpty 
                    ? const Color(0xFFFFF8E1) 
                    : const Color(0xFFECE0FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFilterEmpty ? Icons.filter_list_off_rounded : Icons.inventory_2_outlined,
                size: 64,
                color: isFilterEmpty 
                    ? const Color(0xFFD97706) 
                    : const Color(0xFF9B6FD4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (isFilterEmpty)
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(searchQueryProvider.notifier).state = '';
                  ref.read(categoryFilterProvider.notifier).state = null;
                  ref.read(stockStatusFilterProvider.notifier).state = null;
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reset Active Filters'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/manage_item');
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Your First Item'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}