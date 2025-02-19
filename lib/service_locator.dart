import 'package:get_it/get_it.dart';
import 'package:moneyy/bloc/expenses/expenses_bloc.dart';
import 'package:moneyy/bloc/network/network_bloc.dart';
import 'package:moneyy/bloc/themes/theme_cubit.dart';
import 'package:moneyy/data/local/theme_storage.dart';
import 'package:moneyy/data/repository/auth/auth_repository_impl.dart';
import 'package:moneyy/data/repository/bills/bills_repository_impl.dart';
import 'package:moneyy/data/repository/expenses/expenses_repository_impl.dart';
import 'package:moneyy/data/repository/home/home_repository.dart'; // Import UserRepository
import 'package:moneyy/data/repository/income/income_repository_impl.dart';
import 'package:moneyy/data/repository/settings/settings_repository_impl.dart';
import 'package:moneyy/data/sources/remote/auth/auth_firebase_service.dart';
import 'package:moneyy/data/sources/remote/bills/bills_firebase_services.dart';
import 'package:moneyy/data/sources/remote/connectivity/connectivity_services.dart';
import 'package:moneyy/data/sources/remote/expenses/expenses_firebase_services.dart';
import 'package:moneyy/data/sources/remote/home/home_firebase_services.dart';
import 'package:moneyy/data/sources/remote/income/income_firebase_services.dart';
import 'package:moneyy/data/sources/remote/settings/settings_firebase_services.dart';
import 'package:moneyy/domain/repository/auth/auth.dart';
import 'package:moneyy/domain/repository/bills/bills.dart';
import 'package:moneyy/domain/repository/connectivity/connectivity_service.dart';
import 'package:moneyy/domain/repository/income/income.dart';
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
import 'package:moneyy/domain/usecases/expenses/complete_expenses_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/delete_expenses_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/last_seven_day_expense_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/last_three_expense_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/total_expenses_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/update_expense_usecase.dart';
import 'package:moneyy/domain/usecases/income/add_income_usecase.dart';
import 'package:moneyy/domain/usecases/income/complete_income_usecase.dart';
import 'package:moneyy/domain/usecases/income/delete_income_usecase.dart';
import 'package:moneyy/domain/usecases/income/last_three_income_usecase.dart';
import 'package:moneyy/domain/usecases/income/this_month_total_income.dart';
import 'package:moneyy/domain/usecases/income/this_week_total_income.dart';
import 'package:moneyy/domain/usecases/income/this_year_total_income.dart';
import 'package:moneyy/domain/usecases/income/todays_income_usecase.dart';
import 'package:moneyy/domain/usecases/income/total_income_usecase.dart';
import 'package:moneyy/domain/usecases/income/update_income_usecase.dart';
import 'package:moneyy/domain/usecases/settings/name_reset.dart';
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

 // INCOME RELATED
  sl.registerLazySingleton(() => UpdateIncomeUseCase(sl()));
  sl.registerLazySingleton(() => DeleteIncomeUseCase(sl()));
  sl.registerLazySingleton(() => IncomeFirebaseService());
  sl.registerLazySingleton<IncomeRepository>(() => IncomeRepositoryImpl(sl()));
  sl.registerLazySingleton(() => TotalIncomeUseCase(sl()));
  sl.registerLazySingleton(() => CompleteIncomeUseCase(sl()));
  sl.registerLazySingleton(() => LastThreeIncomeUseCase(sl()));
  sl.registerLazySingleton(() => ThisMonthToatalIncomeUseCase(sl()));
  sl.registerLazySingleton(() => ThisWeekToatalIncomeUseCase(sl()));
  sl.registerLazySingleton(() => TodaysIncomeUsecase(sl()));

  sl.registerLazySingleton(() => ThisYearToatalIncomeUseCase(sl()));

  sl.registerLazySingleton(() => AddIncomeUseCase(sl()));
  // sl.registerFactory(() => IncomeBloc(sl(), sl()));


  // EXPENSES RELATED
  sl.registerLazySingleton(() => LastSevenDayExpensesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateExpensesUseCase(sl()));
  sl.registerLazySingleton(() => DeleteExpensesUseCase(sl()));
  sl.registerLazySingleton(() => ExpensesFirebaseService());
  sl.registerLazySingleton<ExpensesRepository>(() => ExpensesRepositoryImpl(sl()));
  sl.registerLazySingleton(() => TotalExpensesUseCase(sl()));
  sl.registerLazySingleton(() => CompleteExpensesUsecase(sl()));
  sl.registerLazySingleton(() => LastThreeExpensesUseCase(sl()));
  sl.registerLazySingleton(() => AddExpensesUseCase(sl()));
  sl.registerFactory(() => ExpensesBloc(sl(), sl(),sl()));


  // AUTH RELATED
  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl(),);
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl(),);
  sl.registerSingleton<SignInUseCase>(SignInUseCase(),);
  sl.registerSingleton<SignUpUseCase>(SignUpUseCase(),);
  sl.registerSingleton<SignOutUseCase>(SignOutUseCase(),);
  sl.registerSingleton<AccountDeletionUseCase>(AccountDeletionUseCase(),);


  // SETTINGS RELATED
  sl.registerSingleton<SettingsRepository>(SettingsRepositoryImpl());
  sl.registerSingleton<SettingsFirebaseService>(SettingsFirebaseServiceImpl());
  sl.registerSingleton<ResetDailyLimitUseCase>(ResetDailyLimitUseCase(),);
  sl.registerSingleton<ResetMonthlyLimitUseCase>(ResetMonthlyLimitUseCase(),);
  sl.registerSingleton<SendFeedbackUseCase>(SendFeedbackUseCase(),);
  sl.registerSingleton<ResetPasswordUseCase>(ResetPasswordUseCase(),);
  sl.registerSingleton<ResetEmailUseCase>(ResetEmailUseCase(),);
  sl.registerSingleton<ResetNameUseCase>(ResetNameUseCase(),);

  
  // THEME CHANGE RELATED
  sl.registerFactory<ThemeCubit>(() => ThemeCubit(ThemeStorage()));
  sl.registerSingleton<ConnectivityCubit>(
    ConnectivityCubit(sl<GetConnectivityStatus>()), // Ensure GetConnectivityStatus is registered
  );
  sl.registerSingleton<FirebaseHomeService>(
    FirebaseHomeService(), // Pass ConnectivityCubit instance
  );

  sl.registerSingleton<UserRepository>(
    UserRepository(sl<FirebaseHomeService>()), // Pass FirebaseHomeService from GetIt
  );
}
