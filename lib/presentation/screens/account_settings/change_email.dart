import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/domain/usecases/auth/email_reset.dart';
import 'package:moneyy/presentation/routes/routes.dart';
import 'package:moneyy/service_locator.dart';

class ResetEmail extends StatefulWidget {
  const ResetEmail({super.key});

  @override
  State<ResetEmail> createState() => _ResetEmailState();
}

class _ResetEmailState extends State<ResetEmail> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  // RESET EMAIL LOGIC
  void _resetEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final resetPasswordUseCase = sl<ResetEmailUseCase>();
      final result = await resetPasswordUseCase.call(email: emailController.text.trim());

      result.fold(
        (l) {
          if (mounted) {
            errorSnackbar(context, l.toString());
          }
          setState(() {
            _isLoading = false;
          });
        },
        (r) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.logIn, (route) => false);
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
            // ALIGN FOR THE EMAIL AND BUTTON TEXT FIELDS
            Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
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

                      // EMAIL RESET HEADING
                      Padding(
                        padding: EdgeInsets.all(20.w), // PADDING
                        child: Row(
                          children: [
                            Text(
                              ' Reset Email',
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).canvasColor,
                                fontSize: 25.sp, // FONT SIZE
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 10.w), // SPACING
                            Icon(
                              Symbols.email,
                              color: Theme.of(context).canvasColor,
                              size: 35.sp, // ICON SIZE
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 15.h), // SPACING

                      // EMAIL ADDRESS FIELD
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0), // PADDING
                        child: TextFormField(
                          controller: emailController,
                          cursorColor: Theme.of(context).canvasColor.withOpacity(0.7),
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
                              'Enter your new email',
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp, // FONT SIZE
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).canvasColor.withOpacity(0.7),
                              ),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0.r), // RADIUS
                              borderSide: BorderSide(color: Theme.of(context).scaffoldBackgroundColor, width: 0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0.r), // RADIUS
                              borderSide: BorderSide(color: Theme.of(context).scaffoldBackgroundColor, width: 0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0.r), // RADIUS
                              borderSide: BorderSide(color: Theme.of(context).scaffoldBackgroundColor, width: 0),
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
                      ),

                      SizedBox(height: 15.h), // SPACING

                      // SEND BUTTON
                      InkWell(
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: _resetEmail,
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
                                    'Submit',
                                    style: GoogleFonts.poppins(
                                      color: Theme.of(context).hintColor,
                                      fontSize: 25.sp, // FONT SIZE
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 10.w), // SPACING
                                  if (_isLoading)
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

                      // INSTRUCTIONS
                      Padding(
                        padding: EdgeInsets.all(20.w), // PADDING
                        child: Text(
                          softWrap: true,
                          'Note: By clicking submit, you will be redirected to the login page. Please verify your new email before logging in.',
                          style: GoogleFonts.poppins(
                            color: Theme.of(context).canvasColor.withOpacity(0.7),
                            fontSize: 12.sp, // FONT SIZE
                            fontWeight: FontWeight.w400,
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