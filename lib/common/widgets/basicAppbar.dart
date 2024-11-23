import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String heading;

  // Corrected constructor: `userName` is required and passed as a named parameter.
  const CommonAppBar({super.key, required this.heading});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
          icon: Transform.rotate(
          angle: 3.14159, // Rotate the icon by 180 degrees (in radians)
          child: const Icon(
            Icons.arrow_forward_ios,
            size: 18, // Smaller icon size for a subtle design
          ),
        ),
        color: Theme.of(context).canvasColor, // Matches the color theme
        onPressed: () {
          Navigator.pop(context); // Navigates back to the previous screen
        },
      ),
      toolbarHeight: 60,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              heading,
              style: GoogleFonts.poppins(
                fontSize: 19,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).canvasColor,
              ),
            ),

          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
