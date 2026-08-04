import '../../core/errors/api_exception.dart';
import '../../core/errors/failures.dart';
import '../../core/storage/token_storage.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth/login_request.dart';
import '../models/auth/register_request.dart';
import '../models/common/api_result.dart';
import '../../domain/entities/token_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<TokenEntity>> login(String email, String password) async {
    try {
      final tokenModel = await _remoteDataSource.login(
        LoginRequest(email: email, password: password),
      );

      await TokenStorage.saveTokens(
        accessToken: tokenModel.accessToken,
        refreshToken: tokenModel.refreshToken,
      );

      return ApiResult.success(tokenModel.toEntity());
    } on ApiException catch (e) {
      return ApiResult.failure(
        ServerFailure(message: e.message, code: e.errorCode),
      );
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(message: 'Giriş yapılırken beklenmeyen bir hata oluştu.'),
      );
    }
  }

  @override
  Future<ApiResult<TokenEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final tokenModel = await _remoteDataSource.register(
        RegisterRequest(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
        ),
      );

      await TokenStorage.saveTokens(
        accessToken: tokenModel.accessToken,
        refreshToken: tokenModel.refreshToken,
      );

      return ApiResult.success(tokenModel.toEntity());
    } on ApiException catch (e) {
      return ApiResult.failure(
        ServerFailure(message: e.message, code: e.errorCode),
      );
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(message: 'Kayıt olunurken beklenmeyen bir hata oluştu.'),
      );
    }
  }

  @override
  Future<ApiResult<List<String>>> getUserClaims() async {
    try {
      final claims = await _remoteDataSource.getUserClaims();
      return ApiResult.success(claims);
    } on ApiException catch (e) {
      return ApiResult.failure(
        ServerFailure(message: e.message, code: e.errorCode),
      );
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(message: 'Yetkiler çekilirken bir hata oluştu.'),
      );
    }
  }

  @override
  Future<void> logout() async {
    await TokenStorage.clearTokens();
  }
}
