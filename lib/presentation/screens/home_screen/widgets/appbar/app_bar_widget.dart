import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;

  // Corrected constructor: `userName` is required and passed as a named parameter.
  const CustomAppBar({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 80.h,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Container(
        padding:  EdgeInsets.fromLTRB(5.w, 8.h, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back !',
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).canvasColor.withOpacity(0.5),
              ),
            ),
            Text(
              userName,
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).canvasColor,
              ),
            ),
          ],
        ),
      ),

      // actions to include the correct icons and navigation
      actions: [
        IconButton(
          icon: Icon(
            Symbols.notifications,
            color: Theme.of(context).canvasColor,
            size: 23.sp,
            weight: 900,
          ),
          onPressed: () {
            // Add your notification logic here
          },
        ),
        
        
        SizedBox(width: 20.w),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(75.h);
}
