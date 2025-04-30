import 'package:equatable/equatable.dart';
import 'package:material_tracking/features/materials/domain/models/material_model.dart';
import 'package:material_tracking/features/materials/domain/models/consumption_model.dart';

abstract class MaterialsEvent extends Equatable {
  const MaterialsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMaterialsEvent extends MaterialsEvent {
  const LoadMaterialsEvent();
}

class AddMaterialEvent extends MaterialsEvent {
  final MaterialModel material;

  const AddMaterialEvent(this.material);

  @override
  List<Object?> get props => [material];
}

class UpdateMaterialEvent extends MaterialsEvent {
  final MaterialModel material;

  const UpdateMaterialEvent(this.material);

  @override
  List<Object?> get props => [material];
}

class DeleteMaterialEvent extends MaterialsEvent {
  final String materialId;

  const DeleteMaterialEvent(this.materialId);

  @override
  List<Object?> get props => [materialId];
}

class AddConsumptionEvent extends MaterialsEvent {
  final ConsumptionModel consumption;

  const AddConsumptionEvent(this.consumption);

  @override
  List<Object?> get props => [consumption];
}

class UpdateConsumptionEvent extends MaterialsEvent {
  final ConsumptionModel consumption;

  const UpdateConsumptionEvent(this.consumption);

  @override
  List<Object?> get props => [consumption];
}

class DeleteConsumptionEvent extends MaterialsEvent {
  final String consumptionId;

  const DeleteConsumptionEvent(this.consumptionId);

  @override
  List<Object?> get props => [consumptionId];
}

class SyncPendingConsumptionsEvent extends MaterialsEvent {
  const SyncPendingConsumptionsEvent();
}
