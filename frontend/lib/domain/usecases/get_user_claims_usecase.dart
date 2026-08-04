import '../../data/models/common/api_result.dart';
import '../repositories/i_auth_repository.dart';

class GetUserClaimsUseCase {
  final IAuthRepository _repository;

  GetUserClaimsUseCase(this._repository);

  Future<ApiResult<List<String>>> call() {
    return _repository.getUserClaims();
  }
}
