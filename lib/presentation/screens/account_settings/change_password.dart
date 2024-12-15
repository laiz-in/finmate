import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:moneyy/common/widgets/success_snackbar.dart';
import 'package:moneyy/domain/usecases/auth/password_reset.dart';
import 'package:moneyy/presentation/routes/routes.dart';
import 'package:moneyy/service_locator.dart'; // To get the use case instance
import 'package:moneyy/styles/themes.dart';
import 'package:moneyy/ui/error_snackbar.dart';

class ResetPasswordForSettings extends StatefulWidget {
  const ResetPasswordForSettings({super.key});

  @override
  State<ResetPasswordForSettings> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPasswordForSettings> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isloading = false;

  // Reset password logic
  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isloading = true;
      });
      // Call the use case
      final resetPasswordUseCase = sl<ResetPasswordUseCase>();

      final result = await resetPasswordUseCase.call(email: _emailController.text.trim());

      result.fold(
        (failure) {
          setState(() {
        isloading = false;
      });
          errorSnackbar(context, "Unable to send reset password email.");
        },
        (success) {
          setState(() {
        isloading = false;
      });
          // Show success Snackbar and navigate to login
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color:Theme.of(context).canvasColor),
      ),


      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Dismisses the keyboard when tapping outside the text field
        },
        child: Stack(
          children: [
            // Background container
            Container(
              decoration:BoxDecoration(
                color:Theme.of(context).scaffoldBackgroundColor,
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

                      const SizedBox(height: 20),

                      // Send button
                      InkWell(
                        onTap: _resetPassword,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 10, 20, 20),
                          child: Container(
                            height: 63,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color:Theme.of(context).primaryColorDark,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Verify',
                                    style: GoogleFonts.poppins(
                                      color: Theme.of(context).hintColor,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                SizedBox(width: 10),
                                if (isloading)
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Theme.of(context).hintColor,
                                          strokeWidth: 3,
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
                                color: Theme.of(context).canvasColor,
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.lock_open,
                              color: Theme.of(context).canvasColor,
                              size: 35,
                            ),
                          ],
                        ),
                      );
}

Widget _emailField(BuildContext context, emailController){
  return Padding(
                        padding:EdgeInsets.fromLTRB(20.0, 20, 20, 0),
                        child: TextFormField(
                          controller: emailController,
                          cursorColor: Theme.of(context).canvasColor,
                          style: GoogleFonts.poppins(
                            color: Theme.of(context).canvasColor,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                            fontSize: 20,
                          ),
                          decoration: InputDecoration(
                            fillColor:
                                Theme.of(context).highlightColor,
                            filled: true,
                            contentPadding: const EdgeInsets.all(16),
                            prefixIcon: Icon(
                              Symbols
                              .email,
                              color: Theme.of(context).canvasColor.withOpacity(0.7)
                            ),
                            label: Text(
                              'Enter your email',
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).canvasColor.withOpacity(0.7)
                                  ),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelStyle: GoogleFonts.montserrat(
                              color: AppColors.myFadeblue,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                width: 0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                width: 0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                width: 0,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                      );
}


