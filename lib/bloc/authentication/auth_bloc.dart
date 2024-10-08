import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './auth_event.dart';
import './auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {

    // when AuthCheckRequested
on<AuthCheckRequested>((event, emit) async {
  emit(AuthLoading()); // Emit loading state first
  try {
    final user = _auth.currentUser;

    if (user != null) {
      // Emit a state to indicate that we're validating the user's auth state
      emit(AuthLoading());

      // Force the user authentication state to reload from Firebase servers
      await user.reload();
      final refreshedUser = _auth.currentUser;

      // Check if the user still exists and email is verified
      if (refreshedUser != null && refreshedUser.emailVerified) {
        emit(AuthAuthenticated(user: refreshedUser));
      } else {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  } catch (error) {
    emit(AuthUnauthenticated());
  }
});



    
    on<UserLoggedIn>((event, emit) async {
      try {
        emit(AuthAuthenticated(user: _auth.currentUser!));
      } catch (error) {
        // Emit appropriate error state (optional)
      }
    });

    on<UserLoggedOut>((event, emit) async {
      try {
        await _auth.signOut();
        emit(AuthUnauthenticated());
      } catch (error) {
        // Emit appropriate error state (optional)
      }
    });
  }
}
