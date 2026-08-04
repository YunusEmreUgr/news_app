import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/init/service_locator.dart';
import '../../core/storage/token_storage.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/get_user_claims_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase = getIt<LoginUseCase>();
  final RegisterUseCase _registerUseCase = getIt<RegisterUseCase>();
  final GetUserClaimsUseCase _getUserClaimsUseCase = getIt<GetUserClaimsUseCase>();
  final LogoutUseCase _logoutUseCase = getIt<LogoutUseCase>();

  AuthState _state = AuthState.initial;
  String? _errorMessage;
  List<String> _userClaims = [];
  int? _userId;
  String? _userEmail;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  List<String> get userClaims => _userClaims;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  int? get userId => _userId;
  String? get userEmail => _userEmail;

  /// Check if user has Admin or Publisher claims (can publish news)
  bool get canPublish =>
      isAuthenticated &&
      (_userClaims.contains('Admin') || _userClaims.contains('Publisher'));

  /// Check if user has Admin claim
  bool get isAdmin => isAuthenticated && _userClaims.contains('Admin');

  Future<void> checkAuthStatus() async {
    _state = AuthState.loading;
    notifyListeners();

    final hasToken = await TokenStorage.hasToken();
    if (hasToken) {
      _state = AuthState.authenticated;
      _parseTokenClaims();
      await fetchUserClaims();
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _loginUseCase(email, password);

    if (result.isSuccess) {
      _state = AuthState.authenticated;
      _userEmail = email;
      _parseTokenClaims();
      await fetchUserClaims();
      notifyListeners();
      return true;
    } else {
      _state = AuthState.error;
      _errorMessage = result.failureOrNull?.message ?? 'Giriş yapılamadı.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _registerUseCase(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );

    if (result.isSuccess) {
      _state = AuthState.authenticated;
      _userEmail = email;
      _parseTokenClaims();
      await fetchUserClaims();
      notifyListeners();
      return true;
    } else {
      _state = AuthState.error;
      _errorMessage = result.failureOrNull?.message ?? 'Kayıt olunamadı.';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchUserClaims() async {
    try {
      final result = await _getUserClaimsUseCase();
      if (result.isSuccess) {
        _userClaims = result.dataOrNull ?? [];
        notifyListeners();
      }
    } catch (_) {
      // Claims fetch failed silently
    }
  }

  Future<void> logout() async {
    await _logoutUseCase();
    _state = AuthState.unauthenticated;
    _userClaims = [];
    _userId = null;
    _userEmail = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Parse JWT token to extract userId
  void _parseTokenClaims() {
    TokenStorage.getAccessToken().then((token) {
      if (token != null && token.isNotEmpty) {
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            final payload = parts[1];
            // Add padding if needed
            final normalized = base64Url.normalize(payload);
            final decoded = utf8.decode(base64Url.decode(normalized));
            final Map<String, dynamic> claims = json.decode(decoded);

            // Extract userId from common JWT claim types
            final userIdStr = claims['nameid'] ??
                claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
                claims['userid'] ??
                claims['sub'];

            if (userIdStr != null) {
              _userId = int.tryParse(userIdStr.toString());
            }

            // Extract email
            _userEmail ??= claims['email'] ??
                claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'];
          }
        } catch (_) {
          // Token parse failed
        }
      }
    });
  }
}
