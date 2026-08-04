import 'package:flutter/material.dart';
import '../../core/init/service_locator.dart';
import '../../data/models/user/user_model.dart';
import '../../domain/usecases/user/get_user_profile_usecase.dart';
import '../../domain/usecases/user/update_user_profile_usecase.dart';
import '../../domain/usecases/user/change_password_usecase.dart';

enum UserState { initial, loading, loaded, error }

class UserProvider extends ChangeNotifier {
  final GetUserProfileUseCase _getUserProfileUseCase = getIt<GetUserProfileUseCase>();
  final UpdateUserProfileUseCase _updateUserProfileUseCase = getIt<UpdateUserProfileUseCase>();
  final ChangePasswordUseCase _changePasswordUseCase = getIt<ChangePasswordUseCase>();

  UserState _state = UserState.initial;
  UserModel? _profile;
  String? _errorMessage;

  UserState get state => _state;
  UserModel? get profile => _profile;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == UserState.loading;

  Future<void> fetchProfile() async {
    _state = UserState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _getUserProfileUseCase();
    if (result.isSuccess) {
      _profile = result.dataOrNull;
      _state = UserState.loaded;
    } else {
      _state = UserState.error;
      _errorMessage = result.failureOrNull?.message ?? 'Profil bilgileri yüklenemedi.';
    }
    notifyListeners();
  }

  Future<bool> updateProfile(String firstName, String lastName) async {
    final result = await _updateUserProfileUseCase(firstName, lastName);
    if (result.isSuccess) {
      await fetchProfile();
      return true;
    } else {
      _errorMessage = result.failureOrNull?.message ?? 'Profil güncellenemedi.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final result = await _changePasswordUseCase(currentPassword, newPassword);
    if (result.isSuccess) {
      return true;
    } else {
      _errorMessage = result.failureOrNull?.message ?? 'Şifre değiştirilemedi.';
      notifyListeners();
      return false;
    }
  }
}
