import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteBillButton extends StatefulWidget {
  final Future<void> Function() onDeleteConfirmed; // MAKE onDeleteConfirmed ASYNC TO AWAIT OPERATION

  const DeleteBillButton({
    super.key,
    required this.onDeleteConfirmed,
  });

  @override
  State<DeleteBillButton> createState() => _DeleteBillButtonState();
}

class _DeleteBillButtonState extends State<DeleteBillButton> {
  bool _isLoading = false; // TRACK LOADING STATE

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        // SHOW CONFIRMATION DIALOG
        final isConfirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            buttonPadding: EdgeInsets.all(0), // PADDING
            backgroundColor: Colors.white,
            elevation: 15,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26.0.r), // RADIUS
            ),
            title: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 10.0.h), // PADDING
                  child: Center(
                    child: Text(
                      'Are you sure you want to delete this bill?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Color.fromARGB(255, 197, 81, 73),
                        fontWeight: FontWeight.w500,
                        fontSize: 15.sp, // FONT SIZE
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
                        fontSize: 13.sp, // FONT SIZE
                        color: Color.fromARGB(255, 173, 108, 103),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  // CONFIRM DELETE BUTTON
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 189, 84, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0.r), // RADIUS
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10.0.h, horizontal: 28.0.w), // PADDING
                    ),
                    child: Text(
                      'Delete',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp, // FONT SIZE
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
      icon: Icon(
        Icons.delete_outlined,
        size: 22.sp, // ICON SIZE
        color: Color.fromARGB(255, 155, 77, 77),
      ),
      label: _isLoading
          ? SizedBox(
              height: 16.h, // HEIGHT
              width: 16.w, // WIDTH
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 155, 77, 77),
                strokeWidth: 2.0.w, // STROKE WIDTH
              ),
            )
          : Text(
              'Delete',
              style: GoogleFonts.poppins(
                fontSize: 12.sp, // FONT SIZE
                color: const Color.fromARGB(255, 155, 77, 77),
                fontWeight: FontWeight.w500,
              ),
            ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 248, 214, 214),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0.r), // RADIUS
        ),
      ),
    );
  }
}