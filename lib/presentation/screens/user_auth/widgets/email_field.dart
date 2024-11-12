import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/core/colors/colors.dart';

class EmailField extends StatelessWidget {
  final TextEditingController emailController;

  const EmailField({super.key, required this.emailController});

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }
    // Regular expression for email validation
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 20, 10.0, 5.0),
      child: TextFormField(
        controller: emailController,
        cursorColor: Colors.white.withOpacity(0.7),
        style: GoogleFonts.poppins(
          color: AppColors.foregroundColorDark,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.none,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color.fromARGB(255, 134, 168, 163),
          contentPadding: const EdgeInsets.all(18),
          prefixIcon: Icon(
            Icons.email,
            size: 22,
            color: Colors.white.withOpacity(0.5),
          ),
          labelText: 'Email',
          labelStyle: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.5),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 134, 168, 163),
              width: 0,
            ),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 134, 168, 163),
              width: 0,
            ),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.5),
              width: 1,
            ),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
          ),
        ),
        validator: _validateEmail,
      ),
    );
  }
}
