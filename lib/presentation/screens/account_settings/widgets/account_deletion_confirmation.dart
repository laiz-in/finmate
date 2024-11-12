import 'package:flutter/material.dart';
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
  bool isLoading = false; // To track the loading state

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: AlertDialog(
        backgroundColor: Colors.white,
        elevation: 15,

        // Account deletion confirmation heading
        title: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Center(
                child: Text(
                  'Do you want to delete your account? All data will be cleared.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(255, 214, 76, 66),
                    fontWeight: FontWeight.w500,
                    fontSize: 14
                    ,
                  ),
                ),
              ),
            ),

            Divider(color: Colors.red.withOpacity(0.3),endIndent: 0,indent: 0,)
          ],
        ),

        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // Cancel button
              Container(
                padding: const EdgeInsets.only(left: 5),
                color: Colors.transparent,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'No, cancel',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color.fromARGB(255, 235, 125, 117),
                      fontWeight: FontWeight.w500,
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
                  onPressed: isLoading
                      ? null // Disable button while loading
                      : () async {
                          await _handleAccountDeletion(context);
                        },
                  child: isLoading
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                      ) // Show loading indicator
                      : Text(
                          'Yes, delete',
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

  // Function to call the account deletion use case
  Future<void> _handleAccountDeletion(BuildContext context) async {
    setState(() {
      isLoading = true; // Start loading
    });



    final accountDeletionUseCase = sl<AccountDeletionUseCase>();
    final result = await accountDeletionUseCase.call();

    result.fold(
      // If an error occurred
      (l) {
        if (mounted) {
          setState(() {
            isLoading = false; // Stop loading on error
          });
              // Close the dialog only if mounted
          if (mounted) {
            Navigator.of(context).pop();
          }
          errorSnackbar(context, l.toString());

        }
      },
      // If account deletion is successful
      (r) {
        
          setState(() {
            isLoading = false; // Stop loading on success
          });
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.logIn, // Define this route
            (route) => false,
          );
        
      },

    );
  }
}
