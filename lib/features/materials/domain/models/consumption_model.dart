import 'package:hive/hive.dart';

part 'consumption_model.g.dart';

@HiveType(typeId: 1)
class ConsumptionModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String materialId;

  @HiveField(2)
  final double quantity;

  @HiveField(3)
  final String batchNumber;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final String operatorId;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime consumedAt;

  @HiveField(8)
  final String? productId;

  ConsumptionModel({
    required this.id,
    required this.materialId,
    required this.quantity,
    required this.batchNumber,
    this.notes,
    required this.operatorId,
    required this.createdAt,
    required this.consumedAt,
    this.productId,
  });

  factory ConsumptionModel.fromJson(Map<String, dynamic> json) {
    return ConsumptionModel(
      id: json['id'] as String,
      materialId: json['materialId'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      batchNumber: json['batchNumber'] as String,
      notes: json['notes'] as String?,
      operatorId: json['operatorId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      consumedAt: DateTime.parse(json['consumedAt'] as String),
      productId: json['productId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'materialId': materialId,
      'quantity': quantity,
      'batchNumber': batchNumber,
      'notes': notes,
      'operatorId': operatorId,
      'createdAt': createdAt.toIso8601String(),
      'consumedAt': consumedAt.toIso8601String(),
      'productId': productId,
    };
  }
}
