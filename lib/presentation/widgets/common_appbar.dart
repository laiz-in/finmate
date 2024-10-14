import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBarCommon extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  
  const CustomAppBarCommon({
    super.key,
    required this.title,
  }) : preferredSize = const Size.fromHeight(70.0);

  @override
  final Size preferredSize; // This controls the height of the AppBar.

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      toolbarHeight: 90,
      iconTheme: IconThemeData(
        color: Theme.of(context).canvasColor,
        size: 30,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Container(
        alignment: Alignment.bottomLeft, // Align title to the bottom-left
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).canvasColor,
          ),
        ),
      ),
    );
  }
}
