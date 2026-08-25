import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('FinMate')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You are logged in 🎉', style: AppTextStyles.heading2(colors.textPrimary)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<AuthBloc>().add(const AuthSignOutRequested()),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}