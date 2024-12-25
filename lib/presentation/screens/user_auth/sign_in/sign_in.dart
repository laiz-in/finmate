import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Color(0xFF4C7766),
        resizeToAvoidBottomInset: true, // ALLOW THE LAYOUT TO RESIZE WHEN THE KEYBOARD APPEARS
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 10.w), // PADDING
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 100.h), // SPACING

                  // LOGIN HEADING
                  _loginHeading(context),

                  SizedBox(height: 15.h), // SPACING

                  // EMAIL FIELD
                  EmailField(emailController: _emailController),

                  // PASSWORD FIELD
                  PasswordField(passwordController: _passwordController),

                  // FORGOT PASSWORD LINK
                  _forgotPasswordLink(context),

                  // LOGIN BUTTON
                  LoginButtonWidget(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    formKey: _formKey,
                  ),

                  // DON'T HAVE AN ACCOUNT SECTION
                  _redirectToSignUpLink(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// HELPER METHOD FOR LOGIN HEADING
Widget _loginHeading(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      SizedBox(width: 17.w), // SPACING
      Text(
        'Login',
        style: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.8),
          fontSize: 30.sp, // FONT SIZE
          fontWeight: FontWeight.w600,
        ),
      ),
      Text(
        ' to finmate',
        style: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.4),
          fontSize: 30.sp, // FONT SIZE
          fontWeight: FontWeight.w600,
        ),
      ),
      SizedBox(width: 10.w), // SPACING
      Icon(
        Icons.arrow_forward,
        color: Colors.white.withOpacity(0.4),
        size: 40.sp, // ICON SIZE
      ),
    ],
  );
}

// HELPER METHOD FOR FORGOT PASSWORD LINK
Widget _forgotPasswordLink(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(15.w), // PADDING
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.passwordResetScreen);
          },
          child: Text(
            "Forgot Password?",
            style: GoogleFonts.poppins(
              color: AppColors.foregroundColorFaded2.withOpacity(0.5),
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

// HELPER METHOD FOR REDIRECT TO SIGN UP LINK
Widget _redirectToSignUpLink(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(15.w), // PADDING
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "Don't have an account?",
          style: GoogleFonts.poppins(
            fontSize: 13.sp, // FONT SIZE
            color: AppColors.foregroundColorFaded2.withOpacity(0.5),
            letterSpacing: 0.5,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(width: 5.w), // SPACING
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.signUp);
          },
          child: Text(
            "Register now",
            style: GoogleFonts.poppins(
              color: AppColors.foregroundColorFaded2.withOpacity(0.8),
              fontWeight: FontWeight.w500,
              fontSize: 13.sp, // FONT SIZE
            ),
          ),
        ),
      ],
    ),
  );
}