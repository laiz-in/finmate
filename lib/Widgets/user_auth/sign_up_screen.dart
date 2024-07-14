
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../styles/themes.dart';
import '../../ui/dialogue_box.dart';


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


      // 2. Create subcollections for financial data (store references, not actual data)
      await FirebaseFirestore.instance.collection('spendings').doc().set({});
      await FirebaseFirestore.instance.collection('lent_money').doc().set({});
      await FirebaseFirestore.instance.collection('reminders').doc().set({});
      await FirebaseFirestore.instance.collection('money_owes').doc().set({});
      await FirebaseFirestore.instance.collection('upcoming_bills').doc().set({});


      setState(() {
        _isLoading = false;
      });
      showCustomSnackBarInfo(context, "Verify your email to complete");
    


    }catch (e) {
        setState(() {_isLoading = false;});

        // dialogue box to show sign up error
        showCustomSnackBarError(context, "Email is already used !");

    }
  }
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),

      child: Scaffold(
        resizeToAvoidBottomInset: true,


        body: Stack(
          children: [

            Container(
              decoration: BoxDecoration(
                color:Colors.black,
              ),
            ),

            Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildSignUpHeader(),
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
                      _buildRegisterButton(),
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
              color:AppColors.myFadeblue,
              fontSize: 45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.person_add,
            color: AppColors.myOrange,
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
      fillColor: AppColors.myfaded,
      contentPadding: const EdgeInsets.all(15),
      prefixIcon: Icon(
        icon,
        color:AppColors.myFadeblue,
      ),
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      labelStyle: GoogleFonts.montserrat(
        color:AppColors.myFadeblue,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: const BorderSide(
          color: AppColors.myFadeblue,
          width: 2,
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
      padding: const EdgeInsets.fromLTRB(20.0, 12, 20, 0),
      
      child: TextFormField(
        controller: controller,
        cursorColor: AppColors.myFadeblue,
        
        obscureText: obscureText,
        style: GoogleFonts.montserrat(
          color:AppColors.myFadeblue,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.none,
          fontSize: 20,
        ),
        decoration: _inputDecoration(label, icon),
        validator: validator,
      ),
    );
  }

  // Register button
  Widget _buildRegisterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: InkWell(
        onTap: _register,
        child: Container(
          height: 60,
          width: 347,
          decoration: BoxDecoration(
          
            color:AppColors.myFadeblue,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Register',
                  style: GoogleFonts.montserrat(
                    color:AppColors.myDark,
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
              color:AppColors.myFadeblue,
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
                color: Color.fromARGB(255, 55, 113, 223),
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
