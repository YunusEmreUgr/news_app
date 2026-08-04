import '../../core/network/dio_client.dart';
import '../models/user/user_model.dart';

class UserRemoteDataSource {
  final DioClient _dioClient;

  UserRemoteDataSource(this._dioClient);

  Future<UserModel> getProfile() async {
    final response = await _dioClient.get('/users/profile');
    final data = response.containsKey('data') ? response['data'] : response;
    return UserModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<bool> updateProfile(String firstName, String lastName) async {
    final response = await _dioClient.put(
      '/users/profile',
      data: {
        'firstName': firstName,
        'lastName': lastName,
      },
    );
    final success = response['success'];
    return success == true || success?.toString() == 'true';
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final response = await _dioClient.post(
      '/users/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    final success = response['success'];
    return success == true || success?.toString() == 'true';
  }
}
