import 'package:equatable/equatable.dart';
import 'package:material_tracking/features/materials/domain/models/material_model.dart';
import 'package:material_tracking/features/materials/domain/models/consumption_model.dart';
import 'package:material_tracking/features/materials/domain/models/product_model.dart';

abstract class MaterialsState extends Equatable {
  const MaterialsState();

  @override
  List<Object> get props => [];
}

class MaterialsInitial extends MaterialsState {}

class MaterialsLoading extends MaterialsState {}

class MaterialsLoaded extends MaterialsState {
  final List<MaterialModel> materials;
  final List<ConsumptionModel> consumptions;
  final List<ProductModel> products;
  final bool isOnline;

  const MaterialsLoaded({
    required this.materials,
    required this.consumptions,
    required this.products,
    required this.isOnline,
  });

  @override
  List<Object> get props => [materials, consumptions, products, isOnline];
}

class MaterialsError extends MaterialsState {
  final String message;

  const MaterialsError(this.message);

  @override
  List<Object> get props => [message];
}
