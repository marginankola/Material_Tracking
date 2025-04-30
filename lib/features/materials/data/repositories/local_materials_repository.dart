import 'package:hive/hive.dart';
import 'package:material_tracking/features/materials/domain/models/material_model.dart';
import 'package:material_tracking/features/materials/domain/models/consumption_model.dart';
import 'package:material_tracking/features/materials/domain/models/product_model.dart';
import 'package:material_tracking/features/materials/domain/repositories/materials_repository.dart';

class LocalMaterialsRepository implements MaterialsRepository {
  static const String materialsBox = 'materials';
  static const String consumptionsBox = 'consumptions';
  static const String productsBox = 'products';
  static const String pendingConsumptionsBox = 'pending_consumptions';

  final Box<MaterialModel> _materialsBox;
  final Box<ConsumptionModel> _consumptionsBox;

  LocalMaterialsRepository({
    required Box<MaterialModel> materialsBox,
    required Box<ConsumptionModel> consumptionsBox,
  })  : _materialsBox = materialsBox,
        _consumptionsBox = consumptionsBox;

  Future<void> init() async {
    await Hive.openBox<Map>(materialsBox);
    await Hive.openBox<Map>(consumptionsBox);
    await Hive.openBox<Map>(productsBox);
    await Hive.openBox<Map>(pendingConsumptionsBox);
  }

  // Materials
  Future<void> cacheMaterials(List<MaterialModel> materials) async {
    final box = Hive.box<Map>(materialsBox);
    await box.clear();
    await box.putAll(
      Map.fromEntries(materials.map((m) => MapEntry(m.id, m.toJson()))),
    );
  }

