import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moneyy/data/models/auth/create_user_req.dart';
import 'package:moneyy/data/models/auth/signin_user_req.dart';
import 'package:moneyy/domain/exceptions/firebase_exceptions.dart';

abstract class AuthFirebaseService {
  Future<Either<FirebaseFailure, String>> signIn(UserSignInReq userSignInReq);
  Future<Either<FirebaseFailure, void>> resetPassword({required String email});
  Future<Either<FirebaseFailure, String>> resetEmail({required String email});
  Future<Either<FirebaseFailure, void>> sendEmailVerification();
  Future<Either<FirebaseFailure, String>> signOut();
  Future<Either<FirebaseFailure, String>> accountDeletion();
  Future<Either<FirebaseFailure, String>> signUp(UserCreateReq userCreateReq, String password);
}

class AuthFirebaseServiceImpl extends AuthFirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // HANDLE FIREBASE AUTH EXCEPTIONS
  FirebaseFailure _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return InvalidEmailException();
      case 'user-disabled':
        return UserDisabledException();
      case 'user-not-found':
        return UserNotFoundException();
      case 'wrong-password':
        return WrongPasswordException();
      case 'email-already-in-use':
        return EmailAlreadyInUseException();
      case 'weak-password':
        return WeakPasswordException();
      case 'too-many-requests':
        return TooManyRequestsException();
      case 'requires-recent-login':
        return RequiresRecentLoginException();
      case 'invalid-credential':
        return InvalidCredentialException();
      default:
        return GeneralFirebaseException("Unknown error occured , please contact us");
    }
  }

  // CHECK INTERNET CONNECTION
  Future<bool> _isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // EMAIL VERIFICATION
  @override
  Future<Either<FirebaseFailure, void>> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        return const Right(null);
      } else {
        return Left(GeneralFirebaseException("No user is currently signed in"));
      }
    } on FirebaseAuthException catch (e) {
      return Left(_handleAuthException(e));
    } catch (e) {
      return Left(GeneralFirebaseException(e.toString()));
    }
  }

  // SIGN IN
  @override
  Future<Either<FirebaseFailure, String>> signIn(UserSignInReq userSignInReq) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: userSignInReq.email,
        password: userSignInReq.password,
      );

      if (userCredential.user == null) {
        return Left(UserNotFoundException());
      }

      if (!userCredential.user!.emailVerified) {
        await sendEmailVerification();
        await _auth.signOut();
        return Left(GeneralFirebaseException("Your Email is not verified"));
      }

      return await _handleSuccessfulSignIn(userCredential);
    } on FirebaseAuthException catch (e) {
      return Left(_handleAuthException(e));
    }
  }

  // HANDLE SUCCESSFUL SIGN IN
  Future<Either<FirebaseFailure, String>> _handleSuccessfulSignIn(UserCredential userCredential) async {
    try {
      final user = _auth.currentUser;
      String? currentEmail = user?.email;

      if (user == null) {
        return Left(GeneralFirebaseException("User is not authenticated"));
      }

      await _firestore.collection('users').doc(user.uid).update({
        'status': 1,
        'email': currentEmail,
      });

      return const Right("SUser has been signed in succesfully");
    } catch (e) {
      return Left(GeneralFirebaseException("Error while updating firestore"));
    }
  }

  // PASSWORD RESET
  @override
  Future<Either<FirebaseFailure, void>> resetPassword({required String email}) async {
    try {
      if (!await _isConnected()) {
        return Left(GeneralFirebaseException("Internet connection is required for this action"));
      }
      await _auth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(_handleAuthException(e));
    }
  }

  // EMAIL UPDATE
  @override
  Future<Either<FirebaseFailure, String>> resetEmail({required String email}) async {
    try {
      if (!await _isConnected()) {
        return Left(GeneralFirebaseException("Internet connection is required for this action"));
      }

      User? user = _auth.currentUser;
      String? currentEmail = user?.email;

      if (currentEmail == email) {
        return Left(GeneralFirebaseException("Provided Email is same as the current one"));
      }

      await user!.verifyBeforeUpdateEmail(email);
      return const Right("SUCCESS");
    } on FirebaseAuthException catch (e) {
      return Left(_handleAuthException(e));
    }
  }

  // SIGN UP
  @override
  Future<Either<FirebaseFailure, String>> signUp(UserCreateReq userCreateReq, String password) async {
    try {

      if (!await _isConnected()) {
        return Left(GeneralFirebaseException("Internet connection is required for this action"));
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: userCreateReq.email,
        password: password,
      );

      User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return Left(GeneralFirebaseException("User creation has been failed"));
      }

      String uid = firebaseUser.uid;

      UserCreateReq newUser = UserCreateReq(
        email: userCreateReq.email,
        firstName: userCreateReq.firstName,
        lastName: userCreateReq.lastName,
        uid: uid,
      );

      try {
        WriteBatch batch = _firestore.batch();
        DocumentReference userRef = _firestore.collection("users").doc(uid);
        batch.set(userRef, newUser.toFirestoreJson());
        await batch.commit();
        await sendEmailVerification();
        return const Right("Verify your Email to proceed with log in");
      } catch (e) {
        await firebaseUser.delete();
        return Left(GeneralFirebaseException("User sign up has been failed"));
      }
    } on FirebaseAuthException catch (e) {
      return Left(_handleAuthException(e));
    }
  }

  // SIGN OUT
  @override
  Future<Either<FirebaseFailure, String>> signOut() async {
    try {
      await _auth.signOut();
      return const Right("User has been signed out");
    } on FirebaseAuthException catch (e) {
      return Left(_handleAuthException(e));
    }
  }

  // ACCOUNT DELETION
  @override
  Future<Either<FirebaseFailure, String>> accountDeletion() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        final userDocRef = _firestore.collection('users').doc(user.uid);
        await userDocRef.delete();
        return const Right("User account has been deleted");
      } else {
        return Left(GeneralFirebaseException("User not found"));
      }
    } on FirebaseAuthException catch (e) {
      return Left(_handleAuthException(e));
    }
  }
}
