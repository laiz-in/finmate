import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './auth_event.dart';
import './auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {


// ON AUTH CHECK REQUESTED
on<AuthCheckRequested>((event, emit) async {
  emit(AuthLoading());
  try {


    final FirebaseAuth auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    //IF USER IS NOT NULL
    if (user != null) {

      // CHECKS IF EMAIL IS VERIFIED
      if (user.emailVerified) {
        emit(AuthAuthenticated(user: user));
      }

      // IF EMAIL IS NOT VERIFIED
      else {
        emit(AuthUnauthenticated());
      }
    }

    // IF USER IS NULL
    else {
    emit(AuthFailure(message: "Authentication failed"));
    }


    } catch (error) {
      emit(AuthFailure(message: "Authentication failed: ${error.toString()}"));
    }
});



    // IF THE USER IS LOGGED IN
    on<UserLoggedIn>((event, emit) async {
      try {
        emit(AuthAuthenticated(user: _auth.currentUser!));
      } catch (error) {
        emit(AuthUnauthenticated());
      }
    });

    on<UserLoggedOut>((event, emit) async {
      try {
        await _auth.signOut();
        emit(AuthUnauthenticated());
      } catch (error) {
        emit(AuthUnauthenticated());
      }
    });
  }
}
