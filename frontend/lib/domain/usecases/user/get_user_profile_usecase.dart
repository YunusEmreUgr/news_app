import '../../../data/models/common/api_result.dart';
import '../../../data/models/user/user_model.dart';
import '../../repositories/i_user_repository.dart';

class GetUserProfileUseCase {
  final IUserRepository _repository;

  GetUserProfileUseCase(this._repository);

  Future<ApiResult<UserModel>> call() {
    return _repository.getProfile();
  }
}
