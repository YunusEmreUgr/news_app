import '../../core/errors/api_exception.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/common/api_result.dart';

class ProductRepositoryImpl implements IProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<List<ProductEntity>>> getAllProducts() async {
    try {
      final models = await _remoteDataSource.getAllProducts();
      final entities = models.map((m) => m.toEntity()).toList();
      return ApiResult.success(entities);
    } on ApiException catch (e) {
      return ApiResult.failure(ServerFailure(message: e.message, code: e.errorCode));
    } catch (e) {
      return ApiResult.failure(ServerFailure(message: 'Ürünler yüklenirken bir hata oluştu.'));
    }
  }

  @override
  Future<ApiResult<ProductEntity>> getProductById(int id) async {
    try {
      final model = await _remoteDataSource.getProductById(id);
      return ApiResult.success(model.toEntity());
    } on ApiException catch (e) {
      return ApiResult.failure(ServerFailure(message: e.message, code: e.errorCode));
    } catch (e) {
      return ApiResult.failure(ServerFailure(message: 'Ürün detayı alınamadı.'));
    }
  }

  @override
  Future<ApiResult<bool>> addProduct({
    required String name,
    required double price,
    required int stock,
    required String description,
    required int categoryId,
  }) async {
    try {
      final success = await _remoteDataSource.addProduct(
        name: name,
        price: price,
        stock: stock,
        description: description,
        categoryId: categoryId,
      );
      return ApiResult.success(success);
    } on ApiException catch (e) {
      return ApiResult.failure(ServerFailure(message: e.message, code: e.errorCode));
    } catch (e) {
      return ApiResult.failure(ServerFailure(message: 'Ürün eklenirken bir hata oluştu.'));
    }
  }
}
