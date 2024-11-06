import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Make sure you have this import
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/bloc/authentication/auth_bloc.dart'; // Import the AuthBloc
import 'package:moneyy/bloc/authentication/auth_event.dart';
import 'package:moneyy/bloc/authentication/auth_guard.dart';
import 'package:moneyy/core/colors/colors.dart';

class NoInternetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.foregroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 80,
              color: Color.fromARGB(255, 194, 163, 161),
            ),
            SizedBox(height: 20),
            Text(
              'No Internet Connection',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(255, 221, 220, 220),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                elevation: WidgetStateProperty.all(0), // No shadow
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: Color.fromARGB(255, 194, 196, 197)),
                  ),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider<AuthBloc>(
                      create: (context) => AuthBloc()..add(AuthCheckRequested()), // Initialize your AuthBloc here
                      child: const AuthGuard(), // Wrap the AuthGuard with BlocProvider
                    ),
                  ),
                );
              },
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  fontSize: 15,
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
