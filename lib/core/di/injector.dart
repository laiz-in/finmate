import 'package:finmate/presentation/liabilities/bloc/lent_cubit.dart';
import 'package:finmate/presentation/liabilities/bloc/owe_cubit.dart';
import 'package:get_it/get_it.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/lent_repository.dart';
import '../../data/repositories/owe_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/services/expense_service.dart';
import '../../data/services/lent_service.dart';
import '../../data/services/owe_service.dart';
import '../../data/services/profile_service.dart';
import '../../presentation/auth/bloc/auth_bloc.dart';
import '../../presentation/expense/bloc/expense_cubit.dart';
import '../../presentation/profile/bloc/profile_cubit.dart';
import '../connectivity/connectivity_cubit.dart';

final getIt = GetIt.instance;

void setupInjector() {
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerLazySingleton<ProfileService>(() => ProfileService());
  getIt.registerLazySingleton<ExpenseService>(() => ExpenseService());
  getIt.registerLazySingleton<OweService>(() => OweService());
  getIt.registerLazySingleton<LentService>(() => LentService());

  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(getIt<AuthService>()));
  getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepository(getIt<ProfileService>()));
  getIt.registerLazySingleton<ExpenseRepository>(() => ExpenseRepository(getIt<ExpenseService>()));
  getIt.registerLazySingleton<OweRepository>(() => OweRepository(getIt<OweService>()));
  getIt.registerLazySingleton<LentRepository>(() => LentRepository(getIt<LentService>()));

  getIt.registerLazySingleton<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));
  getIt.registerLazySingleton<ConnectivityCubit>(() => ConnectivityCubit(getIt<ConnectivityService>()));
  getIt.registerLazySingleton<ProfileCubit>(() => ProfileCubit(getIt<ProfileRepository>()));
  getIt.registerLazySingleton<ExpenseCubit>(() => ExpenseCubit(getIt<ExpenseRepository>()));
  getIt.registerLazySingleton<OweCubit>(() => OweCubit(getIt<OweRepository>()));
  getIt.registerLazySingleton<LentCubit>(() => LentCubit(getIt<LentRepository>()));
}