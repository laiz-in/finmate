import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/presentation/routes/routes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;

  // Corrected constructor: `userName` is required and passed as a named parameter.
  const CustomAppBar({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 80,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Container(
        padding: const EdgeInsets.fromLTRB(5, 8, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back !',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).canvasColor.withOpacity(0.5),
              ),
            ),
            Text(
              userName,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).canvasColor,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notification_add_outlined,
            color: Theme.of(context).canvasColor,
            size: 25,
          ),
          onPressed: () {
            // Add your notification logic here
          },
        ),
        IconButton(
          icon: Icon(
            Icons.person_outline_outlined,
            color: Theme.of(context).canvasColor,
            size: 25,
          ),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.profileScreen);
          },
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
