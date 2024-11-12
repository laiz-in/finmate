import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteExpenseButton extends StatefulWidget {
  final Future<void> Function() onDeleteConfirmed; // Make onDeleteConfirmed async to await operation

  const DeleteExpenseButton({
    super.key,
    required this.onDeleteConfirmed,
  });

  @override
  State<DeleteExpenseButton> createState() => _DeleteExpenseButtonState();
}

class _DeleteExpenseButtonState extends State<DeleteExpenseButton> {
  bool _isLoading = false; // Track loading state

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        // Show confirmation dialog
        final isConfirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            buttonPadding: EdgeInsets.all(0),
            backgroundColor: Colors.white,
            elevation: 15,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26.0),
            ),


            title: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Center(
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
                ),

                Divider(color: Colors.red.withOpacity(0.2),endIndent: 0,)
              ],
            ),


            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel button
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false), // Return false on cancel
                    child: Text(
                      'No, cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Color.fromARGB(255, 173, 108, 103),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // Confirm delete button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 189, 84, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 28.0),
                    ),
                    child: Text(
                      'Delete',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true); // Return true on confirmation
                    },
                  ),
                ],
              ),
            ],
          ),
        );

        // Perform delete in parent if confirmed
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
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 155, 77, 77),
                strokeWidth: 2.0,
              ),
            )
          : Text(
              'Delete',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color.fromARGB(255, 155, 77, 77),
                fontWeight: FontWeight.w500,
              ),
            ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 248, 214, 214),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}
