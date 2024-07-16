import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../styles/themes.dart';
import '../ui/error_snackbar.dart';

void showCustomAlertBox(BuildContext context, String mainText, String subText) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              padding: EdgeInsets.fromLTRB(5.0, 5, 5, 10),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 212, 224, 198),
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10.0,
                    spreadRadius: 5.0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animation
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Lottie.asset(
                      'assets/animations/succes.json', // Replace with your Lottie animation file
                      repeat: false,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  // Main Text
                  Text(
                    mainText,
                    style: GoogleFonts.montserrat(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5.0),
                  // Sub Text
                  Text(
                    subText,
                    style: GoogleFonts.montserrat(
                      fontSize: 14.0,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.0),
                  
                ],
              ),
            ),
            Positioned(
              bottom: 2.0,
              right: 10.0,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.close, color: Color.fromARGB(255, 219, 140, 140),size:20),
                color: Color.fromARGB(255, 78, 155, 82),
                iconSize: 30.0,
              ),
            ),
          ],
        ),
      );
    },
  );
}



// Custom snack bar for success messages
void showCustomSnackBar(BuildContext context, String message, {Duration duration = const Duration(seconds: 5)}) {
  final snackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    duration: duration,
    content: Container(
      decoration: BoxDecoration(
        color: Colors.transparent, // Adjust the color and opacity as needed
        borderRadius: BorderRadius.circular(8),
      ),
      child: AwesomeSnackbarContent(
        title: 'Success!',
        message: message,
        contentType: ContentType.success,
      ),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

// Custom snack bar for error messages
void showCustomSnackBarError(BuildContext context, String message, {Duration duration = const Duration(seconds: 5)}) {
  final snackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    duration: duration,
    content: AwesomeSnackbarContent(
      color: Color.fromARGB(255, 211, 101, 70),
      title: 'Error!',
      message: message,
      contentType: ContentType.failure,
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

// Custom snack bar for information messages
void showCustomSnackBarInfo(BuildContext context, String message, {Duration duration = const Duration(seconds: 5)}) {
  final snackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    duration: duration,
    content: AwesomeSnackbarContent(
      title: 'Information!',
      message: message,
      contentType: ContentType.help,
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}


void showSignOutConfirmationDialog(BuildContext context){
    final FirebaseAuth auth = FirebaseAuth.instance;
    showDialog(
                context: context,
                builder: (context) => Container(
                  padding: EdgeInsets.all(15),
                  child: AlertDialog(
                    backgroundColor: Theme.of(context).primaryColor,
                    elevation: 15,
                    title: Center(
                      child: Text('Are you sure you want to log out?',textAlign:TextAlign.center,
                      style: GoogleFonts.montserrat(color: Color.fromARGB(255, 197, 81, 73),
                      fontWeight: FontWeight.w600,fontSize: 15)),
                    ),
                    actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      Container(
                        padding: EdgeInsets.only(left: 15),
                        color: Colors.transparent,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('No, cancel',style: GoogleFonts.montserrat(fontSize: 13,color: Color.fromARGB(255, 235, 125, 117),
                          fontWeight: FontWeight.w600),),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          color: Color.fromARGB(255, 235, 125, 117),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            try {
                            Navigator.of(context).pop(); // Close the dialog
                            auth.signOut().then((value) {
                            Navigator.pushNamedAndRemoveUntil(context, '/LoginScreen', (route) => false);
                            });
                            } catch (e) {
                              errorSnackbar(context, 'oh, failed to log out');
                            }
                          },
                          child: Text('Yes, logout',style: GoogleFonts.montserrat(color: Color.fromARGB(255, 248, 245, 245),fontSize: 15,
                          fontWeight: FontWeight.w600),),
                        ),
                      ),]),
                    ],
                  ),
                ),
              );
}


// Delete account confirmation box
void showAccountDeletionConfirmationDialog(BuildContext context) {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final user = auth.currentUser;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            color: AppColors.myGrey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      "Are you sure you want to delete your account?",
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        color: AppColors.myDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Divider(
                  color: Colors.grey,
                  height: 1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: AppColors.popupErrorRed),
                        iconSize: 30,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.check, color: AppColors.popupSuccesGreen),
                        iconSize: 30,
                        onPressed: () async {
                          Navigator.of(context).pop();
                          try {
                            await user!.delete();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/LoginScreen',
                              (route) => false,
                            );
                          } catch (e) {
                            showCustomSnackBarError(context, "Login again to perform this action");
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
