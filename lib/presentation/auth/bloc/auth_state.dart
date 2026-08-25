import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,
  authenticated,
  unverified,
  unauthenticated,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final bool isSubmitting;
  final String? errorMessage;
  final String? infoMessage;

  const AuthState({
    required this.status,
    this.isSubmitting = false,
    this.errorMessage,
    this.infoMessage,
  });

  const AuthState.initial() : this(status: AuthStatus.initial);

  AuthState copyWith({
    AuthStatus? status,
    bool? isSubmitting,
    String? errorMessage,
    String? infoMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      isSubmitting: isSubmitting ?? false,
      errorMessage: errorMessage,
      infoMessage: infoMessage,
    );
  }

  @override
  List<Object?> get props => [status, isSubmitting, errorMessage, infoMessage];
}