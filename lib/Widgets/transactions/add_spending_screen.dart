import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../ui/error_snackbar.dart';
import '../../ui/succes_snackbar.dart';

class AddSpendingBottomSheet extends StatefulWidget {
  @override
  _AddSpendingBottomSheetState createState() => _AddSpendingBottomSheetState();
}

class _AddSpendingBottomSheetState extends State<AddSpendingBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  double _spendingAmount = 0.0;
  String _spendingCategory = 'Groceries';
  String _spendingDescription = '';
  DateTime? _spendingDate = DateTime.now();
  final TextEditingController _dateController = TextEditingController();
  bool _isLoading = false;


  final List<String> _categories = [
    'Groceries',
    'Stationary',
    'Food',
    'Entertainment',
    'Transport',
    'Bills'
    'Other',
  ];

 // function to select the date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _spendingDate ?? DateTime.now(),
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
    _dateController.text = "${_spendingDate?.toLocal()}".split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
      decoration: BoxDecoration(
        
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(
        Radius.circular(20)
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            // Title add +
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 8, 5, 20),
              child: Text(
                'Add Expense +',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  color: Theme.of(context).cardColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // Amount field
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
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
              decoration: InputDecoration(
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
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                      child: Text(
                        category,
                        style: GoogleFonts.montserrat(
                          color: Theme.of(context).cardColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
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
              style: GoogleFonts.montserrat(
                color: Theme.of(context).cardColor,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Description',
                hintStyle: GoogleFonts.montserrat(
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
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
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
            
            // Add button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
      
                TextButton(
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 105, 40, 39),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
      
                SizedBox(width: 10,),
      

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                  ),
                  child: _isLoading
                      ?Row(
                          children: [
                            Text(
                          'Adding  ',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          '  Add +  ',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),


                  
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                      });
                      
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        try {
                          final userDocRef = FirebaseFirestore.instance.collection("users").doc(user.uid);
                          final userDocSnapshot = await userDocRef.get();
                          final currentTotalSpending = userDocSnapshot.get('totalSpending') ?? 0.0;
                          final newTotalSpending = currentTotalSpending + _spendingAmount;

                          await userDocRef.update({'totalSpending': newTotalSpending});
                          final newSpendingRef = FirebaseFirestore.instance
                              .collection("users")
                              .doc(user.uid)
                              .collection("spendings")
                              .doc(); // Create a DocumentReference with a generated ID

                          await newSpendingRef.set({
                            'spendingAmount': _spendingAmount,
                            'spendingCategory': _spendingCategory,
                            'spendingDescription': _spendingDescription,
                            'spendingDate': _spendingDate,
                            'createdAt': FieldValue.serverTimestamp(),
                            'uidOfTransaction': newSpendingRef.id, // Store the generated document ID
                          });
                          
                          if (mounted){
                          successSnackbar(context, 'Spending added successfully!');

                          Navigator.of(context).pop();
                          }


                        } catch (e) {
                          errorSnackbar(context,"Error adding spending: $e");
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      } else {
                        errorSnackbar(context, 'User not logged in!');
                        setState(() {
                          _isLoading = false;
                        });
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
