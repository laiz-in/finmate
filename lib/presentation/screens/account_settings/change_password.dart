import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:moneyy/common/widgets/success_snackbar.dart';
import 'package:moneyy/domain/usecases/auth/password_reset.dart';
import 'package:moneyy/presentation/routes/routes.dart';
import 'package:moneyy/service_locator.dart';

import '../../../common/widgets/error_snackbar.dart'; // TO GET THE USE CASE INSTANCE

class ResetPasswordForSettings extends StatefulWidget {
  const ResetPasswordForSettings({super.key});

  @override
  State<ResetPasswordForSettings> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPasswordForSettings> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // RESET PASSWORD LOGIC
  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // SHOW LOADING ANIMATION
      });
      // CALL THE USE CASE
      final resetPasswordUseCase = sl<ResetPasswordUseCase>();

      final result = await resetPasswordUseCase.call(email: _emailController.text.trim());

      result.fold(
        (failure) {
          setState(() {
            isLoading = false; // HIDE ANIMATION ON ERROR
          });
          errorSnackbar(context, "Sorry, internet required for this action");
        },
        (success) {
          setState(() {
            isLoading = false; // HIDE ANIMATION ON SUCCESS
          });
          // SHOW SUCCESS SNACKBAR AND NAVIGATE TO LOGIN
          successSnackbar(context, 'Password reset email has been sent');
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.logIn, (route) => false);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      // BODY
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // DISMISSES THE KEYBOARD WHEN TAPPING OUTSIDE THE TEXT FIELD
        },
        child: Stack(
          children: [
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
                      SizedBox(height: 15.h), // SPACING

                      Center(
                        child: Container(
                          height: 3.h,
                          width: 100.w,
                          decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor.withOpacity(0.3),
                          ),
                        ),
                      ),

                      SizedBox(height: 40.h), // SPACING

                      // PASSWORD RESET HEADING
                      _passwordResetHeading(context),

                      SizedBox(height: 15.h), // SPACING

                      // EMAIL ADDRESS FIELD
                      _emailField(context, _emailController),

                      SizedBox(height: 20.h), // SPACING

                      // SEND BUTTON
                      InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: _resetPassword,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h), // PADDING
                          child: Container(
                            height: 63.h, // HEIGHT
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorDark,
                              borderRadius: BorderRadius.circular(15.0.r), // RADIUS
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Verify',
                                    style: GoogleFonts.poppins(
                                      color: Theme.of(context).hintColor,
                                      fontSize: 25.sp, // FONT SIZE
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 10.w), // SPACING
                                  if (isLoading)
                                    SizedBox(
                                      height: 20.h, // HEIGHT
                                      width: 20.w, // WIDTH
                                      child: CircularProgressIndicator(
                                        color: Theme.of(context).hintColor,
                                        strokeWidth: 3.w, // STROKE WIDTH
                                      ),
                                    ),
                                ],
                              ),
                            ),
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

// HELPER METHOD FOR PASSWORD RESET HEADING
Widget _passwordResetHeading(BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 10.h), // PADDING
    child: Row(
      children: [
        Text(
          'Reset password',
          style: GoogleFonts.poppins(
            color: Theme.of(context).canvasColor,
            fontSize: 25.sp, // FONT SIZE
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 10.w), // SPACING
        Icon(
          Icons.lock_open,
          color: Theme.of(context).canvasColor,
          size: 35.sp, // ICON SIZE
        ),
      ],
    ),
  );
}

// HELPER METHOD FOR EMAIL FIELD
Widget _emailField(BuildContext context, TextEditingController emailController) {
  return Padding(
    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0), // PADDING
    child: TextFormField(
      controller: emailController,
      cursorColor: Theme.of(context).canvasColor,
      style: GoogleFonts.poppins(
        color: Theme.of(context).canvasColor,
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.none,
        fontSize: 16.sp, // FONT SIZE
      ),
      decoration: InputDecoration(
        fillColor: Theme.of(context).cardColor,
        filled: true,
        contentPadding: EdgeInsets.all(16.w), // PADDING
        prefixIcon: Icon(
          Symbols.email,
          color: Theme.of(context).canvasColor.withOpacity(0.7),
          size: 22.sp, // ICON SIZE
        ),
        label: Text(
          'Enter your email',
          style: GoogleFonts.poppins(
            fontSize: 15.sp, // FONT SIZE
            fontWeight: FontWeight.w400,
            color: Theme.of(context).canvasColor.withOpacity(0.7),
          ),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0.r), // RADIUS
          borderSide: BorderSide(
            color: Theme.of(context).scaffoldBackgroundColor,
            width: 0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0.r), // RADIUS
          borderSide: BorderSide(
            color: Colors.transparent,
            width: 0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0.r), // RADIUS
          borderSide: BorderSide(
            color: Theme.of(context).scaffoldBackgroundColor,
            width: 0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0.r), // RADIUS
          borderSide: BorderSide(
            color: Colors.red.shade200,
            width: 1.w, // BORDER WIDTH
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0.r), // RADIUS
          borderSide: BorderSide(
            color: Colors.red.shade200,
            width: 1.w, // BORDER WIDTH
          ),
        ),
        errorStyle: GoogleFonts.poppins(
          color: Colors.red.shade200,
          fontSize: 12.sp, // FONT SIZE
          fontWeight: FontWeight.w400,
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
  );
}