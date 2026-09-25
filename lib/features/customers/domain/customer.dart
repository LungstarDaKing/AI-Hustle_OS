import 'package:uuid/uuid.dart';

class Customer {
  final String id;
  final String businessId;
  String name;
  String? phoneNumber;
  String? email;
  String? address;
  String? notes;
  double totalSpent;
  double outstandingBalance;
  DateTime? lastInteraction;
  final DateTime createdAt;
  DateTime updatedAt;

  Customer({
    String? id,
    required this.businessId,
    required this.name,
    this.phoneNumber,
    this.email,
    this.address,
    this.notes,
    this.totalSpent = 0.0,
    this.outstandingBalance = 0.0,
    this.lastInteraction,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Factory method to create a Customer from a map (e.g., from database)
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String,
      businessId: map['business_id'] as String,
      name: map['name'] as String,
      phoneNumber: map['phone_number'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      notes: map['notes'] as String?,
      totalSpent: (map['total_spent'] as num?)?.toDouble() ?? 0.0,
      outstandingBalance: (map['outstanding_balance'] as num?)?.toDouble() ?? 0.0,
      lastInteraction: map['last_interaction'] != null
          ? DateTime.parse(map['last_interaction'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Convert Customer to a map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'notes': notes,
      'total_spent': totalSpent,
      'outstanding_balance': outstandingBalance,
      'last_interaction': lastInteraction?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy of this customer with given fields replaced
  Customer copyWith({
    String? id,
    String? businessId,
    String? name,
    String? phoneNumber,
    String? email,
    String? address,
    String? notes,
    double? totalSpent,
    double? outstandingBalance,
    DateTime? lastInteraction,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      totalSpent: totalSpent ?? this.totalSpent,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}