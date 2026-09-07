import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/connectivity/connectivity_cubit.dart';
import 'core/di/injector.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'firebase_options.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/auth/bloc/auth_event.dart';
import 'presentation/auth/screens/auth_gate.dart';
import 'presentation/expense/bloc/expense_cubit.dart';
import 'presentation/profile/bloc/profile_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    Hive.initFlutter(),
  ]);

  await Hive.openBox('settingsBox');
  await Hive.openBox('profileBox');
  await Hive.openBox('expensesBox');

  setupInjector();

  runApp(const FinMateApp());
}

class FinMateApp extends StatelessWidget {
  const FinMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<ConnectivityCubit>(
          create: (_) => getIt<ConnectivityCubit>(),
        ),
        BlocProvider<ProfileCubit>(
          create: (_) => getIt<ProfileCubit>(),
        ),
        BlocProvider<ExpenseCubit>(
          create: (_) => getIt<ExpenseCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          final brightness = themeMode == ThemeMode.system
              ? MediaQuery.platformBrightnessOf(context)
              : (themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light);
          final isDark = brightness == Brightness.dark;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
              systemNavigationBarColor: isDark ? const Color(0xFF000000) : const Color(0xFFFAFAFA),
              systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            ),
            child: MaterialApp(
              title: 'FinMate',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              home: const AuthGate(),
            ),
          );
        },
      ),
    );
  }
}