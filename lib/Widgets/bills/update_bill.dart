import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../ui/error_snackbar.dart';
import '../../ui/succes_snackbar.dart';

class UpdateBillDialog extends StatefulWidget {
  final DocumentSnapshot bill;

  UpdateBillDialog({required this.bill, Key? key}) : super(key: key);

  @override
  _UpdateBillDialogState createState() => _UpdateBillDialogState();
}

class _UpdateBillDialogState extends State<UpdateBillDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _billTitle;
  late double _billAmount;
  late String _billDescription;
  DateTime? _billDueDate;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _billTitle = widget.bill['billTitle'];
    _billAmount = widget.bill['billAmount'];
    _billDescription = widget.bill['billDescription'];
    _billDueDate = widget.bill['billDueDate']?.toDate();
    _dateController.text = _billDueDate != null
        ? "${_billDueDate!.toLocal()}".split(' ')[0]
        : "due date";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _billDueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _billDueDate) {
      setState(() {
        _billDueDate = pickedDate;
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

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
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 8, 5, 20),
              child: Text(
                'Update Bill',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  color: Theme.of(context).cardColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextFormField(
              initialValue: _billAmount.toString(),
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
                  _billAmount = double.parse(value);
                } catch (e) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            SizedBox(height: 15),
            TextFormField(
              initialValue: _billTitle,
              style: GoogleFonts.montserrat(
                color: Theme.of(context).cardColor,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'Bill Title',
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
                  return 'Please enter a title';
                }
                _billTitle = value;
                return null;
              },
            ),
            SizedBox(height: 15),
            TextFormField(
              initialValue: _billDescription,
              style: GoogleFonts.montserrat(
                color: Theme.of(context).cardColor,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'Bill description',
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
                _billDescription = value;
                return null;
              },
            ),
            SizedBox(height: 15),
            TextFormField(
              style: GoogleFonts.montserrat(
                color: Theme.of(context).cardColor,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'Select Due Date',
                filled: true,
                fillColor: Theme.of(context).cardColor.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
              ),
              controller: _dateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a date';
                }
                return null;
              },
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                  ),
                  child: Text(
                    'Update',
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
                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(user.uid)
                              .collection("bills")
                              .doc(widget.bill.id)
                              .update({
                                'billTitle': _billTitle,
                                'billAmount': _billAmount,
                                'billDueDate': _billDueDate,
                                'billDescription': _billDescription,
                              });
                          successSnackbar(context, 'Bill updated successfully!');
                          Navigator.of(context).pop();
                        } catch (e) {
                          errorSnackbar(context, 'Error updating bill: $e');
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
