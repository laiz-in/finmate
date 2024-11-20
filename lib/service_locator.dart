import 'package:get_it/get_it.dart';
import 'package:moneyy/bloc/expenses/expenses_bloc.dart';
import 'package:moneyy/bloc/themes/theme_cubit.dart';
import 'package:moneyy/data/local/theme_storage.dart';
import 'package:moneyy/data/repository/auth/auth_repository_impl.dart';
import 'package:moneyy/data/repository/bills/bills_repository_impl.dart';
import 'package:moneyy/data/repository/expenses/expenses_repository_impl.dart';
import 'package:moneyy/data/repository/home/home_repository.dart'; // Import UserRepository
import 'package:moneyy/data/repository/settings/settings_repository_impl.dart';
import 'package:moneyy/data/sources/auth/auth_firebase_service.dart';
import 'package:moneyy/data/sources/bills/bills_firebase_services.dart';
import 'package:moneyy/data/sources/connectivity/connectivity_services.dart';
import 'package:moneyy/data/sources/expenses/expenses_firebase_services.dart';
import 'package:moneyy/data/sources/home/home_firebase_services.dart'; // Import FirebaseHomeService
import 'package:moneyy/data/sources/settings/settings_firebase_services.dart';
import 'package:moneyy/domain/repository/auth/auth.dart';
import 'package:moneyy/domain/repository/bills/bills.dart';
import 'package:moneyy/domain/repository/connectivity/connectivity_service.dart';
import 'package:moneyy/domain/repository/settings/settings.dart';
import 'package:moneyy/domain/repository/total_spendings/expenses.dart';
import 'package:moneyy/domain/usecases/auth/account_deletion.dart';
import 'package:moneyy/domain/usecases/auth/email_reset.dart';
import 'package:moneyy/domain/usecases/auth/password_reset.dart';
import 'package:moneyy/domain/usecases/auth/sign_in.dart';
import 'package:moneyy/domain/usecases/auth/sign_out.dart';
import 'package:moneyy/domain/usecases/auth/sign_up.dart';
import 'package:moneyy/domain/usecases/bills/add_bill_usecase.dart';
import 'package:moneyy/domain/usecases/bills/delete_bill_usecase.dart';
import 'package:moneyy/domain/usecases/bills/total_bills_usecase.dart';
import 'package:moneyy/domain/usecases/bills/update_bill_usecase.dart';
import 'package:moneyy/domain/usecases/connectivity/connectivity_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/add_expense_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/delete_expenses_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/last_seven_day_expense_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/last_three_expense_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/total_expenses_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/update_expense_usecase.dart';
import 'package:moneyy/domain/usecases/settings/reset_daily_limit.dart';
import 'package:moneyy/domain/usecases/settings/reset_monthly_limit.dart';
import 'package:moneyy/domain/usecases/settings/send_feedback.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {

  // BILLS RELATED
  sl.registerLazySingleton(() => UpdateBillUsecase(sl()));
  sl.registerLazySingleton(() => DeleteBillUsecase(sl()));
  sl.registerLazySingleton(() => AddBillUsecase(sl()));
  sl.registerLazySingleton(() => TotalBillsUsecase(sl()));
  sl.registerLazySingleton(() => BillsFirebaseService());
  sl.registerLazySingleton<BillsRepository>(() => BillsRepositoryImpl(sl()));

// NETWORK CONNECTION RELATED
  sl.registerLazySingleton<IConnectivityService>(() => ConnectivityService());
  sl.registerFactory(() => GetConnectivityStatus(sl<IConnectivityService>()));



  // EXPENSES RELATED
  sl.registerLazySingleton(() => LastSevenDayExpensesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateExpensesUseCase(sl()));
  sl.registerLazySingleton(() => DeleteExpensesUseCase(sl()));
  sl.registerLazySingleton(() => ExpensesFirebaseService());
  sl.registerLazySingleton<ExpensesRepository>(() => ExpensesRepositoryImpl(sl()));
  sl.registerLazySingleton(() => TotalExpensesUseCase(sl()));
  sl.registerLazySingleton(() => LastThreeExpensesUseCase(sl()));
  sl.registerLazySingleton(() => AddExpensesUseCase(sl()));
  sl.registerFactory(() => ExpensesBloc(sl(), sl()));


  // Register Authentication-related services
  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl(),);
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl(),);
  sl.registerSingleton<SignInUseCase>(SignInUseCase(),);
  sl.registerSingleton<SignUpUseCase>(SignUpUseCase(),);
  sl.registerSingleton<SignOutUseCase>(SignOutUseCase(),);
  sl.registerSingleton<AccountDeletionUseCase>(AccountDeletionUseCase(),);


  // Register settings page related services
  sl.registerSingleton<SettingsRepository>(
    SettingsRepositoryImpl(),
  );

  sl.registerSingleton<SettingsFirebaseService>
  (SettingsFirebaseServiceImpl());


  sl.registerSingleton<ResetDailyLimitUseCase>(
    ResetDailyLimitUseCase(),
  );

  sl.registerSingleton<ResetMonthlyLimitUseCase>(
    ResetMonthlyLimitUseCase(),
  );

  sl.registerSingleton<SendFeedbackUseCase>(
    SendFeedbackUseCase(),
  );

  sl.registerSingleton<ResetPasswordUseCase>(
    ResetPasswordUseCase(),
  );

  sl.registerSingleton<ResetEmailUseCase>(
    ResetEmailUseCase(),
  );
  
  // Theme change related services
  sl.registerFactory<ThemeCubit>(() => ThemeCubit(ThemeStorage()));


   // Register FirebaseHomeService directly
  sl.registerSingleton<FirebaseHomeService>(
    FirebaseHomeService(), // No need for FirebaseHomeServiceImpl
  );

  sl.registerSingleton<UserRepository>(
    UserRepository(sl<FirebaseHomeService>()), // Pass FirebaseHomeService from GetIt
  );
}
