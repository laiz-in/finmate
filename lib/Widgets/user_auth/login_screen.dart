import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../styles/themes.dart';
import '../../ui/error_snackbar.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _errorMessage;

  // Funtion to perform log in operations
  Future<void> _loginWithEmailAndPassword(BuildContext context) async {
    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final user = _auth.currentUser;


      // Sign in the user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Check if the email is verified
      if (!userCredential.user!.emailVerified){
        // Email not verified case
              setState(() {
              _errorMessage = "Email not verified";
              });
              _auth.signOut();
              errorSnackbar(context, _errorMessage!);
              return;
      }
      
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({'status': 1});
      // Email verified, navigate to HomeScreen
      Navigator.pushReplacementNamed(context, '/HomeScreen');

    } catch (error) {
      // General error handling
      setState(() {
        _errorMessage = "Incorrect email or password";
      });
      errorSnackbar(context, _errorMessage!);
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Color(0xFF4C7766),
        resizeToAvoidBottomInset: true, // Allow the layout to resize when the keyboard appears
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                
                SizedBox(height: 60),
                // Login headig
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 17,),
                    Text(
                      'Login',
                      style: GoogleFonts.montserrat(
                        color: Theme.of(context).primaryColor,
                        fontSize: 35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 10), // Add some space between the text and icon
                    Icon(
                      Icons.arrow_forward,
                      color: Theme.of(context).primaryColor,
                      size: 40,
                    ),
                  ],
                ),

                SizedBox(height: 40),

                // Email field
                Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 20, 10.0, 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 32, 32, 32).withOpacity(0.2),
                  spreadRadius: 8,
                  blurRadius: 12,
                  offset: Offset(0, 8), // changes position of shadow
                ),
              ],
                    ),
                    child: TextField(
                      controller: _emailController,
                      cursorColor: Colors.white.withOpacity(0.7),
                      style: GoogleFonts.montserrat(
                        color:  Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                        fontSize: 20,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 134, 168, 163),
                        contentPadding: EdgeInsets.all(18),
                        prefixIcon: Icon(Icons.email,size: 22, color: Colors.white.withOpacity(0.5)),
                        label: Text(
                          'Email',
                          style: GoogleFonts.montserrat(color: Colors.white.withOpacity(0.5), fontSize: 16,fontWeight:FontWeight.w500 ),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle: GoogleFonts.montserrat(
                          color: AppColors.myFadeblue,
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 134, 168, 163),width: 0),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color:Color.fromARGB(255, 134, 168, 163), width: 0),
                    
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color:Colors.white.withOpacity(0.5), width: 1),
                    
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                  ),
                ),

                // Password field
                Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 1, 10.0, 10.0),
                  child: Container(
                      decoration: BoxDecoration(
                      boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 32, 32, 32).withOpacity(0.2),
                  spreadRadius: 8,
                  blurRadius: 15,
                  offset: Offset(0, 8), // changes position of shadow
                ),
              ],
                    ),
                    child: TextField(
                      cursorColor:Colors.white.withOpacity(0.7),
                      controller: _passwordController,
                      obscureText: true,
                      style: GoogleFonts.montserrat(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                        fontSize: 20,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 134, 168, 163),
                        prefixIcon: Icon(Icons.lock,size: 22, color:Colors.white.withOpacity(0.5)),
                        contentPadding: EdgeInsets.all(18),
                        label: Text('Password', style: GoogleFonts.montserrat(fontSize: 16,
                        color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w500)),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle: GoogleFonts.montserrat(color: Colors.yellow, fontWeight: FontWeight.w500),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color:Theme.of(context).cardColor, width: 1),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color:Theme.of(context).cardColor, width: 0),
                    
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // forgot password link
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                                      Navigator.pushNamed(context, '/ResetPasswordScreen');
                                      },
                        child: Text(
                          "Forgot Password?",
                          style: GoogleFonts.montserrat(
                            color: Colors.white.withOpacity(0.4),
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Login button
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                    onTap: () => _loginWithEmailAndPassword(context),
                    child: Container(
                      height: 65,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 32, 32, 32).withOpacity(0.2),
                            spreadRadius: 8,
                            blurRadius: 18,
                            offset: Offset(0, 8), // changes position of shadow
                          ),
                        ],
                        color:Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Login',
                              style: GoogleFonts.montserrat(
                                color:Color(0xFF4C7766),
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // dont have an account section
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: GoogleFonts.montserrat(
                          color:Theme.of(context).primaryColor.withOpacity(0.5),
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 5), // Add space between texts
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/SignUpScreen');
                        },
                        child: Text(
                          "Sign up",
                          style: GoogleFonts.montserrat(
                            color: Color.fromARGB(255, 166, 192, 245),
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
