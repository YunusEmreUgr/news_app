import '../../data/models/common/api_result.dart';
import '../entities/token_entity.dart';

abstract class IAuthRepository {
  Future<ApiResult<TokenEntity>> login(String email, String password);
  Future<ApiResult<TokenEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });
  Future<ApiResult<List<String>>> getUserClaims();
  Future<void> logout();
}
