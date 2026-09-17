import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Stream<User?> get authStateChanges => _authService.authStateChanges;
  User? get currentUser => _authService.currentUser;
  bool get isEmailVerified => _authService.isEmailVerified;

  Future<String?> signUp({required String email, required String password}) async {
    try {
      await _authService.signUp(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    }
  }

  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _authService.signIn(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    }
  }

  Future<void> sendEmailVerification() => _authService.sendEmailVerification();
  Future<void> reloadUser() => _authService.reloadUser();
  Future<void> signOut() => _authService.signOut();

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    }
  }

  Future<String?> deleteAccount(String password) async {
    try {
      await _authService.deleteAccount(password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    }
  }

  /// Returns null on success, or a user-facing error message.
  Future<String?> changeEmail({required String currentPassword, required String newEmail}) async {
    try {
      await _authService.changeEmail(currentPassword: currentPassword, newEmail: newEmail);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    }
  }

  /// Returns null on success, or a user-facing error message.
  Future<String?> changePassword({required String currentPassword, required String newPassword}) async {
    try {
      await _authService.changePassword(currentPassword: currentPassword, newPassword: newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    }
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'requires-recent-login':
        return 'Please sign out and sign in again before making this change.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}