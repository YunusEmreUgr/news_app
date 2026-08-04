import '../../core/errors/api_exception.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../datasources/user_remote_data_source.dart';
import '../models/common/api_result.dart';
import '../models/user/user_model.dart';

class UserRepositoryImpl implements IUserRepository {
  final UserRemoteDataSource _remoteDataSource;

  UserRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<UserModel>> getProfile() async {
    try {
      final user = await _remoteDataSource.getProfile();
      return ApiResult.success(user);
    } on ApiException catch (e) {
      return ApiResult.failure(ServerFailure(message: e.message, code: e.errorCode));
    } catch (e) {
      return ApiResult.failure(ServerFailure(message: 'Profil yüklenirken hata oluştu.'));
    }
  }

  @override
  Future<ApiResult<bool>> updateProfile(String firstName, String lastName) async {
    try {
      final success = await _remoteDataSource.updateProfile(firstName, lastName);
      return ApiResult.success(success);
    } on ApiException catch (e) {
      return ApiResult.failure(ServerFailure(message: e.message, code: e.errorCode));
    } catch (e) {
      return ApiResult.failure(ServerFailure(message: 'Profil güncellenirken hata oluştu.'));
    }
  }

  @override
  Future<ApiResult<bool>> changePassword(String currentPassword, String newPassword) async {
    try {
      final success = await _remoteDataSource.changePassword(currentPassword, newPassword);
      return ApiResult.success(success);
    } on ApiException catch (e) {
      return ApiResult.failure(ServerFailure(message: e.message, code: e.errorCode));
    } catch (e) {
      return ApiResult.failure(ServerFailure(message: 'Şifre değiştirilirken hata oluştu.'));
    }
  }
}
