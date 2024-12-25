import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/common/widgets/success_snackbar.dart';
import 'package:moneyy/domain/usecases/auth/password_reset.dart';
import 'package:moneyy/presentation/routes/routes.dart';
import 'package:moneyy/presentation/screens/user_auth/widgets/email_field.dart';
import 'package:moneyy/service_locator.dart'; // TO GET THE USE CASE INSTANCE
import 'package:moneyy/ui/error_snackbar.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
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
          errorSnackbar(context, "Unable to send reset password email.");
        },
        (success) {
          setState(() {
            isLoading = false; // HIDE ANIMATION ON SUCCESS
          });
          // SHOW SUCCESS SNACKBAR AND NAVIGATE TO LOGIN
          successSnackbar(context, 'Password reset email has been sent');
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.logIn, (route) => false);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4C7766),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4C7766),
        iconTheme: IconThemeData(color: Colors.white.withOpacity(0.7)),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // DISMISSES THE KEYBOARD WHEN TAPPING OUTSIDE THE TEXT FIELD
        },
        child: Stack(
          children: [
            // BACKGROUND CONTAINER
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF4C7766),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 40.h), // SPACING

                      // PASSWORD RESET HEADING
                      _passwordResetHeading(context),

                      SizedBox(height: 15.h), // SPACING

                      // EMAIL ADDRESS FIELD
                      _emailField(context, _emailController),

                      // SEND BUTTON
                      InkWell(
                        focusColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: _resetPassword,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(25.w, 5.h, 25.w, 20.h), // PADDING
                          child: Container(
                            height: 63.h, // HEIGHT
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15.r),
                                bottomRight: Radius.circular(15.r),
                              ),
                            ),
                            child: Center(
                              child: isLoading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        color: Theme.of(context).canvasColor,
                                        strokeWidth: 3.w, // STROKE WIDTH
                                      ),
                                    ) // SHOW LOADING ANIMATION
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Verify',
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF4C7766),
                                            fontSize: 25.sp, // FONT SIZE
                                            fontWeight: FontWeight.w600,
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
            color: Colors.white.withOpacity(0.7),
            fontSize: 25.sp, // FONT SIZE
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 10.w), // SPACING
        Icon(
          Icons.lock_open,
          color: Colors.white.withOpacity(0.7),
          size: 35.sp, // ICON SIZE
        ),
      ],
    ),
  );
}

// HELPER METHOD FOR EMAIL FIELD
Widget _emailField(BuildContext context, TextEditingController emailController) {
  return Padding(
    padding: EdgeInsets.fromLTRB(15.w, 20.h, 15.w, 0), // PADDING
    child: EmailField(emailController: emailController),
  );
}