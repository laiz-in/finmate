import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:moneyy/bloc/authentication/auth_bloc.dart';
import 'package:moneyy/bloc/authentication/auth_event.dart';
import 'package:moneyy/bloc/authentication/auth_guard.dart';
import 'package:moneyy/bloc/home_screen/home_screen_bloc.dart';
import 'package:moneyy/bloc/themes/theme_cubit.dart';
import 'package:moneyy/config/firebase_options.dart';
import 'package:moneyy/core/colors/theme.dart';
import 'package:moneyy/data/repository/home/home_repository.dart';
import 'package:moneyy/presentation/routes/routes.dart';
// import 'package:moneyy/presentation/screens/home_screen/home_screen.dart';
import 'package:moneyy/service_locator.dart';
import 'package:path_provider/path_provider.dart';

import 'presentation/screens/splash/splash.dart';


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
    // AuthBloc for authentication-related events
    BlocProvider(
      create: (context) => AuthBloc()..add(AuthCheckRequested()),
    ),

    // ThemeCubit to manage theme changes and load the theme from storage
    BlocProvider(
      create: (context) => sl<ThemeCubit>()..loadTheme(),
    ),

    // HomeScreenBloc to manage the user's home screen data, using the UserRepository
    BlocProvider(
      create: (context) => HomeScreenBloc(sl<UserRepository>()), // Pass the user repository
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
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
            onGenerateRoute: AppRoutes.generateRoute,

          routes: {
            '/': (context) => const SplashScreen(),
            '/auth': (context) => const AuthGuard(),
            // '/TransactionScreen': (context) =>  AllSpendings(),
            // '/ProfileScreen': (context) =>  ProfileSettings(),
            // '/AllBillsScreen': (context) =>  AllBills(),
            // '/AllIndividuals': (context) =>  AllLiabilities(),
            // '/AllReminders': (context) =>  AllReminders(),
            // '/AllStatistics': (context) =>  AllStatistics(),
            // '/changeEmail': (context) => const ResetEmail(),
            // '/changeDailyLimit': (context) => const ResetDailyLimit(),
            // '/changeMonthlyLimit': (context) => const ResetMonthlyLimit(),
          },
          theme: AppTheme.lightTheme,  // Light theme
          darkTheme: AppTheme.darkTheme,  // Dark theme
          themeMode: themeMode,  // The theme mode from ThemeCubit
          title: 'Finmate',
            );
          });
  }

}