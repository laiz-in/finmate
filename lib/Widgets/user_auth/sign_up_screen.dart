
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../ui/error_snackbar.dart';
import '../../ui/info_snackbar.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

Future<void> _register() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Update user profile (optional)
      await userCredential.user!.updateDisplayName("${_firstNameController.text} ${_lastNameController.text}");

      // Save additional user data to Firestore
      await FirebaseFirestore.instance.collection("users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': userCredential.user!.email,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'createdAt': DateTime.now(),
        'status': 1,
        'totalSpending' : 0,
      });


      setState(() {
        _isLoading = false;
      });
      infoSnackbar(context, "Verify your email to complete");
    


    }catch (e) {
        setState(() {_isLoading = false;});

        // dialogue box to show sign up error
        errorSnackbar(context, "Email is already used !");

    }
  }
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),

      child: Scaffold(
        resizeToAvoidBottomInset: true,

        backgroundColor: Color(0xFF4C7766),
        body: Stack(
          children: [

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
            ),

            Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(5),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      // Sign up header
                      _buildSignUpHeader(),
                      
                      // first name field
                      _buildTextField(
                        controller: _firstNameController,
                        label: 'First name',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),

                      // last name field
                      _buildTextField(
                        controller: _lastNameController,
                        label: 'Last name',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),

                      // Email field
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
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
                      
                      // password field
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      
                      // confirm password field
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm password',
                        icon: Icons.lock,
                        obscureText: true,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      
                      // register button
                      _buildRegisterButton(),
                      
                      // already signed in prompt
                      _buildSignInPrompt(context),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }


// Sign up header
  Widget _buildSignUpHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28,15,15,20),
      child: Row(
        children: [
          Text(
            'Sign up',
            style: GoogleFonts.montserrat(
              color:Theme.of(context).primaryColor,
              fontSize: 35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 15),
          Icon(
            Icons.person_add,
            color: Theme.of(context).primaryColor,
            size: 35,
          ),
        ],
      ),
    );
  }

 // Input decorations
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Color.fromARGB(255, 134, 168, 163),
      contentPadding: const EdgeInsets.all(15),
      prefixIcon: Icon(
        icon,
        size: 20,
        color:Colors.white.withOpacity(0.7),
      ),
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      labelStyle: GoogleFonts.montserrat(
        color:Colors.white.withOpacity(0.7),
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(color:Color.fromARGB(255, 134, 168, 163) , width: 0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 209, 211, 216),
          width: 1,
        ),
      ),
    );
  }

  // Text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15,10,15,10),
      
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 32, 32, 32).withOpacity(0.18),
                  spreadRadius: 5,
                  blurRadius: 12,
                  offset: Offset(0, 8), // changes position of shadow
                ),
              ],
        ),
        child: TextFormField(
          controller: controller,
          cursorColor: Colors.white.withOpacity(0.7),
          
          obscureText: obscureText,
          style: GoogleFonts.montserrat(
            color:Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
            fontSize: 20,
          ),
          decoration: _inputDecoration(label, icon),
          validator: validator,
        ),
      ),
    );
  }

  // Register button
  Widget _buildRegisterButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15,20,15,10),
      child: InkWell(
        onTap: _register,
        child: Container(
          padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
          decoration: BoxDecoration(
            boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 32, 32, 32).withOpacity(0.18),
                  spreadRadius: 8,
                  blurRadius: 15,
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
                  'Register',
                  style: GoogleFonts.montserrat(
                    color:Color(0xFF4C7766),
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInPrompt(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 70.0, top: 30),
      child: Row(
        children: [
          Text(
            "Already have an account?",
            style: GoogleFonts.montserrat(
              color:Colors.white.withOpacity(0.5),
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 5),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/LoginScreen');
            },
            child: Text(
              "Sign in",
              style: GoogleFonts.montserrat(
                color: Color.fromARGB(255, 134, 170, 236),
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
