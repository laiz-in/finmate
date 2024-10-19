import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/common/widgets/success_snackbar.dart';
import 'package:moneyy/firebase/firebase_utils.dart' as firebase_utils;


class DeleteExpenseButton extends StatelessWidget {
  final String uidOfTransaction;

  const DeleteExpenseButton({super.key,
    required this.uidOfTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              elevation: 15,
              title: Center(
                child: Text(
                  'Are you sure you want to delete this expense?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Color.fromARGB(255, 197, 81, 73),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),


              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // cancel button
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'No, cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Color.fromARGB(255, 173, 108, 103),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // proceed to delete button
                    Padding(
                      padding: const EdgeInsets.all(8.0),

                      child: Container(
                        decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        color: Color.fromARGB(255, 212, 76, 66),

                      ),
                        child: TextButton(
                          onPressed: () async {
                            final userId = FirebaseAuth.instance.currentUser?.uid;
                            final transactionId = uidOfTransaction;
                            if (userId == null) {
                              errorSnackbar(context, 'User not logged in');
                              return;
                            }
                        
                            try {
                              await firebase_utils.deleteTransaction(
                                context,
                                userId,
                                transactionId,
                              );
                              Navigator.of(context).pop();
                        
                              successSnackbar(context, "Transaction has been deleted");
                            } catch (e) {
                              Navigator.of(context).pop();
                              errorSnackbar(context, 'Failed to delete: ${e.toString()}');
                            } finally {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                            }
                          },
                          child: Text(
                            'Yes, delete',
                            style: GoogleFonts.poppins(
                              color: Color.fromARGB(255, 248, 245, 245),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        label: Icon(Icons.delete_outlined,size: 25,color: Color.fromARGB(255, 155, 77, 77),),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(
            Color.fromARGB(255, 248, 214, 214),
          ),
          elevation: WidgetStateProperty.all<double>(0),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
        ),
      ),
    );
  }
}
