import 'auth_remote_data_source.dart';
import '../models/auth/login_request.dart';
import '../models/auth/register_request.dart';
import '../models/auth/token_model.dart';

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  static const String _mockAccessToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjEiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9lbWFpbGFkZHJlc3MiOiJkZW1vQGVudGVycHJpc2UuY29tIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE5OTk5OTk5OTl9.signature';

  @override
  Future<TokenModel> login(LoginRequest request) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (request.email == 'error@enterprise.com') {
      throw Exception('Hatalı e-posta veya şifre (Demo Modu)');
    }

    return TokenModel(
      accessToken: _mockAccessToken,
      refreshToken: 'mock-refresh-token-12345',
      expiration: '2030-12-31T23:59:59Z',
    );
  }

  @override
  Future<TokenModel> register(RegisterRequest request) async {
    await Future.delayed(const Duration(milliseconds: 800));

    return TokenModel(
      accessToken: _mockAccessToken,
      refreshToken: 'mock-refresh-token-12345',
      expiration: '2030-12-31T23:59:59Z',
    );
  }

  @override
  Future<List<String>> getUserClaims() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return ['Admin', 'User', 'EnterpriseDeveloper'];
  }
}
