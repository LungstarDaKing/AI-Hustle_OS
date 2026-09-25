import 'package:uuid/uuid.dart';

class Product {
  final String id;
  final String businessId;
  String name;
  String sku;
  String? description;
  double cost;
  double sellingPrice;
  String category;
  int quantity;
  int minimumStock;
  String? supplier;

  Product({
    String? id,
    required this.businessId,
    required this.name,
    required this.sku,
    this.description,
    required this.cost,
    required this.sellingPrice,
    required this.category,
    required this.quantity,
    required this.minimumStock,
    this.supplier,
  }) : id = id ?? const Uuid().v4();

  // Factory method to create a Product from a map (e.g., from database)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      businessId: map['business_id'] as String,
      name: map['name'] as String,
      sku: map['sku'] as String,
      description: map['description'] as String?,
      cost: (map['cost'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (map['selling_price'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] as String,
      quantity: (map['quantity'] as int?) ?? 0,
      minimumStock: (map['minimum_stock'] as int?) ?? 0,
      supplier: map['supplier'] as String?,
    );
  }

  // Convert Product to a map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'sku': sku,
      'description': description,
      'cost': cost,
      'selling_price': sellingPrice,
      'category': category,
      'quantity': quantity,
      'minimum_stock': minimumStock,
      'supplier': supplier,
    };
  }

  // Create a copy of this product with given fields replaced
  Product copyWith({
    String? id,
    String? businessId,
    String? name,
    String? sku,
    String? description,
    double? cost,
    double? sellingPrice,
    String? category,
    int? quantity,
    int? minimumStock,
    String? supplier,
  }) {
    return Product(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      minimumStock: minimumStock ?? this.minimumStock,
      supplier: supplier ?? this.supplier,
    );
  }
}