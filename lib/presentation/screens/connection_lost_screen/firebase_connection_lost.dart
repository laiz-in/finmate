// FILEPATH: /C:/Users/Hp/Desktop/moneyy - Copy/moneyy/lib/presentation/screens/connection_lost_screen/firebase_connection_lost.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // MAKE SURE YOU HAVE THIS IMPORT
import 'package:flutter_screenutil/flutter_screenutil.dart'; // IMPORT SCREENUTIL
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:moneyy/bloc/authentication/auth_bloc.dart'; // IMPORT THE AUTHBLOC
import 'package:moneyy/bloc/authentication/auth_event.dart';
import 'package:moneyy/bloc/authentication/auth_guard.dart';
import 'package:moneyy/core/colors/colors.dart';

class NoFirebaseScreen extends StatelessWidget {
  const NoFirebaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.foregroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.cloud_alert,
              size: 80.sp, // USE SCREENUTIL FOR SIZE
              color: Color.fromARGB(255, 194, 163, 161),
            ),
            SizedBox(height: 20.h), // USE SCREENUTIL FOR HEIGHT
            Text(
              'Failed to connect to firebase',
              style: GoogleFonts.poppins(
                fontSize: 17.sp, // USE SCREENUTIL FOR FONT SIZE
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(255, 221, 220, 220),
              ),
            ),
            SizedBox(height: 20.h), // USE SCREENUTIL FOR HEIGHT
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                elevation: WidgetStateProperty.all(0), // NO SHADOW
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h), // USE SCREENUTIL FOR PADDING
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r), // USE SCREENUTIL FOR BORDER RADIUS
                    side: BorderSide(color: Color.fromARGB(255, 194, 196, 197)),
                  ),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider<AuthBloc>(
                      create: (context) => AuthBloc()..add(AuthCheckRequested()), // INITIALIZE YOUR AUTHBLOC HERE
                      child: const AuthGuard(), // WRAP THE AUTHGUARD WITH BLOCPROVIDER
                    ),
                  ),
                );
              },
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp, // USE SCREENUTIL FOR FONT SIZE
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 194, 196, 197),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}