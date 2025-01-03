import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/core/colors/colors.dart';
import 'package:moneyy/presentation/routes/routes.dart';
import 'package:moneyy/presentation/screens/user_auth/widgets/register_button.dart';

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

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true, // ALLOW THE LAYOUT TO RESIZE WHEN THE KEYBOARD APPEARS
        backgroundColor: const Color(0xFF4C7766),
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF4C7766),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(5.w), // PADDING
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // SIGN UP HEADER
                        _buildSignUpHeader(),

                        // FIRST NAME FIELD
                        _buildTextField(
                          TL: 15.0,
                          BL: 0.0,
                          BR: 0.0,
                          TR: 15.0,
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

                        // LAST NAME FIELD
                        _buildTextField(
                          TL: 0.0,
                          BL: 0.0,
                          BR: 0.0,
                          TR: 0.0,
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

                        // EMAIL FIELD
                        _buildTextField(
                          TL: 0.0,
                          BL: 0.0,
                          BR: 0.0,
                          TR: 0.0,
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

                        // PASSWORD FIELD
                        _buildTextField(
                          TL: 0.0,
                          BL: 0.0,
                          BR: 0.0,
                          TR: 0.0,
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

                        // CONFIRM PASSWORD FIELD
                        _buildTextField(
                          TL: 0.0,
                          BL: 15.0,
                          BR: 15.0,
                          TR: 0.0,
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

                        // REGISTER BUTTON
                        RegisterButtonWidget(
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                          firstNameController: _firstNameController,
                          lastNameController: _lastNameController,
                        ),

                        // ALREADY SIGNED IN PROMPT
                        _buildSignInPrompt(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HEADER FOR SIGN UP
  Widget _buildSignUpHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 15.w, 20.h), // PADDING
      child: Row(
        children: [
          Text(
            'Sign up',
            style: GoogleFonts.poppins(
              color: AppColors.mywhite.withOpacity(0.8),
              fontSize: 25.sp, // FONT SIZE
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            ' to finmate',
            style: GoogleFonts.poppins(
              color: AppColors.mywhite.withOpacity(0.4),
              fontSize: 25.sp, // FONT SIZE
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 15.w), // SPACING
          Icon(
            Icons.person_add,
            color: AppColors.mywhite.withOpacity(0.4),
            size: 35.sp, // ICON SIZE
          ),
        ],
      ),
    );
  }

  // INPUT FIELD DECORATIONS
  InputDecoration _inputDecoration(String label, IconData icon, double TL, double TR, double BL, double BR) {
    return InputDecoration(
      filled: true,
      fillColor: const Color.fromARGB(255, 134, 168, 163),
      contentPadding: EdgeInsets.all(15.w), // PADDING
      prefixIcon: Icon(
        icon,
        size: 20.sp, // ICON SIZE
        color: Colors.white.withOpacity(0.7),
      ),
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      labelStyle: GoogleFonts.poppins(
        color: Colors.white.withOpacity(0.7),
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(TL.r),
          topRight: Radius.circular(TR.r),
          bottomLeft: Radius.circular(BL.r),
          bottomRight: Radius.circular(BR.r),
        ), // RADIUS
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(TL.r),
          topRight: Radius.circular(TR.r),
          bottomLeft: Radius.circular(BL.r),
          bottomRight: Radius.circular(BR.r),
        ), // RADIUS
        borderSide: const BorderSide(color: Color.fromARGB(255, 134, 168, 163), width: 0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(TL.r),
          topRight: Radius.circular(TR.r),
          bottomLeft: Radius.circular(BL.r),
          bottomRight: Radius.circular(BR.r),
        ), // RADIUS
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 134, 168, 163),
          width: 0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(TL.r),
          topRight: Radius.circular(TR.r),
          bottomLeft: Radius.circular(BL.r),
          bottomRight: Radius.circular(BR.r),
        ), // RADIUS
        borderSide: BorderSide(
          color: Colors.red.shade200,
          width: 1.w, // BORDER WIDTH
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(TL.r),
          topRight: Radius.circular(TR.r),
          bottomLeft: Radius.circular(BL.r),
          bottomRight: Radius.circular(BR.r),
        ), // RADIUS
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
    );
  }

  // INPUT FIELD CONTAINERS
  Widget _buildTextField({
    required double TL,
    required double TR,
    required double BL,
    required double BR,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(15.w, 2.h, 15.w, 5.h), // PADDING
      child: TextFormField(
        controller: controller,
        cursorColor: Colors.white.withOpacity(0.7),
        obscureText: obscureText,
        style: GoogleFonts.poppins(
          color: AppColors.foregroundColorDark,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.none,
          fontSize: 16.sp, // FONT SIZE
        ),
        decoration: _inputDecoration(label, icon, TL, TR, BL, BR),
        validator: validator,
      ),
    );
  }

  // SIGN IN REDIRECT TEXT
  Widget _buildSignInPrompt(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 70.0.w, top: 30.h), // PADDING
      child: Row(
        children: [
          Text(
            "Already have an account?",
            style: GoogleFonts.poppins(
              color: const Color.fromARGB(255, 207, 195, 195).withOpacity(0.5),
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 5.w), // SPACING
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.logIn);
            },
            child: Text(
              "Sign in",
              style: GoogleFonts.poppins(
                color: const Color.fromARGB(255, 185, 221, 193),
                fontWeight: FontWeight.w500,
                fontSize: 15.sp, // FONT SIZE
              ),
            ),
          ),
        ],
      ),
    );
  }
}