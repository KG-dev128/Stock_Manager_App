import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/splash/splash_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/inventory_list/inventory_list_screen.dart';
import 'features/manage_item/manage_item_screen.dart';
import 'features/manage_categories/manage_categories_screen.dart';
import 'providers/inventory_provider.dart';

class SupabaseConfig {
  static const String url = 'https://ifiodsrgdvunvwprgbdm.supabase.co';
  static const String anonKey = 'sb_publishable_U1YfxEZaqR2kgXKbbSub3w_n6hNmzLa';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
  } catch (e) {
    debugPrint('Supabase Initialization Warning: $e');
    debugPrint('Make sure to supply active SUPABASE_URL and SUPABASE_ANON_KEY config parameters.');
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeModeProvider);
    final ColorScheme customColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: const Color(0xFF9B6FD4),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFECE0FF),
      onPrimaryContainer: const Color(0xFF4A1880),
      secondary: const Color(0xFFE07DA0),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFFFD9E4),
      onSecondaryContainer: const Color(0xFF5C0028),
      tertiary: const Color(0xFF6FA8C8),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFD4EFFF),
      onTertiaryContainer: const Color(0xFF003548),
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
      surface: const Color(0xFFFDF6FF),
      onSurface: const Color(0xFF1E1A2B),
      surfaceContainerHighest: const Color(0xFFEDE0FF),
      outline: const Color(0xFFCDB8E8),
      outlineVariant: const Color(0xFFE8D8FF),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: const Color(0xFF332D40),
      onInverseSurface: const Color(0xFFF6ECFF),
      inversePrimary: const Color(0xFFCFA8FF),
    );

    final ColorScheme darkColorScheme = ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: const Color(0xFF9B6FD4),
      primary: const Color(0xFFCFA8FF),
      primaryContainer: const Color(0xFF4A1880),
      secondary: const Color(0xFFFFB1C9),
      surface: const Color(0xFF1E1E2E),
    );

    return MaterialApp(
      title: 'StockMaster',
      debugShowCheckedModeBanner: false,
      themeMode: currentThemeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: customColorScheme,
        scaffoldBackgroundColor: const Color(0xFFFAF4FF),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFEDE0FF), width: 1.2),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAF4FF),
          foregroundColor: Color(0xFF9B6FD4),
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFECE0FF),
          selectedColor: const Color(0xFF9B6FD4),
          labelStyle: const TextStyle(fontSize: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5EDFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCDB8E8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCDB8E8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF9B6FD4), width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9B6FD4),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF9B6FD4),
          foregroundColor: Colors.white,
        ),
        dividerColor: const Color(0xFFEDE0FF),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFFFAF4FF),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        scaffoldBackgroundColor: const Color(0xFF1E1E2E),
        cardTheme: CardThemeData(
          color: const Color(0xFF27293D),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF3D3355), width: 1.2),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E2E),
          foregroundColor: Color(0xFFCFA8FF),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFCFA8FF),
          foregroundColor: Color(0xFF1E1E2E),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF27293D),
        ),
      ),
      
      initialRoute: '/splash',
      
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/inventory_list': (context) => const InventoryListScreen(),
        '/manage_item': (context) => const ManageItemScreen(),
        '/manage_categories': (context) => const ManageCategoriesScreen(),
      },
    );
  }
}
