import 'package:uuid/uuid.dart';

class PantryItem {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final String status; // 'In Stock' | 'Running Low' | 'Out of Stock'
  final DateTime addedAt;

  PantryItem({
    String? id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.status = 'In Stock',
    DateTime? addedAt,
  }) : id = id ?? const Uuid().v4(),
       addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'quantity': quantity,
    'unit': unit,
    'status': status,
    'addedAt': addedAt.toIso8601String(),
  };

  factory PantryItem.fromMap(Map map) => PantryItem(
    id: map['id'] as String,
    name: map['name'] as String,
    category: map['category'] as String,
    quantity: (map['quantity'] as num).toDouble(),
    unit: map['unit'] as String,
    status: map['status'] as String? ?? 'In Stock',
    addedAt: DateTime.parse(map['addedAt'] as String),
  );

  PantryItem copyWith({
    String? name,
    String? category,
    double? quantity,
    String? unit,
    String? status,
  }) => PantryItem(
    id: id,
    addedAt: addedAt,
    name: name ?? this.name,
    category: category ?? this.category,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    status: status ?? this.status,
  );
}
