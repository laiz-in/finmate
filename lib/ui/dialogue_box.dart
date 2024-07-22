import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../styles/themes.dart';
import '../ui/error_snackbar.dart';


// confirmation dialog box to log out
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
                            errorSnackbar(context, "Login again to perform this action");
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
