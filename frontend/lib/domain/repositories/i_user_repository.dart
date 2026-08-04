import '../../data/models/common/api_result.dart';
import '../../data/models/user/user_model.dart';

abstract class IUserRepository {
  Future<ApiResult<UserModel>> getProfile();
  Future<ApiResult<bool>> updateProfile(String firstName, String lastName);
  Future<ApiResult<bool>> changePassword(String currentPassword, String newPassword);
}
