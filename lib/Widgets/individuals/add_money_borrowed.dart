import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddMoneyBorrowedDialog extends StatefulWidget {
  @override
  _AddMoneyBorrowedDialogState createState() => _AddMoneyBorrowedDialogState();
}

class _AddMoneyBorrowedDialogState extends State<AddMoneyBorrowedDialog> {
  final _formKey = GlobalKey<FormState>();
  String _fromWho = '';
  double _borrowedAmount = 0;
  String _borrowedMoneyDescription = '';
  DateTime? _borrowedReturnDate;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = _borrowedReturnDate != null
        ? "${_borrowedReturnDate?.toLocal()}".split(' ')[0]
        : '';
  }

  // Function for selecting date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _borrowedReturnDate ?? DateTime.now(),
      firstDate: DateTime.now(), // Only allow dates from today onwards
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _borrowedReturnDate) {
      setState(() {
        _borrowedReturnDate = pickedDate;
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Borrowed money'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[

              // Title field to add "from whom"
              TextFormField(
                decoration: InputDecoration(labelText: 'To whom?'),
                onChanged: (value) {
                  _fromWho = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please tell from who you borrowed money';
                  }
                  return null;
                },
              ),

            // field to add how much the borrowed money
            TextFormField(
                decoration: InputDecoration(labelText: 'How much?'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  try {
                    _borrowedAmount = double.parse(value);
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),


              // Date field to your due
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Due date'),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),

              // Borrowed money description field
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  _borrowedMoneyDescription = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),


            ],
          ),
        ),
      ),
      actions: <Widget>[
        // Cancel button
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),

        // Add button
        ElevatedButton(
          child: Text('Add money borrowed'),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(user.uid)
                    .collection("borrowedMoney")
                    .add({
                  'fromWho': _fromWho,
                  'borrowedAmount': _borrowedAmount,
                  'borrowedReturnDate': _borrowedReturnDate,
                  'borrowedMoneyDescription': _borrowedMoneyDescription,
                  'addedDate': DateTime.now(),
                });
                

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('  Borrowed money record has been added')),
                );
              } else {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not add record')),
                );
              }
            }
          },
        ),
      ],
    );
  }
}
