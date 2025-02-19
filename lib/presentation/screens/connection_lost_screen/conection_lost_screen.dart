// FILEPATH: /C:/Users/Hp/Desktop/moneyy - Copy/moneyy/lib/presentation/screens/connection_lost_screen/conection_lost_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // MAKE SURE YOU HAVE THIS IMPORT
import 'package:flutter_screenutil/flutter_screenutil.dart'; // IMPORT SCREENUTIL
import 'package:moneyy/bloc/authentication/auth_bloc.dart'; // IMPORT THE AUTHBLOC
import 'package:moneyy/bloc/authentication/auth_event.dart';
import 'package:moneyy/bloc/authentication/auth_guard.dart';
import 'package:moneyy/core/colors/colors.dart';

class NoInternetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // INITIALIZE SCREENUTIL
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true, splitScreenMode: true);

    return Scaffold(
      backgroundColor: AppColors.foregroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 80.sp, // USE SCREENUTIL FOR SIZE
              color: Color.fromARGB(255, 194, 163, 161),
            ),
            SizedBox(height: 20.h), // USE SCREENUTIL FOR HEIGHT
            Text(
              'You are offline',
              style: TextStyle(
                fontSize: 17.sp, // USE SCREENUTIL FOR FONT SIZE
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(255, 221, 220, 220),
              ),
            ),
            SizedBox(height: 5.h), // USE SCREENUTIL FOR HEIGHT
            SizedBox(
              width:210.w,
              child: Text(
                'No cached data available! , please log in once when you have internet',
                style: TextStyle(
                  
                  fontSize: 11.sp, // USE SCREENUTIL FOR FONT SIZE
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 221, 220, 220).withOpacity(0.5),
                ),
              ),
            ),
            SizedBox(height: 20.h), // USE SCREENUTIL FOR HEIGHT
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                elevation: WidgetStateProperty.all(0), // NO SHADOW
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 7.h), // USE SCREENUTIL FOR PADDING
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r), // USE SCREENUTIL FOR BORDER RADIUS
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
                style: TextStyle(
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