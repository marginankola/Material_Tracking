import 'package:hive/hive.dart';

part 'consumption_model.g.dart';

@HiveType(typeId: 1)
class ConsumptionModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String materialId;

  @HiveField(2)
  final String operatorId;

  @HiveField(3)
  final double quantity;

  @HiveField(4)
  final String? batchNumber;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final DateTime consumedAt;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final String? productId;

  ConsumptionModel({
    required this.id,
    required this.materialId,
    required this.operatorId,
    required this.quantity,
    this.batchNumber,
    this.notes,
    required this.consumedAt,
    required this.createdAt,
    this.productId,
  });

  factory ConsumptionModel.fromJson(Map<String, dynamic> json) {
    return ConsumptionModel(
      id: json['id'] as String,
      materialId: json['materialId'] as String,
      operatorId: json['operatorId'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      batchNumber: json['batchNumber'] as String?,
      notes: json['notes'] as String?,
      consumedAt: DateTime.parse(json['consumedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      productId: json['productId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'materialId': materialId,
      'operatorId': operatorId,
      'quantity': quantity,
      'batchNumber': batchNumber,
      'notes': notes,
      'consumedAt': consumedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'productId': productId,
    };
  }
}