  Future<List<MaterialModel>> getCachedMaterials() async {
    final box = Hive.box<Map>(materialsBox);
    return box.values
        .map((json) => MaterialModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<MaterialModel?> getCachedMaterialById(String id) async {
    final box = Hive.box<Map>(materialsBox);
    final json = box.get(id);
    if (json == null) return null;
    return MaterialModel.fromJson(Map<String, dynamic>.from(json));
  }

  Future<void> cacheMaterial(MaterialModel material) async {
    final box = Hive.box<Map>(materialsBox);
    await box.put(material.id, material.toJson());
  }

  // Consumptions
  Future<void> cacheConsumptions(List<ConsumptionModel> consumptions) async {
    final box = Hive.box<Map>(consumptionsBox);
    final Map<String, Map> data = {
      for (var consumption in consumptions) consumption.id: consumption.toJson()
    };
    await box.putAll(data);
  }

  Future<List<ConsumptionModel>> getCachedConsumptions() async {
    final box = Hive.box<Map>(consumptionsBox);
    return box.values
        .map(
          (json) => ConsumptionModel.fromJson(Map<String, dynamic>.from(json)),
        )
        .toList();
  }

  Future<void> cacheConsumption(ConsumptionModel consumption) async {
    final box = Hive.box<Map>(consumptionsBox);
    await box.put(consumption.id, consumption.toJson());
  }

  // Pending Consumptions (for offline mode)
  Future<void> addPendingConsumption(ConsumptionModel consumption) async {
    final box = Hive.box<Map>(pendingConsumptionsBox);
    await box.put(consumption.id, consumption.toJson());
  }

  Future<List<ConsumptionModel>> getPendingConsumptions() async {
    final box = Hive.box<Map>(pendingConsumptionsBox);
    return box.values
        .map(
          (json) => ConsumptionModel.fromJson(Map<String, dynamic>.from(json)),
        )
        .toList();
  }

  Future<void> removePendingConsumption(String id) async {
    final box = Hive.box<Map>(pendingConsumptionsBox);
    await box.delete(id);
  }

  // Products
  Future<void> cacheProducts(List<ProductModel> products) async {
    final box = Hive.box<Map>(productsBox);
    await box.clear();
    await box.putAll(
      Map.fromEntries(products.map((p) => MapEntry(p.id, p.toJson()))),
    );
  }

  Future<List<ProductModel>> getCachedProducts() async {
    final box = Hive.box<Map>(productsBox);
    return box.values
        .map((json) => ProductModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<ProductModel?> getCachedProductById(String id) async {
    final box = Hive.box<Map>(productsBox);
    final json = box.get(id);
    if (json == null) return null;
    return ProductModel.fromJson(Map<String, dynamic>.from(json));
  }

  // Clear all cached data
  Future<void> clearAllCaches() async {
    await Hive.box<Map>(materialsBox).clear();
    await Hive.box<Map>(consumptionsBox).clear();
    await Hive.box<Map>(productsBox).clear();
    // Don't clear pending consumptions as they need to be synced
  }

  @override
  Stream<List<MaterialModel>> getMaterials() {
    return Stream.value(_materialsBox.values.toList());
  }

  @override
  Future<void> addMaterial(MaterialModel material) async {
    await _materialsBox.put(material.id, material);
  }

  @override
  Future<void> updateMaterial(MaterialModel material) async {
    await _materialsBox.put(material.id, material);
  }

  @override
  Future<void> deleteMaterial(String materialId) async {
    await _materialsBox.delete(materialId);
  }

  @override
  Stream<List<ConsumptionModel>> getConsumptions() {
    return Stream.value(_consumptionsBox.values.toList());
  }

  @override
  Future<void> addConsumption(ConsumptionModel consumption) async {
    await _consumptionsBox.put(consumption.id, consumption);
  }

  @override
  Future<void> updateConsumption(ConsumptionModel consumption) async {
    await _consumptionsBox.put(consumption.id, consumption);
  }

  @override
  Future<void> deleteConsumption(String consumptionId) async {
    await _consumptionsBox.delete(consumptionId);
  }

  @override
  Stream<List<MaterialModel>> getLowStockMaterials() {
    return Stream.value(
      _materialsBox.values
          .where((material) => material.currentStock <= material.minimumStock)
          .toList(),
    );
  }

  @override
  Future<List<ConsumptionModel>> getConsumptionsByMaterial(
      String materialId) async {
    return _consumptionsBox.values
        .where((consumption) => consumption.materialId == materialId)
        .toList();
  }

  @override
  Future<List<ConsumptionModel>> getConsumptionsByOperator(
      String operatorId) async {
    return _consumptionsBox.values
        .where((consumption) => consumption.operatorId == operatorId)
        .toList();
  }

  @override
  Future<List<ConsumptionModel>> getConsumptionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _consumptionsBox.values
        .where((consumption) =>
            consumption.consumedAt.isAfter(startDate) &&
            consumption.consumedAt.isBefore(endDate))
        .toList();
  }

  @override
  Future<MaterialModel> getMaterialById(String id) async {
    final material = await getCachedMaterialById(id);
    if (material == null) {
      throw Exception('Material not found');
    }
    return material;
  }

  @override
  Future<MaterialModel> createMaterial(MaterialModel material) async {
    await _materialsBox.put(material.id, material);
    return material;
  }

  @override
  Future<ConsumptionModel> createConsumption(
      ConsumptionModel consumption) async {
    await _consumptionsBox.put(consumption.id, consumption);
    return consumption;
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final product = await getCachedProductById(id);
    if (product == null) {
      throw Exception('Product not found');
    }
    return product;
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    final box = Hive.box<Map>(productsBox);
    await box.put(product.id, product.toJson());
    return product;
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    final box = Hive.box<Map>(productsBox);
    await box.put(product.id, product.toJson());
  }

  @override
  Future<void> deleteProduct(String id) async {
    final box = Hive.box<Map>(productsBox);
    await box.delete(id);
  }

  @override
  Future<double> calculateProductCost(String productId) async {
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
  }

  @override
  Future<void> updateProductPricing(
    String productId,
    double sellingPrice,
    double profitMargin,
  ) async {
    final manufacturingCost = await calculateProductCost(productId);
    final box = Hive.box<Map>(productsBox);
    final product = await getProductById(productId);
    await box.put(productId, {
      ...product.toJson(),
      'manufacturingCost': manufacturingCost,
      'sellingPrice': sellingPrice,
      'profitMargin': profitMargin,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Stream<List<ProductModel>> getProducts() {
    final box = Hive.box<Map>(productsBox);
    return Stream.value(
      box.values
          .map((json) => ProductModel.fromJson(Map<String, dynamic>.from(json)))
          .toList(),
    );
  }
}
