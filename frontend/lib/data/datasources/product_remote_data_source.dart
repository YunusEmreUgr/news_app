import '../../core/network/dio_client.dart';
import '../models/product/product_model.dart';

class ProductRemoteDataSource {
  final DioClient _dioClient;

  ProductRemoteDataSource(this._dioClient);

  Future<List<ProductModel>> getAllProducts() async {
    final response = await _dioClient.get('/products');
    final data = response.containsKey('data') ? response['data'] : response;
    if (data is List) {
      return data.map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }

  Future<ProductModel> getProductById(int id) async {
    final response = await _dioClient.get('/products/$id');
    final data = response.containsKey('data') ? response['data'] : response;
    return ProductModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<bool> addProduct({
    required String name,
    required double price,
    required int stock,
    required String description,
    required int categoryId,
  }) async {
    final response = await _dioClient.post(
      '/products',
      data: {
        'name': name,
        'price': price,
        'stock': stock,
        'description': description,
        'categoryId': categoryId,
      },
    );
    final success = response['success'];
    return success == true || success?.toString() == 'true';
  }
}
