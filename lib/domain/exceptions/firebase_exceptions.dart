// lib/domain/exceptions/firebase_exceptions.dart

abstract class FirebaseFailure {
  final String message;
  const FirebaseFailure(this.message);
}

class AuthFailure extends FirebaseFailure {
  const AuthFailure(super.message);
}

class InvalidEmailException extends AuthFailure {
  InvalidEmailException() : super("The email address is not valid.");
}

class EmailAlreadyInUseException extends AuthFailure {
  EmailAlreadyInUseException() : super("The email address is already in use.");
}

class WeakPasswordException extends AuthFailure {
  WeakPasswordException() : super("The password is too weak.");
}

class UserNotFoundException extends AuthFailure {
  UserNotFoundException() : super("No user found for the provided email");
}

class WrongPasswordException extends AuthFailure {
  WrongPasswordException() : super("Incorrect password.");
}

class UserDisabledException extends AuthFailure {
  UserDisabledException() : super("The user account has been disabled.");
}

class TooManyRequestsException extends AuthFailure {
  TooManyRequestsException() : super("Too many requests. Try again later.");
}

class RequiresRecentLoginException extends AuthFailure {
  RequiresRecentLoginException() : super("This action requires recent login.");
}

class InvalidCredentialException extends AuthFailure {
  InvalidCredentialException() : super("The credential is invalid or expired.");
}

class FirestoreFailure extends FirebaseFailure {
  const FirestoreFailure(super.message);
}

class PermissionDeniedException extends FirestoreFailure {
  PermissionDeniedException() : super("You don't have permission to access this data.");
}

class NotFoundException extends FirestoreFailure {
  NotFoundException() : super("The requested document was not found.");
}

class AlreadyExistsException extends FirestoreFailure {
  AlreadyExistsException() : super("The document already exists.");
}

class CancelledException extends FirestoreFailure {
  CancelledException() : super("The operation was cancelled.");
}

class DataLossException extends FirestoreFailure {
  DataLossException() : super("Unrecoverable data loss or corruption.");
}

class StorageFailure extends FirebaseFailure {
  const StorageFailure(super.message);
}

class ObjectNotFoundException extends StorageFailure {
  ObjectNotFoundException() : super("No object exists at the specified location.");
}

class BucketNotFoundException extends StorageFailure {
  BucketNotFoundException() : super("No bucket is configured for Cloud Storage.");
}

class UnauthorizedException extends StorageFailure {
  UnauthorizedException() : super("User is not authorized to perform this action.");
}

class QuotaExceededException extends StorageFailure {
  QuotaExceededException() : super("Quota for Cloud Storage has been exceeded.");
}

class UnknownStorageException extends StorageFailure {
  UnknownStorageException() : super("An unknown storage error occurred.");
}

class NetworkException extends FirebaseFailure {
  NetworkException() : super("No internet connection.");
}

class GeneralFirebaseException extends FirebaseFailure {
  GeneralFirebaseException(super.message);
}
