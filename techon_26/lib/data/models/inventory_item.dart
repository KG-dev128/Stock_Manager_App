enum StockStatus { outOfStock, lowStock, inStock }

class InventoryItem {
  final String id;
  final String itemName;
  final String category;
  final int quantity;
  final int minimumStockLevel;
  final DateTime createdAt;

  const InventoryItem({
    required this.id,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.minimumStockLevel,
    required this.createdAt,
  });

  StockStatus get status {
    if (quantity == 0) {
      return StockStatus.outOfStock;
    } else if (quantity <= minimumStockLevel) {
      return StockStatus.lowStock;
    } else {
      return StockStatus.inStock;
    }
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'] as String,
      itemName: map['item_name'] as String,
      category: map['category'] as String,
      quantity: (map['quantity'] as num).toInt(),
      minimumStockLevel: (map['minimum_stock_level'] as num).toInt(),
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_name': itemName,
      'category': category,
      'quantity': quantity,
      'minimum_stock_level': minimumStockLevel,
      'created_at': createdAt.toIso8601String(),
    };
  }

  InventoryItem copyWith({
    String? id,
    String? itemName,
    String? category,
    int? quantity,
    int? minimumStockLevel,
    DateTime? createdAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      minimumStockLevel: minimumStockLevel ?? this.minimumStockLevel,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
