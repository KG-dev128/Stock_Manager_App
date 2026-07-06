import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inventory_item.dart';

class InventoryRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<List<InventoryItem>> watchInventory() {
    return _client
        .from('inventory')
        .stream(primaryKey: ['id'])
        .map((maps) {
          try {
            return maps.map((map) => InventoryItem.fromMap(map)).toList();
          } catch (e) {
            debugPrint('Error parsing inventory items: $e');
            rethrow;
          }
        });
  }

  Future<void> addItem(InventoryItem item) async {
    try {
      await _client.from('inventory').insert(item.toMap());
    } catch (e) {
      debugPrint('Error in addItem: $e');
      throw Exception('Failed to add inventory item: $e');
    }
  }

  Future<void> updateItem(InventoryItem item) async {
    try {
      await _client
          .from('inventory')
          .update(item.toMap())
          .eq('id', item.id);
    } catch (e) {
      debugPrint('Error in updateItem: $e');
      throw Exception('Failed to update inventory item: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _client
          .from('inventory')
          .delete()
          .eq('id', id);
    } catch (e) {
      debugPrint('Error in deleteItem: $e');
      throw Exception('Failed to delete inventory item: $e');
    }
  }
}
