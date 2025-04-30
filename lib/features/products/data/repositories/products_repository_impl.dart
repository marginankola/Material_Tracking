import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../../domain/models/product_model.dart';
import '../../domain/repositories/products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final FirebaseFirestore _firestore;
  static const String productsBox = 'products';

  ProductsRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final snapshot = await _firestore.collection('products').get();
    return snapshot.docs
        .map((doc) => ProductModel.fromJson({
              'id': doc.id,
              ...doc.data(),
            }))
        .toList();
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final doc = await _firestore.collection('products').doc(id).get();
    if (!doc.exists) {
      throw Exception('Product not found');
    }
    return ProductModel.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });
  }

  @override
  Future<void> addProduct(ProductModel product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .set(product.toJson());
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toJson());
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final box = Hive.box<Map>(productsBox);
    final Map<String, Map> data = {
      for (var product in products) product.id: product.toJson()
    };
    await box.putAll(data);
  }

  @override
  Future<void> cacheProduct(ProductModel product) async {
    final box = Hive.box<Map>(productsBox);
    await box.put(product.id, product.toJson());
  }

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    final box = Hive.box<Map>(productsBox);
    return box.values
        .map((json) => ProductModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<ProductModel?> getCachedProductById(String id) async {
    final box = Hive.box<Map>(productsBox);
    final json = box.get(id);
    if (json == null) return null;
    return ProductModel.fromJson(Map<String, dynamic>.from(json));
  }

  @override
  Future<void> clearCache() async {
    final box = Hive.box<Map>(productsBox);
    await box.clear();
  }
}
