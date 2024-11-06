import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:moneyy/bloc/authentication/auth_bloc.dart';
import 'package:moneyy/bloc/authentication/auth_event.dart';
import 'package:moneyy/bloc/expenses/expenses_bloc.dart';
import 'package:moneyy/bloc/home_screen/home_screen_bloc.dart';
import 'package:moneyy/bloc/network/network_bloc.dart';
import 'package:moneyy/bloc/network/network_state.dart';
import 'package:moneyy/bloc/themes/theme_cubit.dart';
import 'package:moneyy/config/firebase_options.dart';
import 'package:moneyy/core/colors/theme.dart';
import 'package:moneyy/data/repository/home/home_repository.dart';
import 'package:moneyy/domain/usecases/expenses/add_expense_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/total_expenses_usecase.dart';
import 'package:moneyy/presentation/routes/routes.dart';
import 'package:moneyy/presentation/screens/connection_lost_screen/conection_lost_screen.dart';
import 'package:moneyy/presentation/screens/splash/splash.dart';
import 'package:moneyy/service_locator.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: getFirebaseOptions(),
  );

  // Initialize Hydrated Storage
  final storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  await initializeDependencies();

  // Set HydratedBloc.storage to the initialized storage
  HydratedBloc.storage = storage;

  runApp(
    MultiBlocProvider(
      providers: [

        // auth
        BlocProvider(
          create: (context) => AuthBloc()..add(AuthCheckRequested()),
        ),

        //expense
        BlocProvider(
          create: (context) => ExpensesBloc(
            sl<TotalExpensesUseCase>(),
            sl<AddExpensesUseCase>(),
          ),
        ),

        // theme
        BlocProvider(
          create: (context) => sl<ThemeCubit>()..loadTheme(),
        ),

        // network
        BlocProvider(
          create: (context) => NetworkBloc(),
        ),


        // homescreen
        BlocProvider(
      create: (context) => HomeScreenBloc(
        userRepository: sl<UserRepository>(),
        networkBloc: BlocProvider.of<NetworkBloc>(context), // Access NetworkBloc
      ),
    
    ),

      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NetworkBloc, NetworkState>(

      listener: (context, state) {
        if (state is NetworkDisconnected) {
          print("NETWORK IS NOT CONNECTED IN MAIN.DART");
          Future.microtask(() {
            Navigator.of(context).pushReplacement(
            MaterialPageRoute(
            builder: (context) => NoInternetScreen(),
              ),
            );
          });
        }
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
  }
}
