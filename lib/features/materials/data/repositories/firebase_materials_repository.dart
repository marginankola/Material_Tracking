import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_tracking/core/services/firebase_service.dart';
import 'package:material_tracking/features/materials/domain/models/material_model.dart';
import 'package:material_tracking/features/materials/domain/models/consumption_model.dart';
import 'package:material_tracking/features/materials/domain/models/product_model.dart';
import 'package:material_tracking/features/materials/domain/repositories/materials_repository.dart';

class FirebaseMaterialsRepository implements MaterialsRepository {
  final FirebaseService _firebaseService;
  final CollectionReference _materialsCollection;
  final CollectionReference _consumptionsCollection;
  final String _productsCollection = 'products';

  FirebaseMaterialsRepository(this._firebaseService)
      : _materialsCollection =
            _firebaseService.firestore.collection('materials'),
        _consumptionsCollection =
            _firebaseService.firestore.collection('consumptions');

  // Materials
  @override
  Stream<List<MaterialModel>> getMaterials() {
    return _materialsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              MaterialModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<MaterialModel> getMaterialById(String id) async {
    final doc = await _materialsCollection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Material not found');
    }
    return MaterialModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> addMaterial(MaterialModel material) async {
    await _materialsCollection.doc(material.id).set(material.toJson());
  }

  @override
  Future<void> updateMaterial(MaterialModel material) async {
    await _materialsCollection.doc(material.id).update(material.toJson());
  }

  @override
  Future<void> deleteMaterial(String materialId) async {
    await _materialsCollection.doc(materialId).delete();
  }

  @override
  Stream<List<MaterialModel>> getLowStockMaterials() {
    return _materialsCollection
        .where('currentStock', isLessThanOrEqualTo: 'minimumStock')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    MaterialModel.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  // Consumptions
  @override
  Stream<List<ConsumptionModel>> getConsumptions() {
    return _consumptionsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              ConsumptionModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<void> addConsumption(ConsumptionModel consumption) async {
    await _consumptionsCollection.doc(consumption.id).set(consumption.toJson());
  }

  @override
  Future<void> updateConsumption(ConsumptionModel consumption) async {
    await _consumptionsCollection
        .doc(consumption.id)
        .update(consumption.toJson());
  }

  @override
  Future<void> deleteConsumption(String consumptionId) async {
    await _consumptionsCollection.doc(consumptionId).delete();
  }

  @override
  Future<List<ConsumptionModel>> getConsumptionsByMaterial(
    String materialId,
  ) async {
    try {
      final querySnapshot = await _consumptionsCollection
          .where('materialId', isEqualTo: materialId)
          .orderBy('consumedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) =>
                ConsumptionModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception(
        'Failed to get consumptions by material: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ConsumptionModel>> getConsumptionsByOperator(
    String operatorId,
  ) async {
    try {
      final querySnapshot = await _consumptionsCollection
          .where('operatorId', isEqualTo: operatorId)
          .orderBy('consumedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) =>
                ConsumptionModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception(
        'Failed to get consumptions by operator: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ConsumptionModel>> getConsumptionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final querySnapshot = await _consumptionsCollection
          .where(
            'consumedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start),
          )
          .where('consumedAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('consumedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) =>
                ConsumptionModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception(
        'Failed to get consumptions by date range: ${e.toString()}',
      );
    }
  }

  // Products
  @override
  Stream<List<ProductModel>> getProducts() {
    return _firebaseService.firestore
        .collection(_productsCollection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    ProductModel.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final doc = await _firebaseService.firestore
        .collection(_productsCollection)
        .doc(id)
        .get();
    if (!doc.exists) {
      throw Exception('Product not found');
    }
    return ProductModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final docRef = await _firebaseService.firestore
          .collection(_productsCollection)
          .add(product.toJson());
      return product.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create product: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firebaseService.firestore
          .collection(_productsCollection)
          .doc(product.id)
          .update(product.toJson());
    } catch (e) {
      throw Exception('Failed to update product: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _firebaseService.firestore
          .collection(_productsCollection)
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete product: ${e.toString()}');
    }
  }

  @override
  Future<double> calculateProductCost(String productId) async {
    try {
      final product = await getProductById(productId);
      double totalCost = 0;

      // Calculate material costs
      for (final entry in product.materialQuantities.entries) {
        final material = await getMaterialById(entry.key);
        totalCost += material.unitCost * entry.value;
      }

      // Add processing costs
      totalCost += product.processingCosts.values.fold(0, (a, b) => a + b);

      return totalCost;
    } catch (e) {
      throw Exception('Failed to calculate product cost: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProductPricing(
    String productId,
    double sellingPrice,
    double profitMargin,
  ) async {
    try {
      final manufacturingCost = await calculateProductCost(productId);
      await _firebaseService.firestore
          .collection(_productsCollection)
          .doc(productId)
          .update({
        'manufacturingCost': manufacturingCost,
        'sellingPrice': sellingPrice,
        'profitMargin': profitMargin,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update product pricing: ${e.toString()}');
    }
  }

  @override
  Future<MaterialModel> createMaterial(MaterialModel material) async {
    final docRef =
        _firebaseService.firestore.collection('materials').doc(material.id);
    await docRef.set(material.toJson());
    return material;
  }

  @override
  Future<ConsumptionModel> createConsumption(
      ConsumptionModel consumption) async {
    final docRef = _firebaseService.firestore
        .collection('consumptions')
        .doc(consumption.id);
    await docRef.set(consumption.toJson());
    return consumption;
  }

  @override
  Future<void> updateMaterialStock(String id, double quantity) async {
    final docRef = _firebaseService.firestore.collection('materials').doc(id);
    await _firebaseService.firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) {
        throw Exception('Material not found');
      }
      final currentStock = doc.data()!['currentStock'] as double;
      transaction.update(docRef, {'currentStock': currentStock - quantity});
    });
  }
}
