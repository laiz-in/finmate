import 'package:flutter/material.dart';
import 'package:moneyy/bloc/authentication/auth_guard.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});  // Using super parameters

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  // Function to navigate to home after delay
  Future<void> _navigateToHome() async {
    print("GOING TO AUTH GUARD FROM SPLASH.DART");

    await Future.delayed(const Duration(seconds: 3));
    print("going to check if the mountes is true or false");
    if (mounted) {
      print("mounted is true , so navigating AUTH GUARD");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthGuard()),
      );
    }
    else{
      print("mounted is false");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4C7766),
      body: Center(
        child:Image.asset(
          'assets/images/splash.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
