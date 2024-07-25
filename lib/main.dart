import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Different screens imports
import 'package:moneyy/Widgets/profile/profile_screen.dart';
import 'package:moneyy/Widgets/profile/set_limits.dart';

import './Widgets/bills/all_bills_screen.dart';
import './Widgets/individuals/individuals_main_screen.dart';
import './Widgets/reminders/all_reminders.dart';
import './Widgets/statistics/all_statistics_screen.dart';
import './styles/theme_bloc.dart';
import './styles/theme_state.dart';
import 'Widgets/connectivity_check/connectivity_bloc.dart';
import 'Widgets/connectivity_check/connectivity_lost_screen.dart';
import 'Widgets/home_screen.dart';
import 'Widgets/profile/change_daily_limit.dart';
import 'Widgets/profile/change_email.dart';
import 'Widgets/transactions/all_spendings_screen.dart';
import 'Widgets/user_auth/login_screen.dart';
import 'Widgets/user_auth/password_reset_screen.dart';
import 'Widgets/user_auth/sign_up_screen.dart';
import 'auth/auth_bloc.dart';
import 'auth/auth_event.dart';
import 'auth/auth_guard.dart';
import 'firebase_options.dart';
import 'splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: getFirebaseOptions(), // Use the function from firebase_options.dart
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeBloc()),
        BlocProvider(create: (context) => ConnectivityBloc()..add(CheckConnectivity())),
        BlocProvider(create: (context) => AuthBloc()..add(AuthCheckRequested())),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<ConnectivityBloc, ConnectivityState>(
          builder: (context, connectivityState) {
            return MaterialApp(
              
              debugShowCheckedModeBanner: false,
              routes: {
                '/': (context) => connectivityState is DisconnectedState
                    ? NoInternetScreen()
                    : SplashScreen(),
                '/auth': (context) => AuthGuard(),
                '/HomeScreen': (context) => HomeScreen(),
                '/SignUpScreen': (context) => SignUpScreen(),
                '/LoginScreen': (context) => LoginScreen(),
                '/ResetPasswordScreen': (context) => ResetPassword(),
                '/TransactionScreen': (context) => AllSpendings(),
                '/ProfileScreen': (context) => ProfileSettings(),
                '/AllBillsScreen': (context) => AllBills(),
                '/SetLimits': (context) => SetLimits(),
                '/AllIndividuals' : (context) => AllIndividuals(),
                '/AllReminders' : (context) => AllReminders(),
                '/AllStatistics' : (context) => AllStatistics(),
                '/changeEmail' : (context) => ResetEmail(),
                '/changeDailyLimit' : (context) => ResetDailyLimit(),



              },
              theme: themeState.themeData,
              title: 'Finmate',
            );
          },
        );
      },
    );
  }
}