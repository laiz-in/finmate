// FILEPATH: /C:/Users/Hp/Desktop/moneyy - Copy/moneyy/lib/presentation/screens/expenses/delete_expense_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // IMPORT SCREENUTIL
import 'package:google_fonts/google_fonts.dart';

class DeleteExpenseButton extends StatefulWidget {
  final Future<void> Function() onDeleteConfirmed; // MAKE ONDELETECONFIRMED ASYNC TO AWAIT OPERATION

  const DeleteExpenseButton({
    super.key,
    required this.onDeleteConfirmed,
  });

  @override
  State<DeleteExpenseButton> createState() => _DeleteExpenseButtonState();
}

class _DeleteExpenseButtonState extends State<DeleteExpenseButton> {
  bool _isLoading = false; // TRACK LOADING STATE

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        // SHOW CONFIRMATION DIALOG
        final isConfirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            buttonPadding: EdgeInsets.all(0),
            backgroundColor: Colors.white,
            elevation: 15,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26.0.r), // USE SCREENUTIL FOR BORDER RADIUS
            ),
            title: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h), // USE SCREENUTIL FOR PADDING
                  child: Center(
                    child: Text(
                      'Are you sure you want to delete this expense?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Color.fromARGB(255, 197, 81, 73),
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp, // USE SCREENUTIL FOR FONT SIZE
                      ),
                    ),
                  ),
                ),
                Divider(color: Colors.red.withOpacity(0.2), endIndent: 0),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // CANCEL BUTTON
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false), // RETURN FALSE ON CANCEL
                    child: Text(
                      'No, cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp, // USE SCREENUTIL FOR FONT SIZE
                        color: Color.fromARGB(255, 173, 108, 103),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w), // USE SCREENUTIL FOR WIDTH
                  
                  // CONFIRM DELETE BUTTON
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 189, 84, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0.r), // USE SCREENUTIL FOR BORDER RADIUS
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 28.w), // USE SCREENUTIL FOR PADDING
                    ),
                    child: Text(
                      'Delete',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp, // USE SCREENUTIL FOR FONT SIZE
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true); // RETURN TRUE ON CONFIRMATION
                    },
                  ),
                ],
              ),
            ],
          ),
        );

        // PERFORM DELETE IN PARENT IF CONFIRMED
        if (isConfirmed == true) {
          setState(() {
            _isLoading = true;
          });
          await widget.onDeleteConfirmed();
          setState(() {
            _isLoading = false;
          });
        }
      },
      icon: const Icon(Icons.delete_outlined, size: 25, color: Color.fromARGB(255, 155, 77, 77)),
      label: _isLoading
          ? SizedBox(
              height: 16.h, // USE SCREENUTIL FOR HEIGHT
              width: 16.w, // USE SCREENUTIL FOR WIDTH
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 155, 77, 77),
                strokeWidth: 2.0,
              ),
            )
          : Text(
              'Delete',
              style: GoogleFonts.poppins(
                fontSize: 14.sp, // USE SCREENUTIL FOR FONT SIZE
                color: const Color.fromARGB(255, 155, 77, 77),
                fontWeight: FontWeight.w500,
              ),
            ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 248, 214, 214),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0.r), // USE SCREENUTIL FOR BORDER RADIUS
        ),
      ),
    );
  }
}