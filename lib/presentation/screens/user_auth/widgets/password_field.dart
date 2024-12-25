import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/core/colors/colors.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController passwordController;

  const PasswordField({super.key, required this.passwordController});

  // PASSWORD VALIDATION METHOD
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 1.h, 10.w, 10.h), // PADDING
      child: TextFormField(
        cursorColor: Colors.white.withOpacity(0.7),
        controller: passwordController,
        obscureText: true,
        style: GoogleFonts.poppins(
          color: AppColors.foregroundColorDark,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.none,
          fontSize: 16.sp, // FONT SIZE
        ),
        decoration: InputDecoration(
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red.shade200,
              width: 1.w,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15.r), // RADIUS
              bottomRight: Radius.circular(15.r), // RADIUS
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red.shade200,
              width: 1.w,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15.r), // RADIUS
              bottomRight: Radius.circular(15.r), // RADIUS
            ),
          ),
          errorStyle: GoogleFonts.poppins(
            color: Colors.red.shade200,
            fontSize: 12.sp, // FONT SIZE
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: const Color.fromARGB(255, 134, 168, 163),
          contentPadding: EdgeInsets.all(18.w), // PADDING
          prefixIcon: Icon(
            Icons.lock,
            size: 22.sp, // ICON SIZE
            color: Colors.white.withOpacity(0.5),
          ),
          labelText: 'Password',
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
              bottomLeft: Radius.circular(15.r), // RADIUS
              bottomRight: Radius.circular(15.r), // RADIUS
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 134, 168, 163),
              width: 0,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15.r), // RADIUS
              bottomRight: Radius.circular(15.r), // RADIUS
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.5),
              width: 1.w, // BORDER WIDTH
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15.r), // RADIUS
              bottomRight: Radius.circular(15.r), // RADIUS
            ),
          ),
        ),
        validator: _validatePassword,
      ),
    );
  }
}