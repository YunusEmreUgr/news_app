import '../../../data/models/common/api_result.dart';
import '../../repositories/i_user_repository.dart';

class UpdateUserProfileUseCase {
  final IUserRepository _repository;

  UpdateUserProfileUseCase(this._repository);

  Future<ApiResult<bool>> call(String firstName, String lastName) {
    return _repository.updateProfile(firstName, lastName);
  }
}
