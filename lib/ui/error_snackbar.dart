import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

void errorSnackbar(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
  final snackBar = SnackBar(
    content: ModernSnackBarContent(message: message),
    backgroundColor: Colors.transparent,
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    duration: duration,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class ModernSnackBarContent extends StatelessWidget {
  final String message;

  const ModernSnackBarContent({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 243, 222, 222),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 48, 48, 48).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Lottie.asset(
          'assets/animations/error.json',
          width: 40,
          height: 40,
          fit: BoxFit.fill,
        ),
        const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'OOPS!',
                  style: GoogleFonts.montserrat(
                      color: Color.fromARGB(255, 83, 53, 51),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.montserrat(
                    textStyle: const TextStyle(
                      color: Color.fromARGB(255, 85, 43, 43),
                      fontSize: 14,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}