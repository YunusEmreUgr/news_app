import '../../data/models/common/api_result.dart';
import '../entities/token_entity.dart';
import '../repositories/i_auth_repository.dart';

class RegisterUseCase {
  final IAuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<ApiResult<TokenEntity>> call({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) {
    return _repository.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );
  }
}
