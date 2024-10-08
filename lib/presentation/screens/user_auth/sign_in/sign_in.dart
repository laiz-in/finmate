import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/core/colors/colors.dart';
import 'package:moneyy/presentation/routes/routes.dart';
import 'package:moneyy/presentation/screens/user_auth/widgets/login_button.dart';

import '../widgets/email_field.dart';
import '../widgets/password_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isloading =  true;



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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 100),
              
                  // Login headig
                  _loginHeading(context),
              
                  SizedBox(height: 15),
              
                  // Email field
                  EmailField(emailController: _emailController),
              
                  // Password field
                  PasswordField(passwordController: _passwordController),
              
                  
                  // forgot password link
                  _forgotPasswordLink(context),
              
                  // Login button
                  LoginButtonWidget(emailController: _emailController, passwordController: _passwordController,formKey: _formKey,),
                  
                  // dont have an account section
                  _redirectToSignUpLink(context)
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


Widget _loginHeading(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      const SizedBox(width: 17),
      Text(
        'Login',
        style: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.8),
          fontSize: 30,
          fontWeight: FontWeight.w600,
        ),
      ),
      Text(
        ' to finmate',
        style: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.4),
          fontSize: 30,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(width: 10), // Add some space between the text and icon
      Icon(
        Icons.arrow_forward,
        color: Colors.white.withOpacity(0.4),
        size: 40,
      ),
    ],
  );
}

Widget _forgotPasswordLink(BuildContext context){
  return Padding(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                                      Navigator.pushNamed(context, AppRoutes.passwordResetScreen);
                                      },
                        child: Text(
                          "Forgot Password?",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.4),
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
}

Widget _redirectToSignUpLink(BuildContext context){
    return Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: GoogleFonts.poppins(
                          color:AppColors.foregroundColorFaded2.withOpacity(0.5),
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 5), // Add space between texts
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.signUp);
                        },
                        child: Text(
                          "Sign up",
                          style: GoogleFonts.poppins(
                            color: Color.fromARGB(255, 185, 221, 193),
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      )
                    ],
                  ),
                );
}

