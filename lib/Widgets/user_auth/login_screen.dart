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

  Future<void> _loginWithEmailAndPassword(BuildContext context) async {
    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      // Sign in the user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the email is verified
      if (!userCredential.user!.emailVerified) {
        // Email not verified
        setState(() {
          _errorMessage = "Email not verified";
        });
        _auth.signOut();
        errorSnackbar(context, _errorMessage!);
        return;
      }

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
        backgroundColor: Theme.of(context).cardColor,
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
                  child: TextField(
                    controller: _emailController,
                    cursorColor: Theme.of(context).cardColor,
                    style: GoogleFonts.montserrat(
                      color: Theme.of(context).cardColor,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).primaryColorDark   ,
                      contentPadding: EdgeInsets.all(20),
                      prefixIcon: Icon(Icons.email, color: AppColors.myFadeblue),
                      label: Text(
                        'Email',
                        style: TextStyle(fontSize: 18),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelStyle: GoogleFonts.montserrat(
                        color: AppColors.myFadeblue,
                        fontWeight: FontWeight.w500,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color:Theme.of(context).primaryColorDark, width: 1),

                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color:Theme.of(context).primaryColorDark, width: 1),

                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                  ),
                ),

                // Password field
                Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 1, 10.0, 20.0),
                  child: TextField(
                    cursorColor:Theme.of(context).cardColor,
                    controller: _passwordController,
                    obscureText: true,
                    style: GoogleFonts.montserrat(
                      color: Theme.of(context).cardColor,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).primaryColorDark,
                      prefixIcon: Icon(Icons.lock, color:AppColors.myFadeblue),
                      contentPadding: EdgeInsets.all(20),
                      label: Text('Password', style: GoogleFonts.montserrat(fontSize: 18,
                      color: AppColors.myFadeblue, fontWeight: FontWeight.w500)),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelStyle: GoogleFonts.montserrat(color: AppColors.myGrey, fontWeight: FontWeight.w500),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color:Theme.of(context).primaryColorDark, width: 1),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(color:Theme.of(context).primaryColorDark, width: 1),

                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(color:Theme.of(context).primaryColorDark, width: 1),
                      ),
                    ),
                  ),
                ),
                
                // forgot password link
                Padding(
                  padding: EdgeInsets.only(left: 8, top: 5, right: 25),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/ResetPasswordScreen');
                    },
                    child: Row(
                      children: [
                        Spacer(),
                        Text(
                          "Forgot Password?",
                          style: GoogleFonts.montserrat(
                            color: Theme.of(context).primaryColor.withOpacity(0.7),
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Login button
                InkWell(
                  onTap: () => _loginWithEmailAndPassword(context),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      height: 65,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color:Theme.of(context).primaryColorLight,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Login',
                              style: GoogleFonts.montserrat(
                                color:Theme.of(context).cardColor,
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
                  padding: const EdgeInsets.only(left: 90.0, top: 30),
                  child: Row(
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
