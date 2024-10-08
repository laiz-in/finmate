import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class basicButton extends StatelessWidget {

  final VoidCallback onPressed;
  final String buttonTitle;
  const basicButton({
    required this.onPressed,
    required this.buttonTitle,
    super.key});


  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed,
    child: Text(buttonTitle,style: GoogleFonts.montserrat(fontSize: 25),)
    
    );
  }
}