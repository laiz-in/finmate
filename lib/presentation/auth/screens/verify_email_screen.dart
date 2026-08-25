import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _pollTimer;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    // Auto-check verification status every 4 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      context.read<AuthBloc>().add(const AuthEmailVerificationCheckRequested());
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _resendEmail() {
    context.read<AuthBloc>().add(const AuthEmailVerificationResendRequested());
    setState(() => _resendCooldown = 30);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.infoMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.infoMessage!)),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mark_email_unread_outlined, size: 72, color: colors.primary),
                const SizedBox(height: 24),
                Text('Verify your email', style: AppTextStyles.heading2(colors.textPrimary)),
                const SizedBox(height: 12),
                Text(
                  'We sent a verification link to your email. Please check your spam folder as well',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption(colors.textSecondary),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _resendCooldown > 0 ? null : _resendEmail,
                    child: Text(_resendCooldown > 0 ? 'Resend in ${_resendCooldown}s' : 'Resend Email'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.read<AuthBloc>().add(const AuthSignOutRequested()),
                  child: Text('Sign out', style: AppTextStyles.bodyMedium(colors.textSecondary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}