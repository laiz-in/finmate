import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyy/bloc/network/network_bloc.dart';
import 'package:moneyy/presentation/screens/connection_lost_screen/conection_lost_screen.dart';
import 'package:moneyy/presentation/screens/home_screen/home_screen.dart';
import 'package:moneyy/presentation/screens/splash/splash.dart';
import 'package:moneyy/presentation/screens/user_auth/sign_in/sign_in.dart';

import 'auth_bloc.dart';
import 'auth_state.dart';

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, bool>(
      builder: (context, isConnected) {
        // Check the network connection status
        if (!isConnected) {
          return NoInternetScreen(); // Show NoInternetScreen when disconnected
        }

        // If connected, handle authentication state
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is AuthLoading) {
              return SplashScreen();
            } else if (authState is AuthAuthenticated) {
              return HomeScreen();
            } else if (authState is AuthUnauthenticated) {
              return LoginScreen();
            } else {
              return NoInternetScreen(); // Fallback in case of unexpected state
            }
          },
        );
      },
    );
  }
}
