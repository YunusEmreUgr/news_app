import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../config/app_config.dart';
import '../network/auth_interceptor.dart';
import '../network/dio_client.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/mock_auth_remote_data_source.dart';
import '../../data/datasources/product_remote_data_source.dart';
import '../../data/datasources/user_remote_data_source.dart';
import '../../data/datasources/news_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/get_user_claims_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/product/get_products_usecase.dart';
import '../../domain/usecases/product/add_product_usecase.dart';
import '../../domain/usecases/user/get_user_profile_usecase.dart';
import '../../domain/usecases/user/update_user_profile_usecase.dart';
import '../../domain/usecases/user/change_password_usecase.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static late GlobalKey<NavigatorState> _navigatorKey;

  static void setup(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;

    // --- Core Dependencies ---
    getIt.registerLazySingleton<AuthInterceptor>(() => AuthInterceptor());
    getIt.registerLazySingleton<DioClient>(() => DioClient(getIt<AuthInterceptor>()));

    // --- Data Sources ---
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AppConfig.instance.useMockData
          ? MockAuthRemoteDataSource()
          : AuthRemoteDataSource(getIt<DioClient>()),
    );
    getIt.registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSource(getIt<DioClient>()),
    );
    getIt.registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSource(getIt<DioClient>()),
    );
    getIt.registerLazySingleton<NewsRemoteDataSource>(
      () => NewsRemoteDataSource(getIt<DioClient>()),
    );

    // --- Repositories ---
    getIt.registerLazySingleton<IAuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
    );
    getIt.registerLazySingleton<IProductRepository>(
      () => ProductRepositoryImpl(getIt<ProductRemoteDataSource>()),
    );
    getIt.registerLazySingleton<IUserRepository>(
      () => UserRepositoryImpl(getIt<UserRemoteDataSource>()),
    );

    // --- Use Cases ---
    getIt.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(getIt<IAuthRepository>()),
    );
    getIt.registerLazySingleton<RegisterUseCase>(
      () => RegisterUseCase(getIt<IAuthRepository>()),
    );
    getIt.registerLazySingleton<GetUserClaimsUseCase>(
      () => GetUserClaimsUseCase(getIt<IAuthRepository>()),
    );
    getIt.registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(getIt<IAuthRepository>()),
    );
    getIt.registerLazySingleton<GetProductsUseCase>(
      () => GetProductsUseCase(getIt<IProductRepository>()),
    );
    getIt.registerLazySingleton<AddProductUseCase>(
      () => AddProductUseCase(getIt<IProductRepository>()),
    );
    getIt.registerLazySingleton<GetUserProfileUseCase>(
      () => GetUserProfileUseCase(getIt<IUserRepository>()),
    );
    getIt.registerLazySingleton<UpdateUserProfileUseCase>(
      () => UpdateUserProfileUseCase(getIt<IUserRepository>()),
    );
    getIt.registerLazySingleton<ChangePasswordUseCase>(
      () => ChangePasswordUseCase(getIt<IUserRepository>()),
    );
  }

  static void onLogout() {
    _navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
