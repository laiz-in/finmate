import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthState.initial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthEmailVerificationResendRequested>(_onResendVerification);
    on<AuthEmailVerificationCheckRequested>(_onCheckVerification);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
      return;
    }
    await _authRepository.reloadUser();
    emit(state.copyWith(
      status: _authRepository.isEmailVerified ? AuthStatus.authenticated : AuthStatus.unverified,
    ));
  }

  Future<void> _onSignUpRequested(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    final error = await _authRepository.signUp(email: event.email, password: event.password);
    if (error != null) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error));
      return;
    }
    emit(state.copyWith(
      isSubmitting: false,
      status: AuthStatus.unverified,
      infoMessage: 'Verification email sent. Please check your inbox.',
    ));
  }

  Future<void> _onSignInRequested(AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    final error = await _authRepository.signIn(email: event.email, password: event.password);
    if (error != null) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error));
      return;
    }
    emit(state.copyWith(
      isSubmitting: false,
      status: _authRepository.isEmailVerified ? AuthStatus.authenticated : AuthStatus.unverified,
    ));
  }

  Future<void> _onResendVerification(AuthEmailVerificationResendRequested event, Emitter<AuthState> emit) async {
    await _authRepository.sendEmailVerification();
    emit(state.copyWith(infoMessage: 'Verification email sent.'));
  }

  Future<void> _onCheckVerification(AuthEmailVerificationCheckRequested event, Emitter<AuthState> emit) async {
    await _authRepository.reloadUser();
    emit(state.copyWith(
      status: _authRepository.isEmailVerified ? AuthStatus.authenticated : AuthStatus.unverified,
    ));
  }

  Future<void> _onPasswordResetRequested(AuthPasswordResetRequested event, Emitter<AuthState> emit) async {
    final error = await _authRepository.sendPasswordResetEmail(event.email);
    if (error != null) {
      emit(state.copyWith(errorMessage: error));
    } else {
      emit(state.copyWith(infoMessage: 'Password reset email sent.'));
    }
  }

  Future<void> _onSignOutRequested(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.signOut();
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }
}