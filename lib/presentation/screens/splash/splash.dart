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
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthGuard()),
      );
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
