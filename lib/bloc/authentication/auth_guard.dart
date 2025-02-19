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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {

        return BlocBuilder<ConnectivityCubit, bool>(
          builder: (context, isConnected) {
            

            // IF AUTHENTICATION FAILED AND NO INTERNET CONNECTION
            if (authState is AuthFailure && !isConnected) {
              return NoInternetScreen();
            }


            // WHEN AUTHENTICATON LOADING
            if (authState is AuthLoading) {
              return SplashScreen();
            }

            // AUTHENTICATED
            if (authState is AuthAuthenticated) {
              return HomeScreen();
            }


            // DEVICE IS NOT AUTHENTICATED
            if (authState is AuthUnauthenticated || authState is AuthFailure) {
              return LoginScreen();
            }


            // AUTHENTICATION FAILED
            if (authState is AuthFailure) {
              return LoginScreen();
            }

            return SplashScreen();
          },
        );
      },
    );
  }
}
