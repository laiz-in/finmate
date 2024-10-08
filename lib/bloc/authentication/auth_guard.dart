import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyy/presentation/screens/home_screen/home_screen.dart';
import 'package:moneyy/presentation/screens/splash/splash.dart';
import 'package:moneyy/presentation/screens/user_auth/sign_in/sign_in.dart';

import 'auth_bloc.dart';
import 'auth_state.dart';

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(

      builder: (context, state) {
        
        // During loading return splash screen only
        if (state is AuthLoading) {
          return SplashScreen();

        // if authenticated , then return the main screen
        } else if (state is AuthAuthenticated) {
          return HomeScreen();

        // if user is un authenticated, then retun home screen
        } else {
          return LoginScreen();

        }
      },
    );
  }
}
