import 'package:get_it/get_it.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/services/auth_service.dart';
import '../../presentation/auth/bloc/auth_bloc.dart';

final getIt = GetIt.instance;

void setupInjector() {
  // Services
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<AuthService>()),
  );

  // Blocs — singleton now, since it lives above the Navigator in main.dart
  // and must persist across the whole app lifetime, not per-screen.
  getIt.registerLazySingleton<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));
}