import 'package:flutter/material.dart';

import './auth/auth_guard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});  // Using super parameters

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
        MaterialPageRoute(builder: (context) => AuthGuard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: Center(
        child: Image.asset(
          'assets/images/logo_bg_removed.png',
          width: 70,
          height: 70,
        ),
      ),
    );
  }
}
