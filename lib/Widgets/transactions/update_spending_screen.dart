import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/styles/themes.dart';
import 'package:moneyy/ui/succes_snackbar.dart';

import '../../ui/error_snackbar.dart';

class UpdateSpendingDialog extends StatefulWidget {
  final double initialAmount;
  final String initialCategory;
  final String initialDescription;
  final DateTime initialDate;
  final String transactionId;
  final Function(double, String, String, DateTime) onSubmit;

  UpdateSpendingDialog({
    required this.initialAmount,
    required this.initialCategory,
    required this.initialDescription,
    required this.initialDate,
    required this.transactionId,
    required this.onSubmit,
  });

  @override
  _UpdateSpendingDialog createState() => _UpdateSpendingDialog();
}

class _UpdateSpendingDialog extends State<UpdateSpendingDialog> {
  final _formKey = GlobalKey<FormState>();
  late double _spendingAmount;
  late String _spendingCategory;
  late String _spendingDescription;
  late DateTime _spendingDate;
  final TextEditingController _dateController = TextEditingController();

  final List<String> _categories = [
    'Groceries',
    'Stationary',
    'Food',
    'Entertainment',
    'Transport',
    'Other'
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _spendingDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _spendingDate) {
      setState(() {
        _spendingDate = pickedDate;
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _spendingAmount = widget.initialAmount;
    _spendingCategory = widget.initialCategory;
    _spendingDescription = widget.initialDescription;
    _spendingDate = widget.initialDate;
    _dateController.text = "${_spendingDate.toLocal()}".split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
      contentPadding: EdgeInsets.all(25.0),
      
      shape: RoundedRectangleBorder(
        
        borderRadius: BorderRadius.circular(26.0),
      ),
      elevation: 15,
      backgroundColor: Theme.of(context).primaryColor,

      // Title text
      title: Text(
        'Edit your expense',
        style: GoogleFonts.montserrat(
          fontSize: 18,
          color: Theme.of(context).cardColor,
          fontWeight: FontWeight.w700,
        ),
      ),
      
      content: Form(

        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(height: 5),

              // Amounr field
              TextFormField(
                initialValue: _spendingAmount.toString(),
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
                    fontWeight: FontWeight.w500,
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
                    _spendingAmount = double.parse(value);
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Dropdown to select category
              DropdownButtonFormField<String>(
                
                value: _spendingCategory,
                style: GoogleFonts.montserrat(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: GoogleFonts.montserrat(
                    fontSize: 17,
                    color:Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  filled: true,
                  fillColor: Theme.of(context).cardColor.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                ),
                dropdownColor: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    
                    value: category,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12))
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                        child: Text(
                          category,
                          style: GoogleFonts.montserrat(
                            color: Theme.of(context).cardColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _spendingCategory = value!;
                  });
                },
                isExpanded: true,
              ),
              SizedBox(height: 15),

              // Description field
              TextFormField(
                initialValue: _spendingDescription,
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
                  _spendingDescription = value;
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Date field
              TextFormField(
                style: GoogleFonts.montserrat(
                  color: Theme.of(context).cardColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  
                  filled: true,
                  fillColor:Theme.of(context).cardColor.withOpacity(0.3),
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

            ],
          ),
        ),
      ),
      actions: <Widget>[

        // Cancel button
        TextButton(
          child: Text(
            'Cancel',
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.myOrange,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        
        // Update button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:Theme.of(context).cardColor, // Background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0), // Set the border radius
            ),
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0), // Optional padding
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
              // Update Firebase instance
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                // Fetch the existing spending data
                final spendingRef = FirebaseFirestore.instance
                    .collection("users")
                    .doc(user.uid)
                    .collection("spendings")
                    .doc(widget.transactionId);
                final spendingSnapshot = await spendingRef.get();
                final currentAmount = spendingSnapshot.get('spendingAmount') ?? 0.0;

                // Update the spending data
                await spendingRef.update({
                  'spendingAmount': _spendingAmount,
                  'spendingCategory': _spendingCategory,
                  'spendingDescription': _spendingDescription,
                  'date': _spendingDate,
                });

                // Update total_spending
                final userDocRef = FirebaseFirestore.instance.collection("users").doc(user.uid);
                final userDocSnapshot = await userDocRef.get();
                final currentTotalSpending = userDocSnapshot.get('totalSpending') ?? 0.0;
                final newTotalSpending = currentTotalSpending - currentAmount + _spendingAmount;
                await userDocRef.update({'totalSpending': newTotalSpending});

                // Execute the onSubmit callback
                widget.onSubmit(_spendingAmount, _spendingCategory, _spendingDescription, _spendingDate);

                // Show success message
                Navigator.of(context).pop();
                successSnackbar(context, 'Spending has been updated');

                // Clear form fields
                setState(() {
                  _spendingAmount = 0.0;
                  _spendingCategory = 'Groceries';
                  _spendingDescription = '';
                  _spendingDate = DateTime.now();
                  _dateController.text = "${_spendingDate.toLocal()}".split(' ')[0];
                });
              } else {
                // Show error message
                Navigator.of(context).pop();
                errorSnackbar(context, "Could not update spending");
              }
            }
          },
        ),
      
      ],
    );
  }
}
