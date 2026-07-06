import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/inventory_item.dart';
import '../../providers/inventory_provider.dart';

class ManageItemScreen extends ConsumerStatefulWidget {
  const ManageItemScreen({super.key});

  @override
  ConsumerState<ManageItemScreen> createState() => _ManageItemScreenState();
}

class _ManageItemScreenState extends ConsumerState<ManageItemScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _minStockController;
  late TextEditingController _customCategoryController;
  
  String? _selectedCategory;
  bool _isCustomCategory = false;
  bool _isLoading = false;
  InventoryItem? _editingItem;

  final List<String> _categories = [
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
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _quantityController = TextEditingController();
    _minStockController = TextEditingController();
    _customCategoryController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is InventoryItem && _editingItem == null) {
      _editingItem = args;
      _nameController.text = args.itemName;
      _quantityController.text = args.quantity.toString();
      _minStockController.text = args.minimumStockLevel.toString();
      
      final customCats = ref.read(customCategoriesProvider);
      final allCatsCombined = [..._categories, ...customCats];
      final matchCategory = allCatsCombined.firstWhere(
        (cat) => cat.toLowerCase() == args.category.toLowerCase(),
        orElse: () => '',
      );

      if (matchCategory.isNotEmpty) {
        _selectedCategory = matchCategory;
        _isCustomCategory = false;
      } else {
        _selectedCategory = 'CUSTOM_VALUE';
        _isCustomCategory = true;
        _customCategoryController.text = args.category;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  String _generateUuid() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40; // set version to 4
    values[8] = (values[8] & 0x3f) | 0x80; // set variant to RFC 4122
    final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final name = _nameController.text.trim();
    final category = _isCustomCategory 
        ? _customCategoryController.text.trim() 
        : (_selectedCategory ?? 'Other');
    final quantity = int.parse(_quantityController.text.trim());
    final minStock = int.parse(_minStockController.text.trim());

    final repository = ref.read(inventoryRepositoryProvider);

    try {
      if (_editingItem != null) {
        final updatedItem = _editingItem!.copyWith(
          itemName: name,
          category: category,
          quantity: quantity,
          minimumStockLevel: minStock,
        );
        await repository.updateItem(updatedItem);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item updated successfully!'),
              backgroundColor: Color(0xFF4BA57A),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        final newItem = InventoryItem(
          id: _generateUuid(),
          itemName: name,
          category: category,
          quantity: quantity,
          minimumStockLevel: minStock,
          createdAt: DateTime.now(),
        );
        await repository.addItem(newItem);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item added successfully!'),
              backgroundColor: Color(0xFF4BA57A),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFE07DA0),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = _editingItem != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Inventory Item' : 'Add New Item',
          style: const TextStyle(fontWeight: FontWeight.bold),
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
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEditMode ? 'Modify item specifications' : 'Register a new stock item',
                    style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Item Name *',
                      hintText: 'Enter item name',
                      prefixIcon: const Icon(Icons.shopping_bag_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Item name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category *',
                      hintText: 'Select category',
                      prefixIcon: const Icon(Icons.category_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
                    ),
                    items: [
                      ...{..._categories, ...ref.watch(customCategoriesProvider)}.toList().map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        );
                      }),
                      const DropdownMenuItem(
                        value: 'CUSTOM_VALUE',
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 18, color: Color(0xFF6FA8C8)),
                            SizedBox(width: 8),
                            Text(
                              'Add Custom Category...',
                              style: TextStyle(color: Color(0xFF6FA8C8), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        if (value == 'CUSTOM_VALUE') {
                          _isCustomCategory = true;
                          _selectedCategory = 'CUSTOM_VALUE';
                        } else {
                          _isCustomCategory = false;
                          _selectedCategory = value;
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),

                  if (_isCustomCategory) ...[
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _customCategoryController,
                      decoration: InputDecoration(
                        labelText: 'Custom Category Name *',
                        hintText: 'Enter custom category',
                        prefixIcon: const Icon(Icons.add_box_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (_isCustomCategory && (value == null || value.trim().isEmpty)) {
                          return 'Custom category name is required';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity *',
                      hintText: 'Enter current quantity',
                      prefixIcon: const Icon(Icons.production_quantity_limits_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Quantity is required';
                      }
                      final number = int.tryParse(value.trim());
                      if (number == null) {
                        return 'Please enter a valid whole number';
                      }
                      if (number < 0) {
                        return 'Quantity cannot be negative';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _minStockController,
                    decoration: InputDecoration(
                      labelText: 'Minimum Stock Level *',
                      hintText: 'Alert when stock falls below this',
                      prefixIcon: const Icon(Icons.notification_important_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Minimum stock level is required';
                      }
                      final number = int.tryParse(value.trim());
                      if (number == null) {
                        return 'Please enter a valid whole number';
                      }
                      if (number < 0) {
                        return 'Minimum stock level cannot be negative';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: isEditMode 
                          ? const Color(0xFF6FA8C8) 
                          : Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      isEditMode ? 'Update Item' : 'Add Item',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha(90),
              child: const Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Saving changes...',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
