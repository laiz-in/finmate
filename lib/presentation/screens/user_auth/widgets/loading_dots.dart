import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingDots extends StatefulWidget {
  @override
  _LoadingDotsState createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(0),
        SizedBox(width: 5), // Spacing between dots
        _buildDot(1),
        SizedBox(width: 5), // Spacing between dots
        _buildDot(2),
      ],
    );
  }

  Widget _buildDot(int index) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(0.3 * index, 1.0, curve: Curves.easeIn),
        ),
      ),
      child: Text(
        
        '.',
        style: GoogleFonts.poppins(
          color: Color(0xFF4C7766),
          fontSize: 45,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}