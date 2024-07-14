import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './auth_event.dart';
import './auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>((event, emit) async {
      emit(AuthLoading()); // Emit loading state first
      try {
        final user = _auth.currentUser;
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (error) {
        emit(AuthUnauthenticated());
      }
    });

    on<UserLoggedIn>((event, emit) async {
      try {
        // Additional user information retrieval (optional)
        // final user = await _auth.currentUser!.reload(); // Refresh user data
        emit(AuthAuthenticated(user: _auth.currentUser!));
      } catch (error) {
        print(error); // Log the error for debugging
        // Emit appropriate error state (optional)
      }
    });

    on<UserLoggedOut>((event, emit) async {
      try {
        await _auth.signOut();
        emit(AuthUnauthenticated());
      } catch (error) {
        print(error); // Log the error for debugging
        // Emit appropriate error state (optional)
      }
    });
  }
}
