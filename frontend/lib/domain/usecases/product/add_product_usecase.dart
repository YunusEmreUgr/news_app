import '../../../data/models/common/api_result.dart';
import '../../repositories/i_product_repository.dart';

class AddProductUseCase {
  final IProductRepository _repository;

  AddProductUseCase(this._repository);

  Future<ApiResult<bool>> call({
    required String name,
    required double price,
    required int stock,
    required String description,
    required int categoryId,
  }) {
    return _repository.addProduct(
      name: name,
      price: price,
      stock: stock,
      description: description,
      categoryId: categoryId,
    );
  }
}
