import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void infoSnackbar(BuildContext context, String message, {Duration duration = const Duration(seconds: 5)}) {
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.info,color: Color.fromARGB(255, 37, 61, 97),size: 50,),

          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'perfect',
                  style: GoogleFonts.poppins(
                      color: Color.fromARGB(255, 37, 61, 97),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 47, 101, 146),
                      fontSize: 14,
                      
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