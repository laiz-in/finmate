import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyy/splash.dart';

import '../Widgets/home_screen.dart';
import '../Widgets/user_Auth/login_screen.dart';
import 'auth_bloc.dart';
import 'auth_state.dart';

class AuthGuard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return SplashScreen();
        } else if (state is AuthAuthenticated) {
          return HomeScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
