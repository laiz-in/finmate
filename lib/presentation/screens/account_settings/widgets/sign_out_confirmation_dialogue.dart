import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      padding: EdgeInsets.all(10.w), // PADDING
      child: AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.white,
        elevation: 15,

        // LOG OUT CONFIRMATION TEXT
        title: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(5.w), // PADDING
              child: Center(
                child: Text(
                  'Are you sure you want to log out?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(255, 197, 81, 73),
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp, // FONT SIZE
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h), // SPACING
            SizedBox(
              width: double.infinity, // THIS WILL MAKE THE DIVIDER EXPAND TO THE FULL WIDTH
              child: Divider(
                endIndent: 0,
                indent: 0,
                color: Colors.red.withOpacity(0.3),
                height: 1.h, // ADJUST THICKNESS AS NEEDED
              ),
            ),
          ],
        ),

        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // CANCEL BUTTON
              Container(
                padding: EdgeInsets.only(left: 15.w), // PADDING
                color: Colors.transparent,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'No, cancel',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp, // FONT SIZE
                      color: const Color.fromARGB(255, 235, 125, 117),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // PROCEED BUTTON
              Container(
                padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0), // PADDING
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12.r)), // RADIUS
                  color: const Color.fromARGB(255, 212, 76, 66),
                ),
                child: TextButton(
                  onPressed: () => _handleSignOut(),
                  child: Text(
                    'Yes, logout',
                    style: GoogleFonts.poppins(
                      color: const Color.fromARGB(255, 248, 245, 245),
                      fontSize: 13.sp, // FONT SIZE
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

  // FUNCTION TO CALL THE SIGNOUT USE CASE
  Future<void> _handleSignOut() async {
    // CLOSE THE DIALOG
    if (mounted) {
      Navigator.of(context).pop();
    }
    final signOutUseCase = sl<SignOutUseCase>();
    final result = await signOutUseCase.call();
    result.fold(
      // IF ANY ERROR OCCURRED
      (l) {
        errorSnackbar(context, l.toString());
      },
      // IF SIGN OUT IS SUCCESS
      (r) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.logIn, (route) => false);
      },
    );
  }
}