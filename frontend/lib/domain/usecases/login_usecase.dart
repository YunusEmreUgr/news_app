import '../../data/models/common/api_result.dart';
import '../entities/token_entity.dart';
import '../repositories/i_auth_repository.dart';

class LoginUseCase {
  final IAuthRepository _repository;

  LoginUseCase(this._repository);

  Future<ApiResult<TokenEntity>> call(String email, String password) {
    return _repository.login(email, password);
  }
}
