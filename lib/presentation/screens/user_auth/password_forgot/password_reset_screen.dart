import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/common/widgets/success_snackbar.dart';
import 'package:moneyy/domain/usecases/auth/password_reset.dart';
import 'package:moneyy/presentation/routes/routes.dart';
import 'package:moneyy/presentation/screens/user_auth/widgets/email_field.dart';
import 'package:moneyy/service_locator.dart'; // To get the use case instance
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

  // Reset password logic
  // Reset password logic
  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {

      setState(() {
              isLoading = true; // Show loading animation
            });
      // Call the use case
      final resetPasswordUseCase = sl<ResetPasswordUseCase>();

      final result = await resetPasswordUseCase.call(email: _emailController.text.trim());

      result.fold(
        (failure) {
          setState(() {
                  isLoading = false; // Hide animation on error
                });
          errorSnackbar(context, "Unable to send reset password email.");
        },
        (success) {
          setState(() {
                  isLoading = false; // Hide animation on error
                });
          // Show success Snackbar and navigate to login
          successSnackbar(context, 'Password reset email has been sent');
          isLoading = true;
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.logIn, (route) => false);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xFF4C7766),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4C7766),
        iconTheme: IconThemeData(color: Colors.white.withOpacity(0.7)),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Dismisses the keyboard when tapping outside the text field
        },
        child: Stack(
          children: [
            // Background container
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF4C7766),
              ),
            ),
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
                      const SizedBox(height: 40),


                      // Password reset heading
                      _passwordResetHeading(context),

                      const SizedBox(height: 15),

                      // Email address field
                      _emailField(context,_emailController),



                      // Send button
                      InkWell(
                        onTap: _resetPassword,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(25.0, 5, 25, 20),
                          child: Container(
                            height: 63,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15),bottomRight: Radius.circular(15)),
                            ),
                            child: Center(
                              child:  isLoading
                ? Center(child: CircularProgressIndicator(
                  color: Theme.of(context).canvasColor,strokeWidth: 3,
                )) // Show loading animation
                : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Verify',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF4C7766),
                                      fontSize: 25,
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

Widget _passwordResetHeading(BuildContext context){
  return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 10),
                        child: Row(
                          children: [
                            Text(
                              'Reset password',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.lock_open,
                              color: Colors.white.withOpacity(0.7),
                              size: 35,
                            ),
                          ],
                        ),
                      );
}

Widget _emailField(BuildContext context, emailController){
  return Padding(
                        padding: const EdgeInsets.fromLTRB(15.0, 20, 15, 0),
                        child:EmailField(emailController: emailController),

                      );
}


