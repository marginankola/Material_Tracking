import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'material_model.g.dart';

@HiveType(typeId: 0)
class MaterialModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final double unitCost;
  @HiveField(4)
  final String unitType;
  @HiveField(5)
  final double currentStock;
  @HiveField(6)
  final double minimumStock;
  @HiveField(7)
  final DateTime createdAt;
  @HiveField(8)
  final DateTime updatedAt;

  MaterialModel({
    required this.id,
    required this.name,
    required this.description,
    required this.unitCost,
    required this.unitType,
    required this.currentStock,
    required this.minimumStock,
    required this.createdAt,
    required this.updatedAt,
  });

  MaterialModel copyWith({
    String? id,
    String? name,
    String? description,
    double? unitCost,
    String? unitType,
    double? currentStock,
    double? minimumStock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      unitCost: unitCost ?? this.unitCost,
      unitType: unitType ?? this.unitType,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'unitCost': unitCost,
      'unitType': unitType,
      'currentStock': currentStock,
      'minimumStock': minimumStock,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      unitCost: (json['unitCost'] as num).toDouble(),
      unitType: json['unitType'] as String,
      currentStock: (json['currentStock'] as num).toDouble(),
      minimumStock: (json['minimumStock'] as num).toDouble(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }
}
