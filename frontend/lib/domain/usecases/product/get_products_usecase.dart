import '../../../data/models/common/api_result.dart';
import '../../entities/product_entity.dart';
import '../../repositories/i_product_repository.dart';

class GetProductsUseCase {
  final IProductRepository _repository;

  GetProductsUseCase(this._repository);

  Future<ApiResult<List<ProductEntity>>> call() {
    return _repository.getAllProducts();
  }
}
