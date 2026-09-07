import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injector.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../dashboard/screens/main_shell.dart';
import '../../expense/bloc/expense_cubit.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../profile/bloc/profile_cubit.dart';
import '../../profile/bloc/profile_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.initial:
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          case AuthStatus.authenticated:
            return const _ProfileGate();
          case AuthStatus.unverified:
            return const VerifyEmailScreen();
          case AuthStatus.unauthenticated:
            return const LoginScreen();
        }
      },
    );
  }
}

class _ProfileGate extends StatefulWidget {
  const _ProfileGate();

  @override
  State<_ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<_ProfileGate> {
  @override
  void initState() {
    super.initState();
    final uid = getIt<AuthRepository>().currentUser?.uid;
    if (uid != null) {
      context.read<ProfileCubit>().loadProfile(uid);
      context.read<ExpenseCubit>().loadExpenses(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (state.profile == null) {
          return const OnboardingScreen();
        }
        return const MainShell();
      },
    );
  }
}