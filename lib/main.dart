import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:moneyy/bloc/authentication/auth_bloc.dart';
import 'package:moneyy/bloc/authentication/auth_event.dart';
import 'package:moneyy/bloc/bills/bills_bloc.dart';
import 'package:moneyy/bloc/expenses/expenses_bloc.dart';
import 'package:moneyy/bloc/home_screen/home_screen_bloc.dart';
import 'package:moneyy/bloc/income/income_bloc.dart';
import 'package:moneyy/bloc/network/network_bloc.dart';
import 'package:moneyy/bloc/themes/theme_cubit.dart';
import 'package:moneyy/config/firebase_options.dart';
import 'package:moneyy/core/colors/theme.dart';
import 'package:moneyy/data/repository/home/home_repository.dart';
import 'package:moneyy/domain/usecases/bills/add_bill_usecase.dart';
import 'package:moneyy/domain/usecases/bills/total_bills_usecase.dart';
import 'package:moneyy/domain/usecases/connectivity/connectivity_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/add_expense_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/total_expenses_usecase.dart';
import 'package:moneyy/domain/usecases/income/add_income_usecase.dart';
import 'package:moneyy/domain/usecases/income/this_month_total_income.dart';
import 'package:moneyy/domain/usecases/income/this_week_total_income.dart';
import 'package:moneyy/domain/usecases/income/this_year_total_income.dart';
import 'package:moneyy/domain/usecases/income/total_income_usecase.dart';
import 'package:moneyy/firebase_initializer.dart';
import 'package:moneyy/presentation/routes/routes.dart';
import 'package:moneyy/presentation/screens/splash/splash.dart';
import 'package:moneyy/service_locator.dart';
import 'package:path_provider/path_provider.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: getFirebaseOptions(),
  );

  // Initialize Hydrated Storage
  final storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  FirebaseInitializer.enableOfflinePersistence(
    'https://console.firebase.google.com/project/finmate-d9f70/database/finmate-d9f70-default-rtdb/data/~2F',
  );

  await initializeDependencies();

  // Set HydratedBloc.storage to the initialized storage
  HydratedBloc.storage = storage;

  runApp(
    MultiBlocProvider(
      providers: [
        // Auth Bloc
        BlocProvider(
          create: (context) => AuthBloc()..add(AuthCheckRequested()),
        ),

        // Expenses Bloc
        BlocProvider(
          create: (context) => ExpensesBloc(
            sl<TotalExpensesUseCase>(),
            sl<AddExpensesUseCase>(),
          ),
        ),

        // Bills Bloc
        BlocProvider(
          create: (context) => BillsBloc(
            sl<TotalBillsUsecase>(),
            sl<AddBillUsecase>(),
          ),
        ),

        // Income Bloc
        BlocProvider(
          create: (context) => IncomeBloc(
            sl<TotalIncomeUseCase>(),
            sl<AddIncomeUseCase>(),
          ),
        ),

        // Theme
        BlocProvider(
          create: (context) => sl<ThemeCubit>()..loadTheme(),
        ),

        // Network
        BlocProvider(
          create: (context) => ConnectivityCubit(sl<GetConnectivityStatus>()),
        ),

        // HomeScreen
        BlocProvider(
          create: (context) => HomeScreenBloc(
            userRepository: sl<UserRepository>(),
            connectivityCubit: BlocProvider.of<ConnectivityCubit>(context),
            fetchThisMonthIncomeUseCase: sl<ThisMonthToatalIncomeUseCase>(),
            fetchThisWeekIncomeUseCase: sl<ThisWeekToatalIncomeUseCase>(),
            fetchThisYearIncomeUseCase: sl<ThisYearToatalIncomeUseCase>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Specify your design reference
      minTextAdapt: true,
      builder: (context, child) {
        return BlocListener<ConnectivityCubit, bool>(
          listener: (context, isConnected) {
            // Handle connectivity changes
          },
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                onGenerateRoute: AppRoutes.generateRoute,
                routes: {
                  '/': (context) => const SplashScreen(),
                },
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                title: 'Finmate',
              );
            },
          ),
        );
      },
    );
  }
}