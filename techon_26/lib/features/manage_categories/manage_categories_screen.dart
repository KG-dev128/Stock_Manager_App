import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/inventory_provider.dart';
import '../common/app_drawer.dart';

class ManageCategoriesScreen extends ConsumerStatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  ConsumerState<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends ConsumerState<ManageCategoriesScreen> {
  final TextEditingController _categoryController = TextEditingController();

  final List<String> _defaultCategories = [
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
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  void _addCategory() {
    final name = _categoryController.text.trim();
    if (name.isEmpty) return;

    final currentCats = ref.read(customCategoriesProvider);
    
    final allCats = [..._defaultCategories, ...currentCats];
    if (allCats.any((cat) => cat.toLowerCase() == name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Category already exists!'),
          backgroundColor: const Color(0xFFD97706),
        ),
      );
      return;
    }

    ref.read(customCategoriesProvider.notifier).state = [...currentCats, name];
    _categoryController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Category "$name" added successfully!'),
        backgroundColor: const Color(0xFF4BA57A),
      ),
    );
  }

  void _deleteCustomCategory(String category) {
    final currentCats = ref.read(customCategoriesProvider);
    ref.read(customCategoriesProvider.notifier).state = 
        currentCats.where((cat) => cat != category).toList();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Category "$category" removed.'),
        backgroundColor: const Color(0xFFE07DA0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customCategories = ref.watch(customCategoriesProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Manage Categories', style: TextStyle(fontWeight: FontWeight.bold)),
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
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      hintText: 'Enter new category name...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
                    ),
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _addCategory(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (customCategories.isNotEmpty) ...[
                  Text(
                    'Custom Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...customCategories.map((cat) => Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Theme.of(context).dividerColor.withAlpha(50)),
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(Icons.category_rounded, color: Theme.of(context).colorScheme.primary),
                      title: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFE07DA0)),
                        onPressed: () => _deleteCustomCategory(cat),
                      ),
                    ),
                  )),
                  const SizedBox(height: 24),
                ],
                
                Text(
                  'Default Categories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                  ),
                ),
                const SizedBox(height: 8),
                ..._defaultCategories.map((cat) => Card(
                  elevation: 0,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Theme.of(context).dividerColor.withAlpha(30)),
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(Icons.category_outlined, color: Theme.of(context).colorScheme.onSurface.withAlpha(100)),
                    title: Text(cat, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(180))),
                    trailing: Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.onSurface.withAlpha(80), size: 16),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
