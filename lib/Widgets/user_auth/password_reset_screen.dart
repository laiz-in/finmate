import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/styles/themes.dart';
import 'package:moneyy/ui/error_snackbar.dart';

import '../../ui/succes_snackbar.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Reset password logic
  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      successSnackbar(context, 'Email has been sent');
      } catch (e) {
      // dilaloge message to error when sending verification email
      errorSnackbar(context, "Failed to send");
      }// vatch block ends
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                      SizedBox(height: 50,),
                      // Password reset heading
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                        child: Row(
                          children: [
                            Text(
                              'Reset password',
                              style: GoogleFonts.montserrat(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.settings_backup_restore_outlined,
                              color:Colors.white.withOpacity(0.7),
                              size: 35,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 15,),
                      // Email address field
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.0, 30, 20, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 32, 32, 32).withOpacity(0.2),
                              spreadRadius: 8,
                              blurRadius: 15,
                              offset: Offset(0, 4), // changes position of shadow
                            ),
                          ],
                          ),
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
                              contentPadding: EdgeInsets.all(20),
                              prefixIcon: Icon(
                                Icons.email,
                                color:Colors.white.withOpacity(0.7),
                              ),
                              label: Text(
                                'Verification Email',
                                style: GoogleFonts.montserrat(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.white.withOpacity(0.7)),
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
                      ),
                      SizedBox(height: 20),
                      
                      // Send button
                      InkWell(
                        onTap: _resetPassword,
                        child:Padding(
                          padding: EdgeInsets.fromLTRB(20.0, 10, 20, 20),
                        child:
                          Container(
                          height: 63,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 32, 32, 32).withOpacity(0.2),
                              spreadRadius: 8,
                              blurRadius: 15,
                              offset: Offset(0, 4), // changes position of shadow
                            ),
                          ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                            'Verify',
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
