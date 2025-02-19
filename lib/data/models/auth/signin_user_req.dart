import 'package:meta/meta.dart';

// CUSTOM EXCEPTION FOR SIGN IN VALIDATION
class SignInValidationException implements Exception {
  final String message;
  SignInValidationException(this.message);
}

@immutable
class UserSignInReq {
  // CONSTANTS FOR VALIDATION
  static const int MAX_EMAIL_LENGTH = 254;
  static const int MIN_PASSWORD_LENGTH = 6;
  static const int MAX_PASSWORD_LENGTH = 128;

  // EMAIL REGEX FOR BASIC VALIDATION
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );

  // PRIVATE FINAL FIELDS
  final String email;
  final String password;

  // PRIVATE CONSTRUCTOR FOR VALIDATION CONTROL
  const UserSignInReq._internal({
    required this.email,
    required this.password,
  });

  // PUBLIC FACTORY CONSTRUCTOR WITH VALIDATION
  factory UserSignInReq({
    required String email,
    required String password,
  }) {
    // VALIDATE EMAIL
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) {
      throw SignInValidationException('Email cannot be empty');
    }
    if (cleanEmail.length > MAX_EMAIL_LENGTH) {
      throw SignInValidationException('Email is too long');
    }
    if (!_emailRegex.hasMatch(cleanEmail)) {
      throw SignInValidationException('Invalid email format');
    }

    // VALIDATE PASSWORD
    if (password.isEmpty) {
      throw SignInValidationException('Password cannot be empty');
    }
    if (password.length < MIN_PASSWORD_LENGTH) {
      throw SignInValidationException(
        'Password must be at least $MIN_PASSWORD_LENGTH characters',
      );
    }
    if (password.length > MAX_PASSWORD_LENGTH) {
      throw SignInValidationException('Password is too long');
    }

    return UserSignInReq._internal(
      email: cleanEmail,
      password: password,
    );
  }

  // CONVERT TO JSON FOR API REQUESTS
  Map<String, String> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  // SAFE COPY WITH METHOD
  UserSignInReq copyWith({
    String? email,
    String? password,
  }) {
    return UserSignInReq(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  // OVERRIDE EQUALITY FOR PROPER COMPARISON
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSignInReq &&
          email == other.email &&
          password == password;  // COMPARE HASHED PASSWORDS IF NEEDED

  // OVERRIDE HASHCODE FOR PROPER SET/MAP OPERATIONS
  @override
  int get hashCode => email.hashCode ^ password.hashCode;

  // STRING REPRESENTATION (SAFE)
  @override
  String toString() {
    return 'UserSignInReq(email: $email, password: ****)';
  }
}