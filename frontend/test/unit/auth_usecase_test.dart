import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_template/core/errors/failures.dart';
import 'package:frontend_template/data/models/common/api_result.dart';
import 'package:frontend_template/domain/entities/token_entity.dart';
import 'package:frontend_template/domain/repositories/i_auth_repository.dart';
import 'package:frontend_template/domain/usecases/login_usecase.dart';

class FakeAuthRepository implements IAuthRepository {
  @override
  Future<ApiResult<TokenEntity>> login(String email, String password) async {
    if (email == 'admin@test.com' && password == '123456') {
      return ApiResult.success(const TokenEntity(
        accessToken: 'fake_access_token',
        refreshToken: 'fake_refresh_token',
      ));
    }
    return ApiResult.failure(
      const ServerFailure(message: 'Hatalı giriş'),
    );
  }

  @override
  Future<ApiResult<TokenEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    return ApiResult.success(const TokenEntity(
      accessToken: 'fake_access_token',
      refreshToken: 'fake_refresh_token',
    ));
  }

  @override
  Future<ApiResult<List<String>>> getUserClaims() async {
    return ApiResult.success(const ['Admin', 'User']);
  }

  @override
  Future<void> logout() async {}
}

void main() {
  late LoginUseCase loginUseCase;
  late FakeAuthRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeAuthRepository();
    loginUseCase = LoginUseCase(fakeRepository);
  });

  test('LoginUseCase - Basarili giris token dönmeli', () async {
    final result = await loginUseCase('admin@test.com', '123456');
    expect(result.isSuccess, true);
    expect(result.dataOrNull?.accessToken, 'fake_access_token');
  });

  test('LoginUseCase - Hatali giris failure dönmeli', () async {
    final result = await loginUseCase('wrong@test.com', 'wrong');
    expect(result.isFailure, true);
  });
}
