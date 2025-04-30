import '../models/product_model.dart';

abstract class ProductsRepository {
  Future<List<ProductModel>> getAllProducts();
  Future<ProductModel> getProductById(String id);
  Future<void> addProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
  Future<void> cacheProducts(List<ProductModel> products);
  Future<void> cacheProduct(ProductModel product);
  Future<List<ProductModel>> getCachedProducts();
  Future<ProductModel?> getCachedProductById(String id);
  Future<void> clearCache();
}
