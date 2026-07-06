import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/inventory_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF9B6FD4),
                  Color(0xFFE07DA0),
                  Color(0xFF6FA8C8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'StockMaster',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Inventory with Elegance',
                    style: TextStyle(
                      color: Colors.white.withAlpha(200),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildDrawerTile(
            context,
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            routeName: '/dashboard',
            currentRoute: currentRoute,
            color: const Color(0xFF9B6FD4),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),
          _buildDrawerTile(
            context,
            icon: Icons.list_alt_rounded,
            label: 'Inventory List',
            routeName: '/inventory_list',
            currentRoute: currentRoute,
            color: const Color(0xFFE07DA0),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/inventory_list');
            },
          ),
          _buildDrawerTile(
            context,
            icon: Icons.category_rounded,
            label: 'Manage Categories',
            routeName: '/manage_categories',
            currentRoute: currentRoute,
            color: const Color(0xFF6FA8C8),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/manage_categories');
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF9B6FD4).withAlpha(12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCDB8E8).withAlpha(80)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isDark ? 'Dark Mode' : 'Light Mode',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Switch(
                    value: isDark,
                    activeColor: const Color(0xFF9B6FD4),
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).state =
                          val ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'StockMaster v1.0.0',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String routeName,
    required String? currentRoute,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isActive = currentRoute == routeName;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        leading: Icon(icon, color: isActive ? color : Theme.of(context).colorScheme.onSurface.withAlpha(150)),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? color : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        selected: isActive,
        selectedTileColor: color.withAlpha(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}
