
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:moneyy/data/models/auth/create_user_req.dart";
import 'package:moneyy/data/models/auth/signin_user_req.dart';



abstract class AuthFirebaseService {

  Future<Either> signIn(UserSignInReq userSignInReq);

  Future<Either> resetPassword({required String email});

  Future<Either> resetEmail({required String email});

  Future<void> sendEmailVerification();

  Future<Either> signOut();

  Future<Either> accountDeletion();

  Future<Either> signUp(UserCreateReq userCreateReq);
}




class AuthFirebaseServiceImpl extends AuthFirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  
// SENDING EMAIL VERIFICATION
@override
Future<void> sendEmailVerification() async {
  User? user = _auth.currentUser;
  if (user != null) {
    await user.sendEmailVerification();
  } else {
    throw Exception('No user is currently signed in.');
  }
}


// SIGN IN FIREBASE SERVICE
@override
Future<Either> signIn(UserSignInReq userSignInReq) async {
  try {

    // Sign in with Firebase Authentication
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: userSignInReq.email,
      password: userSignInReq.password,
    );

    if (userCredential.user != null && !userCredential.user!.emailVerified) {
      String errorMessage = "Your email is not verified";
      await FirebaseAuth.instance.signOut(); // Sign out the user
      return Left(errorMessage); // Return error message
      
    } else{
            final user = _auth.currentUser;
            String? currentEmail = user?.email;

            await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({'status': 1});
            await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({'email': currentEmail});

            return const Right("sign in succesfull");

    }

  } on FirebaseAuthException catch (e) {

    String message ="";
    if(e.code=="invalid-email")
    {
      message = "No user found with this email";
    }else if(e.code == "invalid-credential")
    {
      message = "invalid credentials";
    }else if(e.code=="too-many-requests")
    {
      message = "you are requesting too many times";
    }else {
      message ="A network error occured";
    }
    return Left(message);

  }
}


// PASSWORD RESET FIREBASE SERVICE
@override
Future<Either<Exception, void>> resetPassword({required String email}) async {
  try {
    
    // Attempt to send password reset email
    await _auth.sendPasswordResetEmail(email: email);
    // Return a success response
    return const Right(null); // 'null' since you don't need to return a value on success
  } catch (e) {
    // Handle any errors and return them in the Left side of Either
    return Left(Exception(e.toString()));
  }
}

// EMAIL UPDATE FIREBASE SERVICE
@override
Future<Either> resetEmail({required String email}) async {
try {

  // Get the current user
  User? user = _auth.currentUser;
  

  String? currentEmail = user?.email;
  if (currentEmail == email) {
    return Left("Provided email ID is same as the current one!");
  }
  else{
      await user!.verifyBeforeUpdateEmail(email);
      return Right("successss");

  }
} on FirebaseAuthException catch (e) {
    if (e.code == 'invalid-email') {
      return Left("Provided email is inavalid!");

    } else if (e.code == 'email-already-in-use') {
      return Left("This email is already in use!");

    } else if (e.code == 'requires-recent-login') {
      return Left("This action needs a recent login!");

    } else if (e.code == 'user-not-found') {
      return Left("User not found");

    } else if (e.code == 'user-disabled') {
      return Left("This user is disabled");

    } else if (e.code == 'too-many-requests') {
      return Left("oops , too many requests!");

    } else if (e.code == 'network-request-failed') {
      return Left("Network request failed!");

    } else if (e.code == 'operation-not-allowed') {
      return Left("This operation is not allowed!");
    }
    else{
      return Left("Unexpected error occured!");
    }
  }
}


// SIGN UP FIREBASE SERVICE
@override
Future<Either> signUp(UserCreateReq userCreateReq) async {
  try {
    // Create user with Firebase Authentication
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: userCreateReq.email,
      password: userCreateReq.password,
    );
    String uid = userCredential.user!.uid;

    UserCreateReq newUser = UserCreateReq(
      email: userCreateReq.email,
      password: userCreateReq.password,
      firstName: userCreateReq.firstName,
      lastName: userCreateReq.lastName,
      uid: uid,
    );
    await sendEmailVerification();

    await _firestore.collection("users").doc(uid).set(newUser.toJson());

    return const Right("verify email to proceed login");

  } on FirebaseAuthException catch (e) {
    String message ="";

    if (e.code == 'email-already-in-use') {
      message = "The email address is already in use by another account.";

    } else if (e.code == 'weak-password') {
      message = "The password provided is too weak.";

    } else if (e.code == 'invalid-email') {
      message="The email address is not valid.";

    } else {
      message = "An unknown error occurred.";
    }


    return Left(message);

    }
}


// SIGN OUT FIREBASE SERVICE
@override
Future<Either> signOut() async {
  try {
    // Sign out from Firebase
    await _auth.signOut();
    // Return success message
    return Right("Sign out successful");
  } on FirebaseAuthException catch (e) {
    // Handle specific FirebaseAuth exceptions and provide meaningful messages
    if (e.code == 'requires-recent-login') {
      return Left("You need to log in again to sign out.");
    } else if (e.code == 'network-request-failed') {
      return Left("Network error occurred while signing out.");
    } else {
      return Left("An unexpected error occurred during sign out.");
    }
  } catch (e) {
    return Left("Unknown error occurred while signing out.");
  }
}

// ACCOUNT DELETION FIREBASE SERVICE
@override
Future<Either> accountDeletion() async {
  try {
    final user = _auth.currentUser;

    if (user != null) {

      // Delete the user from Firebase Authentication
      await user.delete();

      // Reference to the user document in Firestore
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      
      // Delete the user document from Firestore
      await userDocRef.delete();
      
      
      // Return success if everything works well
      return Right("User account deleted successfully");
    } else {
      // Return error if the user is not found
      return Left("User not found!");
    }
  } on FirebaseAuthException catch (e) {
    // Handle Firebase-specific exceptions
    if (e.code == 'requires-recent-login') {
      return Left("This action requires a recent login! Please log in again.");
    } else if (e.code == 'network-request-failed') {
      return Left("Network request failed. Please check your internet connection.");
    } else if (e.code == 'user-not-found') {
      return Left("User not found in Firebase.");
    } else if (e.code == 'too-many-requests') {
      return Left("Too many requests. Please try again later.");
    } else {
      return Left("An unknown error occurred: ${e.message}");
    }
  } catch (e) {
    // Handle other potential exceptions
    return Left("An unexpected error occurred!");
  }
}



}
