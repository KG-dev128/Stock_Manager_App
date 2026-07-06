import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/inventory_provider.dart';
import '../../data/models/inventory_item.dart';
import '../common/app_drawer.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryStreamProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.inventory_2_rounded, color: Theme.of(context).colorScheme.primary, size: 26),
            const SizedBox(width: 8),
            const Text(
              'StockMaster',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
          ],
        ),
        elevation: 0,
        centerTitle: false,
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
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.notifications_none_rounded, color: Theme.of(context).colorScheme.onSurface),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: inventoryAsync.when(
        data: (items) {
          final totalItems = items.length;
          final lowStockItems = items.where((item) => item.status == StockStatus.lowStock).length;
          final outOfStockItems = items.where((item) => item.status == StockStatus.outOfStock).length;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(inventoryStreamProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(context),
                  const SizedBox(height: 24),

                  Text(
                    'Stock Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildStatsGrid(
                    context, 
                    totalItems: totalItems, 
                    lowStockItems: lowStockItems, 
                    outOfStockItems: outOfStockItems,
                  ),
                  const SizedBox(height: 28),

                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildQuickActionCards(context, ref),
                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Additions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/inventory_list'),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text('View All'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF0D9488),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  _buildRecentPreviewList(context, items),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 72, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Database Connection Error',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(inventoryStreamProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9B6FD4),
            Color(0xFFE07DA0),
            Color(0xFF6FA8C8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9B6FD4).withAlpha(50),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to StockMaster',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track products, manage alerts, and maintain categories seamlessly in real-time.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withAlpha(210),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.query_stats_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context, {
    required int totalItems,
    required int lowStockItems,
    required int outOfStockItems,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = (constraints.maxWidth - 16) / 2;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(
              title: 'Total Items',
              value: '$totalItems',
              subtitle: 'Unique items stored',
              icon: Icons.grid_view_rounded,
              color: const Color(0xFF9B6FD4),
              cardWidth: constraints.maxWidth,
            ),
            _buildStatCard(
              title: 'Low Stock',
              value: '$lowStockItems',
              subtitle: 'Needs review',
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFD97706),
              cardWidth: width,
            ),
            _buildStatCard(
              title: 'Out of Stock',
              value: '$outOfStockItems',
              subtitle: 'Order required',
              icon: Icons.gpp_bad_rounded,
              color: const Color(0xFFE07DA0),
              cardWidth: width,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double cardWidth,
  }) {
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(50), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: color.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCards(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _buildActionTile(
            context,
            title: 'Add Item',
            subtitle: 'Register new',
            icon: Icons.add_circle_outline_rounded,
            color: const Color(0xFF9B6FD4),
            onTap: () => Navigator.pushNamed(context, '/manage_item'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionTile(
            context,
            title: 'Manage Categories',
            subtitle: 'View & add',
            icon: Icons.category_outlined,
            color: const Color(0xFF6FA8C8),
            onTap: () => Navigator.pushNamed(context, '/manage_categories'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionTile(
            context,
            title: 'View List',
            subtitle: 'Filter & search',
            icon: Icons.list_alt_rounded,
            color: const Color(0xFFE07DA0),
            onTap: () => Navigator.pushNamed(context, '/inventory_list'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Theme.of(context).dividerColor.withAlpha(50)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPreviewList(BuildContext context, List<InventoryItem> items) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withAlpha(50)),
        ),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 36, color: Theme.of(context).colorScheme.primary.withAlpha(120)),
            const SizedBox(height: 8),
            Text(
              'No items stored yet.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(150), fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final recentItems = List<InventoryItem>.from(items)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final displayItems = recentItems.take(3).toList();

    return Column(
      children: displayItems.map((item) {
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

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inventory_2_outlined, color: Theme.of(context).colorScheme.primary),
            ),
            title: Text(
              item.itemName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text('Category: ${item.category}', style: const TextStyle(fontSize: 12)),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Qty: ${item.quantity}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                ),
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
        );
      }).toList(),
    );
  }
}
