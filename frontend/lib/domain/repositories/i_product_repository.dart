import '../entities/product_entity.dart';
import '../../data/models/common/api_result.dart';

abstract class IProductRepository {
  Future<ApiResult<List<ProductEntity>>> getAllProducts();
  Future<ApiResult<ProductEntity>> getProductById(int id);
  Future<ApiResult<bool>> addProduct({
    required String name,
    required double price,
    required int stock,
    required String description,
    required int categoryId,
  });
}
