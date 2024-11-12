import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/core/colors/colors.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController passwordController;

  const PasswordField({super.key, required this.passwordController});

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 1, 10.0, 10.0),
      child: TextFormField(
        cursorColor: Colors.white.withOpacity(0.7),
        controller: passwordController,
        obscureText: true,
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
            Icons.lock,
            size: 22,
            color: Colors.white.withOpacity(0.5),
          ),
          labelText: 'Password',
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
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15),bottomRight: Radius.circular(15)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 134, 168, 163),
              width: 0,
            ),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15),bottomRight: Radius.circular(15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.5),
              width: 1,
            ),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15),bottomRight: Radius.circular(15)),
          ),
        ),
        validator: _validatePassword,
      ),
    );
  }
}
