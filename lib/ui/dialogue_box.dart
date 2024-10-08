import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/presentation/routes/routes.dart';
import 'package:moneyy/ui/succes_snackbar.dart';

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
                            await auth.signOut();
                            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.logIn, (route) => false);
                            
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
void showAccountDeletionConfirmationDialog(BuildContext context){
    final FirebaseAuth auth = FirebaseAuth.instance;
    showDialog(
                context: context,
                builder: (context) => Container(
                  padding: EdgeInsets.all(15),
                  child: AlertDialog(
                    backgroundColor: Theme.of(context).hintColor,
                    elevation: 15,
                    title: Center(
                      child: Text('You want to delete your aaccount? all datas will be deleted',textAlign:TextAlign.center,
                      style: GoogleFonts.montserrat(color: Color.fromARGB(255, 197, 81, 73),
                      fontWeight: FontWeight.w600,fontSize: 13)),
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
                            final user = auth.currentUser;

                            final userDocRef = FirebaseFirestore.instance.collection('users').doc(user?.uid);
                            await userDocRef.delete();

                            await auth.currentUser!.delete();
                            Navigator.of(context).pop(); // Close the dialog
                            Navigator.pushNamedAndRemoveUntil(
                                context, AppRoutes.logIn, (route) => false);
                            successSnackbar(context, "User account has been deleted");
                          } catch (e) {
                            errorSnackbar(context, 'You need to login again to perform this action!');
                            Navigator.of(context).pop(); // Close the dialog

                          }
                          },
                          child: Text('Yes, proceed',style: GoogleFonts.montserrat(color: Color.fromARGB(255, 248, 245, 245),fontSize: 15,
                          fontWeight: FontWeight.w600),),
                        ),
                      ),]),
                    ],
                  ),
                ),
              );
}
