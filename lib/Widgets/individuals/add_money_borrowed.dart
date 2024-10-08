import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../ui/error_snackbar.dart';
import '../../ui/succes_snackbar.dart';

class AddMoneyDialog extends StatefulWidget {
  @override
  _AddMoneyDialogState createState() => _AddMoneyDialogState();
}

class _AddMoneyDialogState extends State<AddMoneyDialog> {
  final _formKey = GlobalKey<FormState>();
  double _amount = 0;
  String _description = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // dialog box heading
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 8, 5, 20),
              child: Text(
                'Add Money +',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  color: Theme.of(context).cardColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // Money amount field
            TextFormField(
              cursorColor: Theme.of(context).cardColor.withOpacity(0.4),
              style: GoogleFonts.montserrat(
                color: Theme.of(context).cardColor,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: '0.00',
                labelStyle: GoogleFonts.montserrat(
                  fontSize: 17,
                  color: Theme.of(context).cardColor,
                  fontWeight: FontWeight.w600,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                try {
                  _amount = double.parse(value);
                } catch (e) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            SizedBox(height: 15),

            // Description field
            TextFormField(
              style: GoogleFonts.montserrat(
                color: Theme.of(context).cardColor,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'Description',
                hintStyle: GoogleFonts.montserrat(
                  fontSize: 17,
                  color: Theme.of(context).cardColor,
                  fontWeight: FontWeight.w700,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                _description = value;
                return null;
              },
            ),
            SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel button
                TextButton(
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade400,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(width: 10),

                // Add button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                  ),
                  child: Text(
                    '  Add +  ',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        try {
                          // Creates a document ID
                          final newMoneyRef = FirebaseFirestore.instance
                              .collection("users")
                              .doc(user.uid)
                              .collection("money")
                              .doc();
                          // Add the input data to Firebase
                          await newMoneyRef.set({
                            'amount': _amount,
                            'description': _description,
                            'addedDate': DateTime.now(),
                            'uidOfMoney': newMoneyRef.id, // Store the generated document ID
                          });
                          // Show success message
                          successSnackbar(context, 'Money added successfully!');
                          Navigator.of(context).pop();
                        } catch (e) {
                          errorSnackbar(context, 'Error adding money: $e');
                        }
                      } else {
                        errorSnackbar(context, 'User not logged in!');
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
