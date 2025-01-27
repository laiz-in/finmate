import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/domain/usecases/auth/account_deletion.dart';
import 'package:moneyy/presentation/routes/routes.dart';
import 'package:moneyy/service_locator.dart';

class AccountDeletionConfirmationDialog extends StatefulWidget {
  const AccountDeletionConfirmationDialog({super.key});

  @override
  State<AccountDeletionConfirmationDialog> createState() =>
      _AccountDeletionConfirmationDialogState();
}

class _AccountDeletionConfirmationDialogState
    extends State<AccountDeletionConfirmationDialog> {
  bool isLoading = false; // TO TRACK THE LOADING STATE

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w), // PADDING
      child: AlertDialog(
        backgroundColor: Colors.white,
        elevation: 15,

        // ACCOUNT DELETION CONFIRMATION HEADING
        title: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 15.h), // PADDING
              child: Center(
                child: Text(
                  'Do you want to delete your account? All data will be cleared.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(255, 214, 76, 66),
                    fontWeight: FontWeight.w500,
                    fontSize: 13.sp, // FONT SIZE
                  ),
                ),
              ),
            ),
            Divider(
              color: Colors.red.withOpacity(0.3),
              endIndent: 0,
              indent: 0,
            ),
          ],
        ),

        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // CANCEL BUTTON
              Container(
                padding: EdgeInsets.only(left: 5.w), // PADDING
                color: Colors.transparent,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'No, cancel',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp, // FONT SIZE
                      color: const Color.fromARGB(255, 235, 125, 117),
                      fontWeight: FontWeight.w500,
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
                  onPressed: isLoading
                      ? null // DISABLE BUTTON WHILE LOADING
                      : () async {
                          await _handleAccountDeletion(context);
                        },
                  child: isLoading
                      ? SizedBox(
                          height: 20.h, // HEIGHT
                          width: 20.w, // WIDTH
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.w, // STROKE WIDTH
                          ),
                        ) // SHOW LOADING INDICATOR
                      : Text(
                          'Yes, delete',
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

  // FUNCTION TO CALL THE ACCOUNT DELETION USE CASE
  Future<void> _handleAccountDeletion(BuildContext context) async {
    setState(() {
      isLoading = true; // START LOADING
    });

    final accountDeletionUseCase = sl<AccountDeletionUseCase>();
    final result = await accountDeletionUseCase.call();

    result.fold(
      // IF AN ERROR OCCURRED
      (l) {
        if (mounted) {
          setState(() {
            isLoading = false; // STOP LOADING ON ERROR
          });
          // CLOSE THE DIALOG ONLY IF MOUNTED
          if (mounted) {
            Navigator.of(context).pop();
          }
          errorSnackbar(context, l.toString());
        }
      },
      // IF ACCOUNT DELETION IS SUCCESSFUL
      (r) {
        if (mounted) {
          setState(() {
            isLoading = false; // STOP LOADING ON SUCCESS
          });
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.logIn, // DEFINE THIS ROUTE
            (route) => false,
          );
        }
      },
    );
  }
}