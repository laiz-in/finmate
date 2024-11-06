import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void successSnackbar(BuildContext context, String message, {Duration duration = const Duration(seconds: 2)}) {
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

  const ModernSnackBarContent({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        
        color: Color.fromARGB(255, 237, 248, 237),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 109, 109, 109).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline,size: 50,color:Color.fromARGB(255, 88, 138, 89) ,),
        
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'YAY!',
                  style: GoogleFonts.poppins(
                      color: Color.fromARGB(255, 66, 112, 68),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 33, 61, 34),
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