import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/styles/themes.dart';
import 'package:moneyy/ui/error_snackbar.dart';

import '../../ui/succes_snackbar.dart';

class ResetMonthlyLimit extends StatefulWidget {
  const ResetMonthlyLimit({super.key});


  @override
  State<ResetMonthlyLimit> createState() => _ResetMonthlyLimitState();
}

class _ResetMonthlyLimitState extends State<ResetMonthlyLimit> {
  final TextEditingController _limitController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Reset daily limit logic
  void _resetMonthlyLimit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = _auth.currentUser;

        if (user != null) {
          int newLimit = int.parse(_limitController.text);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'monthlyLimit': newLimit});
          successSnackbar(context, 'Monthly limit has been updated');
        }
      } catch (e) {
        // Show error message if updating daily limit fails
        errorSnackbar(context, "Unable to update monthly limit");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        backgroundColor: Color(0xFF4C7766),
        iconTheme: IconThemeData(color: Colors.white.withOpacity(0.7)),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            // Container
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF4C7766),
              ),
            ),
            // Align for the email and button Text fields
            Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 40,),
                      // Password reset heading
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(
                              Icons.settings,
                              color: Colors.white.withOpacity(0.7),
                              size: 35,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Reset monthly limit',
                              style: GoogleFonts.montserrat(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15,),
                      // Amount field
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.0, 20, 20, 0),
                        child: TextFormField(
                          controller: _limitController,
                          cursorColor: Colors.white.withOpacity(0.7),
                          style: GoogleFonts.montserrat(
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                            fontSize: 20,
                          ),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            fillColor: Color.fromARGB(255, 134, 168, 163),
                            filled: true,
                            contentPadding: EdgeInsets.all(16),
                            prefixIcon: Icon(
                              Icons.currency_rupee,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            label: Text(
                              'Enter amount',
                              style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.5)),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelStyle: GoogleFonts.montserrat(
                              color: AppColors.myFadeblue,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Color.fromARGB(255, 134, 168, 163), width: 0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Color.fromARGB(255, 134, 168, 163), width: 0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Color.fromARGB(255, 134, 168, 163), width: 0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            if (!RegExp(r'^\d+$').hasMatch(value)) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      // Send button
                      InkWell(
                        onTap: _resetMonthlyLimit,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.0, 10, 20, 20),
                          child: Container(
                            height: 63,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(15.0),
                            ),

                            child: Center(
                              child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Submit',
                                    style: GoogleFonts.montserrat(
                                      color: Color(0xFF4C7766),
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 15,),
                                  if (_isLoading)
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF4C7766),
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Instructions
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          softWrap: true,
                          'Note: Your monthly limit will remain the same until you update it next time',
                          style: GoogleFonts.montserrat(
                            color: const Color.fromARGB(255, 245, 195, 195).withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
