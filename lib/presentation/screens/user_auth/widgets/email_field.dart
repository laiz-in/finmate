import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/core/colors/colors.dart';

class EmailField extends StatelessWidget {
  final TextEditingController emailController;

  const EmailField({super.key, required this.emailController});

  // EMAIL VALIDATION METHOD
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }
    // REGULAR EXPRESSION FOR EMAIL VALIDATION
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 20.h, 10.w, 5.h), // PADDING
      child: TextFormField(
        controller: emailController,
        cursorColor: Colors.white.withOpacity(0.7),
        style: GoogleFonts.poppins(
          color: AppColors.foregroundColorDark,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.none,
          fontSize: 16.sp, // FONT SIZE
        ),
        decoration: InputDecoration(
          filled: true,
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red.shade200,
              width: 1.w,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.r),
              topRight: Radius.circular(15.r),
            ),
          ),
          errorStyle: GoogleFonts.poppins(
            color: Colors.red.shade200,
            fontSize: 12.sp, // FONT SIZE
            fontWeight: FontWeight.w400,
          ),
          fillColor: const Color.fromARGB(255, 134, 168, 163),
          contentPadding: EdgeInsets.all(18.w), // PADDING
          prefixIcon: Icon(
            Icons.email,
            size: 22.sp, // ICON SIZE
            color: Colors.white.withOpacity(0.5),
          ),
          labelText: 'Email',
          labelStyle: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.5),
            fontSize: 16.sp, // FONT SIZE
            fontWeight: FontWeight.w400,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 134, 168, 163),
              width: 0,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.r), // RADIUS
              topRight: Radius.circular(15.r), // RADIUS
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 134, 168, 163),
              width: 0,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.r), // RADIUS
              topRight: Radius.circular(15.r), // RADIUS
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.5),
              width: 1.w, // BORDER WIDTH
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.r), // RADIUS
              topRight: Radius.circular(15.r), // RADIUS
            ),
          ),
        ),
        validator: _validateEmail,
      ),
    );
  }
}