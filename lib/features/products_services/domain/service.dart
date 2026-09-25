import 'package:uuid/uuid.dart';

class Service {
  final String id;
  final String businessId;
  String name;
  String? description;
  double price;
  int duration; // in minutes
  String category;

  Service({
    String? id,
    required this.businessId,
    required this.name,
    this.description,
    required this.price,
    required this.duration,
    required this.category,
  }) : id = id ?? const Uuid().v4();

  // Factory method to create a Service from a map (e.g., from database)
  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] as String,
      businessId: map['business_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      duration: (map['duration'] as int?) ?? 0,
      category: map['category'] as String,
    );
  }

  // Convert Service to a map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'category': category,
    };
  }

  // Create a copy of this service with given fields replaced
  Service copyWith({
    String? id,
    String? businessId,
    String? name,
    String? description,
    double? price,
    int? duration,
    String? category,
  }) {
    return Service(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      category: category ?? this.category,
    );
  }
}