import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/domain/usecases/auth/sign_out.dart';
import 'package:moneyy/presentation/routes/routes.dart';
import 'package:moneyy/service_locator.dart';

class SignOutConfirmationDialog extends StatefulWidget {
  
  const SignOutConfirmationDialog({super.key});

  @override
  State<SignOutConfirmationDialog> createState() => _SignOutConfirmationDialogState();
}

class _SignOutConfirmationDialogState extends State<SignOutConfirmationDialog> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),


      child: AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.white,
        elevation: 15,

        // Log out confirmation text
        title: Column(
          children: [

            Padding(
              padding: const EdgeInsets.all(5),
              child: Center(
                child: Text(
                  'Are you sure you want to log out?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(255, 197, 81, 73),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          
          SizedBox(height: 8,),

          SizedBox(
                width: double.infinity, // This will make the Divider expand to the full width
                child: Divider(
                  endIndent: 0,
                  indent: 0,
                  color: Colors.red.withOpacity(0.3),
                  height: 1, // Adjust thickness as needed
                ),
              ),          ],
        ),


        
        actions: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              // Cancel button
              Container(
                padding: const EdgeInsets.only(left: 15),
                color: Colors.transparent,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'No, cancel',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color.fromARGB(255, 235, 125, 117),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Proceed button
              Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: Color.fromARGB(255, 212, 76, 66),
                ),
                child: TextButton(
                  onPressed: () => _handleSignOut(),
                  child: Text(
                    'Yes, logout',
                    style: GoogleFonts.poppins(
                      color: const Color.fromARGB(255, 248, 245, 245),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }

// function to call the signout use case
Future<void> _handleSignOut() async {
    // Close the dialog
    if (mounted) {
      Navigator.of(context).pop();
    }
    final signOutUseCase = sl<SignOutUseCase>();
    final result = await signOutUseCase.call();
    result.fold(
      // If any error occured
      (l) {
        errorSnackbar(context, l.toString());
      },
      // If Sign out is success
      (r) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.logIn, (route) => false);
      },
    );
  }
}
