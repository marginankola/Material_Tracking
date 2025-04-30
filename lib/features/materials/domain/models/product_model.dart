import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final double manufacturingCost;
  final double sellingPrice;
  final double profitMargin;
  final Map<String, double> materialQuantities;
  final Map<String, double> processingCosts;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.manufacturingCost,
    required this.sellingPrice,
    required this.profitMargin,
    required this.materialQuantities,
    required this.processingCosts,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      manufacturingCost: (json['manufacturingCost'] as num).toDouble(),
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      profitMargin: (json['profitMargin'] as num).toDouble(),
      materialQuantities: Map<String, double>.from(
        (json['materialQuantities'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      processingCosts: Map<String, double>.from(
        (json['processingCosts'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'manufacturingCost': manufacturingCost,
      'sellingPrice': sellingPrice,
      'profitMargin': profitMargin,
      'materialQuantities': materialQuantities,
      'processingCosts': processingCosts,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? manufacturingCost,
    double? sellingPrice,
    double? profitMargin,
    Map<String, double>? materialQuantities,
    Map<String, double>? processingCosts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      manufacturingCost: manufacturingCost ?? this.manufacturingCost,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      profitMargin: profitMargin ?? this.profitMargin,
      materialQuantities: materialQuantities ?? this.materialQuantities,
      processingCosts: processingCosts ?? this.processingCosts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    manufacturingCost,
    sellingPrice,
    profitMargin,
    materialQuantities,
    processingCosts,
    createdAt,
    updatedAt,
  ];
}
