import 'package:material_tracking/features/materials/domain/models/material_model.dart';
import 'package:material_tracking/features/materials/domain/models/consumption_model.dart';
import 'package:material_tracking/features/materials/domain/models/product_model.dart';

abstract class MaterialsRepository {
  // Materials
  Stream<List<MaterialModel>> getMaterials();
  Future<MaterialModel> getMaterialById(String id);
  Future<MaterialModel> createMaterial(MaterialModel material);
  Future<void> updateMaterial(MaterialModel material);
  Future<void> deleteMaterial(String id);
  Stream<List<MaterialModel>> getLowStockMaterials();

  // Consumption
  Stream<List<ConsumptionModel>> getConsumptions();
  Future<ConsumptionModel> createConsumption(ConsumptionModel consumption);
  Future<List<ConsumptionModel>> getConsumptionsByMaterial(String materialId);
  Future<List<ConsumptionModel>> getConsumptionsByOperator(String operatorId);
  Future<List<ConsumptionModel>> getConsumptionsByDateRange(
    DateTime start,
    DateTime end,
  );

  // Products
  Stream<List<ProductModel>> getProducts();
  Future<ProductModel> getProductById(String id);
  Future<ProductModel> createProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
  Future<double> calculateProductCost(String productId);
  Future<void> updateProductPricing(
    String productId,
    double sellingPrice,
    double profitMargin,
  );
}
