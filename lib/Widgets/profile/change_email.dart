import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/styles/themes.dart';
import 'package:moneyy/ui/error_snackbar.dart';

import '../../ui/succes_snackbar.dart';

class ResetEmail extends StatefulWidget {
  const ResetEmail({super.key});

  @override
  State<ResetEmail> createState() => _ResetEmailState();
}

class _ResetEmailState extends State<ResetEmail> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Reset password logic
  void _resetEmail() async {
    if (_formKey.currentState!.validate()) {
      try {
      User? user = _auth.currentUser;

      if (user != null) {
        print("getting email from field");
        String newEmail = _emailController.text.trim();
        await _auth.currentUser!.verifyBeforeUpdateEmail(newEmail);


        await user.sendEmailVerification();
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'status': 0});

      }

      successSnackbar(context, ' email has been sent');
      Navigator.pushNamedAndRemoveUntil(context, '/LoginScreen', (route) => false);

      } catch (e) {
      // dilaloge message to error when sending verification email
      errorSnackbar(context, "Unable to send");
      }// vatch block ends
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        backgroundColor: Color(0xFF4C7766),
        iconTheme: IconThemeData(color:Colors.white.withOpacity(0.7)),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Dismisses the keyboard when tapping outside the text field
        },
        child: Stack(
          children: [
            // Container
            Container(
              decoration: BoxDecoration(
                color:Color(0xFF4C7766),
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
                        padding:
                            EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(
                              Icons.email,
                              color:Colors.white.withOpacity(0.7),
                              size: 35,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Reset Email',
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
                      
                      // Email address field
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.0, 20, 20, 0),
                        child: TextFormField(
                          controller: _emailController,
                          cursorColor: Colors.white.withOpacity(0.7),
                          style: GoogleFonts.montserrat(
                            color:Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                            fontSize: 20,
                          ),
                          decoration: InputDecoration(
                            fillColor: Color.fromARGB(255, 134, 168, 163),
                            filled: true,
                            contentPadding: EdgeInsets.all(16),
                            prefixIcon: Icon(
                              Icons.email,
                              color:Colors.white.withOpacity(0.7),
                            ),
                            label: Text(
                              'Enter email',
                              style: GoogleFonts.montserrat(fontSize: 15,fontWeight: FontWeight.w500,color: Colors.white.withOpacity(0.5)),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelStyle: GoogleFonts.montserrat(
                              color:AppColors.myFadeblue,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Color.fromARGB(255, 134, 168, 163),width: 0),
                        
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Color.fromARGB(255, 134, 168, 163),width: 0),
                        
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Color.fromARGB(255, 134, 168, 163),width: 0),
                        
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      // Send button
                      InkWell(
                        onTap: _resetEmail,
                        child:Padding(
                          padding: EdgeInsets.fromLTRB(20.0, 10, 20, 20),
                        child:
                          Container(
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
                                SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ),
                      )
                      ),

                      // Instructions
                      Padding(
                      padding:EdgeInsets.all(20),
                            child: Text(
                              softWrap: true,
                              'Note : By clicking submit , you will be redirected to login page , please verify your new Email before login',
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
