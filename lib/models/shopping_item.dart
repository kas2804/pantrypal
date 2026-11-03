import 'package:uuid/uuid.dart';

class ShoppingItem {
  final String id;
  final String name;
  final String category; // e.g. 'Veggies', 'Dairy'
  final double quantity; // e.g. 2.0
  final String unit; // e.g. 'kg', 'L', 'pcs'
  final String priority; // 'High', 'Medium', 'Low'
  final String buyFrom; // 'Online', 'Outside', 'Any'
  final String store; // 'DMart', 'Zepto', 'Blinkit' etc.
  final String notes;
  final bool isTicked;
  final bool isFavourite;
  final bool isOftenBought;
  final bool isRepeating;
  final String repeatFrequency; // 'Daily', 'Weekly', 'Monthly'
  final DateTime createdAt;

  ShoppingItem({
    String? id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.priority = 'Medium',
    this.buyFrom = 'Any',
    this.store = 'Any',
    this.notes = '',
    this.isTicked = false,
    this.isFavourite = false,
    this.isOftenBought = false,
    this.isRepeating = false,
    this.repeatFrequency = 'Weekly',
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  // ─── Converts this item into a Map so Hive can save it ───────────────────
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'quantity': quantity,
    'unit': unit,
    'priority': priority,
    'buyFrom': buyFrom,
    'store': store,
    'notes': notes,
    'isTicked': isTicked,
    'isFavourite': isFavourite,
    'isOftenBought': isOftenBought,
    'isRepeating': isRepeating,
    'repeatFrequency': repeatFrequency,
    'createdAt': createdAt.toIso8601String(),
  };

  // ─── Recreates a ShoppingItem from a saved Map ───────────────────────────
  factory ShoppingItem.fromMap(Map<dynamic, dynamic> map) => ShoppingItem(
    id: map['id'] as String,
    name: map['name'] as String,
    category: map['category'] as String,
    quantity: (map['quantity'] as num).toDouble(),
    unit: map['unit'] as String,
    priority: map['priority'] as String? ?? 'Medium',
    buyFrom: map['buyFrom'] as String? ?? 'Any',
    store: map['store'] as String? ?? 'Any',
    notes: map['notes'] as String? ?? '',
    isTicked: map['isTicked'] as bool? ?? false,
    isFavourite: map['isFavourite'] as bool? ?? false,
    isOftenBought: map['isOftenBought'] as bool? ?? false,
    isRepeating: map['isRepeating'] as bool? ?? false,
    repeatFrequency: map['repeatFrequency'] as String? ?? 'Weekly',
    createdAt: DateTime.parse(map['createdAt'] as String),
  );

  // ─── Makes a modified copy of this item ──────────────────────────────────
  ShoppingItem copyWith({
    String? name,
    String? category,
    double? quantity,
    String? unit,
    String? priority,
    String? buyFrom,
    String? store,
    String? notes,
    bool? isTicked,
    bool? isFavourite,
    bool? isOftenBought,
    bool? isRepeating,
    String? repeatFrequency,
  }) => ShoppingItem(
    id: id,
    createdAt: createdAt,
    name: name ?? this.name,
    category: category ?? this.category,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    priority: priority ?? this.priority,
    buyFrom: buyFrom ?? this.buyFrom,
    store: store ?? this.store,
    notes: notes ?? this.notes,
    isTicked: isTicked ?? this.isTicked,
    isFavourite: isFavourite ?? this.isFavourite,
    isOftenBought: isOftenBought ?? this.isOftenBought,
    isRepeating: isRepeating ?? this.isRepeating,
    repeatFrequency: repeatFrequency ?? this.repeatFrequency,
  );
}
