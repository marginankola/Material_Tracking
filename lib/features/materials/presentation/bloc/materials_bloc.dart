import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_tracking/core/services/connectivity_service.dart';
import 'package:material_tracking/features/materials/data/repositories/firebase_materials_repository.dart';
import 'package:material_tracking/features/materials/data/repositories/local_materials_repository.dart';
import 'package:material_tracking/features/materials/domain/models/material_model.dart';
import 'package:material_tracking/features/materials/domain/models/consumption_model.dart';
import 'package:material_tracking/features/materials/domain/models/product_model.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_event.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_state.dart';

// Bloc
class MaterialsBloc extends Bloc<MaterialsEvent, MaterialsState> {
  final FirebaseMaterialsRepository _firebaseRepository;
  final LocalMaterialsRepository _localRepository;
  final ConnectivityService _connectivityService;
  StreamSubscription? _materialsSubscription;
  StreamSubscription? _connectivitySubscription;
  bool _isOnline = true;

  MaterialsBloc({
    required FirebaseMaterialsRepository firebaseRepository,
    required LocalMaterialsRepository localRepository,
    required ConnectivityService connectivityService,
  })  : _firebaseRepository = firebaseRepository,
        _localRepository = localRepository,
        _connectivityService = connectivityService,
        super(MaterialsInitial()) {
    on<LoadMaterialsEvent>(_onLoadMaterials);
    on<AddMaterialEvent>(_onAddMaterial);
    on<UpdateMaterialEvent>(_onUpdateMaterial);
    on<DeleteMaterialEvent>(_onDeleteMaterial);
    on<AddConsumptionEvent>(_onAddConsumption);
    on<SyncPendingConsumptionsEvent>(_onSyncPendingConsumptions);

    _connectivitySubscription =
        _connectivityService.onConnectivityChanged.listen((isOnline) {
      _isOnline = isOnline;
      if (isOnline) {
        add(SyncPendingConsumptionsEvent());
      }
    });
  }

  Future<void> _onLoadMaterials(
    LoadMaterialsEvent event,
    Emitter<MaterialsState> emit,
  ) async {
    emit(MaterialsLoading());
    try {
      if (_isOnline) {
        _materialsSubscription?.cancel();
        _materialsSubscription = _firebaseRepository.getMaterials().listen((
          materials,
        ) async {
          await _localRepository.cacheMaterials(materials);
          final consumptions =
              await _firebaseRepository.getConsumptions().first;
          final products = await _firebaseRepository.getProducts().first;
          emit(
            MaterialsLoaded(
              materials: materials,
              consumptions: consumptions,
              products: products,
              isOnline: true,
            ),
          );
        });
      } else {
        final materials = await _localRepository.getCachedMaterials();
        final consumptions = await _localRepository.getCachedConsumptions();
        final products = await _localRepository.getCachedProducts();
        emit(
          MaterialsLoaded(
            materials: materials,
            consumptions: consumptions,
            products: products,
            isOnline: false,
          ),
        );
      }
    } catch (e) {
      emit(MaterialsError(e.toString()));
    }
  }

  Future<void> _onAddMaterial(
    AddMaterialEvent event,
    Emitter<MaterialsState> emit,
  ) async {
    try {
      if (_isOnline) {
        await _firebaseRepository.createMaterial(event.material);
      } else {
        emit(MaterialsError('Cannot add material while offline'));
      }
    } catch (e) {
      emit(MaterialsError(e.toString()));
    }
  }

  Future<void> _onUpdateMaterial(
    UpdateMaterialEvent event,
    Emitter<MaterialsState> emit,
  ) async {
    try {
      if (_isOnline) {
        await _firebaseRepository.updateMaterial(event.material);
      } else {
        emit(MaterialsError('Cannot update material while offline'));
      }
    } catch (e) {
      emit(MaterialsError(e.toString()));
    }
  }

  Future<void> _onDeleteMaterial(
    DeleteMaterialEvent event,
    Emitter<MaterialsState> emit,
  ) async {
    try {
      if (_isOnline) {
        await _firebaseRepository.deleteMaterial(event.materialId);
      } else {
        emit(MaterialsError('Cannot delete material while offline'));
      }
    } catch (e) {
      emit(MaterialsError(e.toString()));
    }
  }

  Future<void> _onAddConsumption(
    AddConsumptionEvent event,
    Emitter<MaterialsState> emit,
  ) async {
    try {
      if (_isOnline) {
        await _firebaseRepository.createConsumption(event.consumption);
      } else {
        await _localRepository.cacheConsumption(event.consumption);
        emit(MaterialsError('Consumption cached for offline use'));
      }
    } catch (e) {
      emit(MaterialsError(e.toString()));
    }
  }

  Future<void> _onSyncPendingConsumptions(
    SyncPendingConsumptionsEvent event,
    Emitter<MaterialsState> emit,
  ) async {
    try {
      final pendingConsumptions =
          await _localRepository.getPendingConsumptions();
      for (final consumption in pendingConsumptions) {
        await _firebaseRepository.createConsumption(consumption);
        await _localRepository.removePendingConsumption(consumption.id);
      }
    } catch (e) {
      emit(MaterialsError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _materialsSubscription?.cancel();
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
