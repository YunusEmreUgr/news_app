import '../../../data/models/common/api_result.dart';
import '../../repositories/i_user_repository.dart';

class ChangePasswordUseCase {
  final IUserRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<ApiResult<bool>> call(String currentPassword, String newPassword) {
    return _repository.changePassword(currentPassword, newPassword);
  }
}
