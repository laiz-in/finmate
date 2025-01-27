import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:moneyy/bloc/themes/theme_cubit.dart';
import 'package:moneyy/core/colors/colors.dart';
import 'package:moneyy/presentation/screens/account_settings/change_daily_limit.dart';
import 'package:moneyy/presentation/screens/account_settings/change_email.dart';
import 'package:moneyy/presentation/screens/account_settings/change_monthly_limit.dart';
import 'package:moneyy/presentation/screens/account_settings/change_name.dart';
import 'package:moneyy/presentation/screens/account_settings/change_password.dart';
import 'package:moneyy/presentation/screens/account_settings/photo_and_name.dart';
import 'package:moneyy/presentation/screens/account_settings/send_feedback.dart';
import 'package:moneyy/presentation/screens/account_settings/widgets/account_deletion_confirmation.dart';
import 'package:moneyy/presentation/screens/account_settings/widgets/sign_out_confirmation_dialogue.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  ProfileSettingsState createState() => ProfileSettingsState();
}

class ProfileSettingsState extends State<ProfileSettings> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _monthlyLimitController = TextEditingController();
  final TextEditingController _dailyLimitController = TextEditingController();

  // FUNCTION TO LOG OUT
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const SignOutConfirmationDialog();
      },
    );
  }

  // FUNCTION TO DELETE THE USER ACCOUNT
  void _deleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AccountDeletionConfirmationDialog();
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _monthlyLimitController.dispose();
    _dailyLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // APP BAR
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.h), // ADJUST THIS HEIGHT AS NEEDED
        child: AppBar(
          automaticallyImplyLeading: false, // Disable automatic back button

          scrolledUnderElevation: 0,
          elevation: 0,
          toolbarHeight: 70.h,
          
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Container(
            alignment: Alignment.bottomLeft, // ALIGN TITLE TO THE BOTTOM-LEFT
            child: Text(
              ' Profile settings',
              style: GoogleFonts.poppins(
                fontSize: 22.sp, // FONT SIZE
                fontWeight: FontWeight.w500,
                color: Theme.of(context).canvasColor,
              ),
            ),
          ),
        ),
      ),

      // BODY
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(width: double.infinity, height: 15.h), // SPACING
      
            // PROFILE PHOTO AND NAME
            const ProfilePage(),
      
            SizedBox(width: double.infinity, height: 18.h), // SPACING
      
            Container(
              margin: EdgeInsets.fromLTRB(15.w, 0, 15.w, 0),
              padding: EdgeInsets.all(15.w), // PADDING
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 56, 56, 56).withOpacity(0.10),
                    spreadRadius: 10.r,
                    blurRadius: 10.r,
                    offset: const Offset(0, 6), // CHANGES POSITION OF SHADOW
                  ),
                ],
                color: Theme.of(context).hintColor,
                borderRadius: BorderRadius.circular(20.r), // RADIUS
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // TEXT BUTTON TO CHANGE NAME
                  TextButton(
                    style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        elevation: 20,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (BuildContext context) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.r), // RADIUS
                                topRight: Radius.circular(30.r), // RADIUS
                              ),
                            ),
                            height: MediaQuery.of(context).size.height * 0.9,
                            child: const ResetProfileName(),
                          );
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Symbols.person_edit_rounded, color: Theme.of(context).primaryColorDark, size: 20.sp),
                            SizedBox(width: 10.w),
                            Text(
                              "Update your profile name",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp, // FONT SIZE
                                color: Theme.of(context).canvasColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).canvasColor.withOpacity(0.5),
                          size: 17.sp, // ICON SIZE
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Theme.of(context).canvasColor.withOpacity(0.2)),
      
                  // TEXT BUTTON TO CHANGE EMAIL
                  TextButton(
                    style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        elevation: 20,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (BuildContext context) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.r), // RADIUS
                                topRight: Radius.circular(30.r), // RADIUS
                              ),
                            ),
                            height: MediaQuery.of(context).size.height * 0.9,
                            child: const ResetEmail(),
                          );
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Symbols.email, color: Theme.of(context).primaryColorDark, size: 20.sp),
                            SizedBox(width: 10.w),
                            Text(
                              "Update your email",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp, // FONT SIZE
                                color: Theme.of(context).canvasColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).canvasColor.withOpacity(0.5),
                          size: 17.sp, // ICON SIZE
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Theme.of(context).canvasColor.withOpacity(0.2)),
      
                  // TEXT BUTTON FOR PASSWORD UPDATE
                  TextButton(
                    style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        elevation: 20,
                        shape:  RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r )),
                        ),
                        builder: (BuildContext context) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.r), // RADIUS
                                topRight: Radius.circular(30.r), // RADIUS
                              ),
                            ),
                            height: MediaQuery.of(context).size.height * 0.9,
                            child: const ResetPasswordForSettings(),
                          );
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Symbols.lock, color: Theme.of(context).primaryColorDark, size: 20.sp),
                            SizedBox(width: 10),
                            Text(
                              "Update your password",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp, // FONT SIZE
                                color: Theme.of(context).canvasColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).canvasColor.withOpacity(0.5),
                          size: 17.sp, // ICON SIZE
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Theme.of(context).canvasColor.withOpacity(0.2)),
      
                  // TEXT BUTTON FOR DAILY LIMIT
                  TextButton(
                    style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        elevation: 20,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (BuildContext context) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.r), // RADIUS
                                topRight: Radius.circular(30.r), // RADIUS
                              ),
                            ),
                            height: MediaQuery.of(context).size.height * 0.9,
                            child: const ResetDailyLimit(),
                          );
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Symbols.calendar_clock, color: Theme.of(context).primaryColorDark, size: 20.sp),
                            SizedBox(width: 10.w),
                            Text(
                              "Reset your daily limit",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp, // FONT SIZE
                                color: Theme.of(context).canvasColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).canvasColor.withOpacity(0.5),
                          size: 17.sp, // ICON SIZE
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Theme.of(context).canvasColor.withOpacity(0.2)),
      
                  // TEXT BUTTON FOR MONTHLY LIMIT
                  TextButton(
                    style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        elevation: 20,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (BuildContext context) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.r), // RADIUS
                                topRight: Radius.circular(30.r), // RADIUS
                              ),
                            ),
                            height: MediaQuery.of(context).size.height * 0.9,
                            child: const ResetMonthlyLimit(),
                          );
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Symbols.calendar_clock, color: Theme.of(context).primaryColorDark, size: 20.sp),
                            SizedBox(width: 10.w),
                            Text(
                              "Reset your monthly limit",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp, // FONT SIZE
                                color: Theme.of(context).canvasColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).canvasColor.withOpacity(0.5),
                          size: 17.sp, // ICON SIZE
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Theme.of(context).canvasColor.withOpacity(0.2)),
      
                  // TEXT BUTTON FOR FEEDBACK
                  TextButton(
                    style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        elevation: 20,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (BuildContext context) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.r), // RADIUS
                                topRight: Radius.circular(30.r), // RADIUS
                              ),
                            ),
                            height: MediaQuery.of(context).size.height * 0.9,
                            child: const SendFeedbackScreen(),
                          );
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Symbols.forum, color: Theme.of(context).primaryColorDark, size: 20.sp),
                            SizedBox(width: 10.w,),
                            Text(
                              "Send feedback",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp, // FONT SIZE
                                color: Theme.of(context).canvasColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).canvasColor.withOpacity(0.5),
                          size: 17.sp, // ICON SIZE
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Theme.of(context).canvasColor.withOpacity(0.2)),
      
                  // TEXT BUTTON TO CONTACT US
                  TextButton(
                    style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        elevation: 20,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (BuildContext context) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.r), // RADIUS
                                topRight: Radius.circular(30.r), // RADIUS
                              ),
                            ),
                            height: MediaQuery.of(context).size.height * 0.9,
                            child: const ResetEmail(),
                          );
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Symbols.headset_mic, color: Theme.of(context).primaryColorDark, size: 20.sp),
                            SizedBox(width: 10.w),
                            Text(
                              "Contact us",
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp, // FONT SIZE
                                color: Theme.of(context).canvasColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).canvasColor.withOpacity(0.5),
                          size: 17.sp, // ICON SIZE
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Theme.of(context).canvasColor.withOpacity(0.2)),
                  
                  // THEME CHANGE TOGGLE
                  Padding(
                    padding: EdgeInsets.fromLTRB(10.w, 0, 7.w, 0), // PADDING
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                        Icon(Symbols.dark_mode, color: Theme.of(context).primaryColorDark, size: 20.sp),
                        SizedBox(width: 10.w,),
                        Text(
                          "Dark mode",
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp, // FONT SIZE
                            color: Theme.of(context).primaryColorDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]),
                  
                        BlocBuilder<ThemeCubit, ThemeMode>(
                          builder: (context, currentTheme) {
                            return CupertinoSwitch(
                              value: currentTheme == ThemeMode.dark,
                              onChanged: (bool value) {
                                BlocProvider.of<ThemeCubit>(context).toggleTheme();
                              },
                              activeColor: AppColors.foregroundColor,
                              thumbColor: Colors.white,
                              focusColor: Theme.of(context).scaffoldBackgroundColor,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 25.h), // SPACING
      
            // LOG OUT AND ACCOUNT DELETE BUTTONS
            Container(
              margin: EdgeInsets.fromLTRB(15.w, 0, 15.w, 15.h),
              padding: EdgeInsets.all(20.w), // PADDING
              width: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 32, 32, 32).withOpacity(0.10),
                    spreadRadius: 12.r,
                    blurRadius: 15.r,
                    offset: const Offset(0, 3),
                  ),
                ],
                color: Theme.of(context).hintColor,
                borderRadius: BorderRadius.circular(20.r), // RADIUS
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildElevatedButton(
                    onPressed: () => _logout(context),
                    text: 'Log out',
                    icon: Icons.logout,
                    backgroundColor: AppColors.foregroundColor,
                  ),
                  Divider(color: Theme.of(context).primaryColorDark.withOpacity(0.6)),
                  SizedBox(height: 1.h), // SPACING
                  _buildElevatedButton(
                    onPressed: () => _deleteAccount(context),
                    text: 'Delete account',
                    icon: Icons.delete_outline,
                    backgroundColor: Colors.red.shade200,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElevatedButton({
    required VoidCallback onPressed,
    required String text,
    double fontSize = 14,
    IconData? icon,
    Color backgroundColor = AppColors.foregroundColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: EdgeInsets.all(5.w), // PADDING
          backgroundColor: Theme.of(context).hintColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r), // RADIUS
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: backgroundColor,
                size: 20.sp, // ICON SIZE
              ),
              SizedBox(width: 10.w), // SPACING
            ],
            Text(
              text,
              style: GoogleFonts.poppins(
                color: backgroundColor,
                fontSize: fontSize.sp, // FONT SIZE
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}