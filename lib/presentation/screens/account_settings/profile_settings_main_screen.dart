// C:\Users\Hp\Desktop\moneyy\moneyy\lib\Widgets\profile\profile_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/bloc/themes/theme_cubit.dart';
import 'package:moneyy/core/colors/colors.dart';
import 'package:moneyy/presentation/routes/routes.dart';
import 'package:moneyy/presentation/screens/account_settings/change_daily_limit.dart';
import 'package:moneyy/presentation/screens/account_settings/change_monthly_limit.dart';
import 'package:moneyy/presentation/screens/account_settings/photo_and_name.dart';
import 'package:moneyy/presentation/screens/account_settings/widgets/account_deletion_confirmation.dart';
import 'package:moneyy/presentation/screens/account_settings/widgets/sign_out_confirmation_dialogue.dart';



class ProfileSettings extends StatefulWidget {
  @override
  ProfileSettingsState createState() => ProfileSettingsState();
}

class ProfileSettingsState extends State<ProfileSettings> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _monthlyLimitController = TextEditingController();
  final TextEditingController _dailyLimitController = TextEditingController();





// function to log out
void _logout(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const SignOutConfirmationDialog();
    },
  );
}




// funciton to delete the user account
void _deleteAccount(BuildContext context) {
showDialog(
    context: context,
    builder: (BuildContext context) {
      return const AccountDeletionConfirmationDialog();
    },
  );}

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

      //App bar
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Adjust this height as needed
        child: AppBar(
          scrolledUnderElevation: 0,
          elevation: 0,
          toolbarHeight: 90,
          iconTheme: IconThemeData(color: Theme.of(context).canvasColor,size: 30),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,

          title: Container(
            alignment: Alignment.bottomLeft, // Align title to the bottom-left
            child: Text(
              'Profile settings',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).canvasColor,
              ),
            ),
          ),
          
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 15, 15, 15),

        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(width: double.infinity,height: 15,),

              ProfilePage(),
              
              SizedBox(width: double.infinity,height: 18,),
              
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 68, 67, 67).withOpacity(0.15),
                  spreadRadius: 6,
                  blurRadius: 10,
                  offset: Offset(0, 6), // changes position of shadow
                ),
              ],
                  color: Theme.of(context).hintColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    

                    // Text button to change email
                    TextButton(
                      style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      ),
                      onPressed: () {
                                      Navigator.pushNamed(context, '/changeEmail');
                                      },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Text("Update your email",
                        style: GoogleFonts.poppins(fontSize: 15,color: Theme.of(context).canvasColor
                        ,fontWeight: FontWeight.w500),),
                        Icon(Icons.arrow_forward_ios,color: Theme.of(context).canvasColor.withOpacity(0.5),size: 17,),
                      ],
                    )
                    ),
                    Divider(color: Theme.of(context).canvasColor.withOpacity(0.2),),



                    // Text button to update password
                    TextButton(
                      style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      ),
                      onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.passwordResetScreenForSettings);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children:[
                                  Text("Update your password",
                                  style: GoogleFonts.poppins(fontSize: 15,color: Theme.of(context).canvasColor
                                  ,fontWeight: FontWeight.w500),),
                        Icon(Icons.arrow_forward_ios,color: Theme.of(context).canvasColor.withOpacity(0.5),size: 17,),
                                  ],
                                )
                    ),
                    Divider(color: Theme.of(context).canvasColor.withOpacity(0.2),),



                    // Text button to change daily limit
                    TextButton(
                      style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      ),onPressed: () {
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
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30))
                                ),
                                height: (MediaQuery.of(context).size.height*0.9),
                            
                                child: ResetDailyLimit(),
                              );
                            },
                      );},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Text("Reset your daily limit",
                        style: GoogleFonts.poppins(fontSize: 15,color: Theme.of(context).canvasColor
                        ,fontWeight: FontWeight.w500),),
                        Icon(Icons.arrow_forward_ios,color: Theme.of(context).canvasColor.withOpacity(0.5),size: 17,),
                      ],
                    )
                    
                    ),
                    Divider(color: Theme.of(context).canvasColor.withOpacity(0.2),),



                    // Textb button to change monthly limit
                    TextButton(
                      style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      ),
                      onPressed: ()
                      {
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
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30))
                                ),
                                height: (MediaQuery.of(context).size.height*0.9),
                            
                                child: ResetMonthlyLimit(),
                              );
                            },
                      );},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Text("Reset your monthly limit",
                        style: GoogleFonts.poppins(fontSize: 15,color: Theme.of(context).canvasColor
                        ,fontWeight: FontWeight.w500),),
                        Icon(Icons.arrow_forward_ios,color: Theme.of(context).canvasColor.withOpacity(0.5),size: 17,),
                      ],
                    )
                    ),
                    Divider(color: Theme.of(context).canvasColor.withOpacity(0.2),),



                    // Textb button to send feedback
                    TextButton(
                      style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      ),
                      onPressed: (){Navigator.pushNamed(
                                              context,
                                              AppRoutes.sendFeedbackScreen,
                                            );},
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Text("Send your feedback",
                        style: GoogleFonts.poppins(fontSize: 15,color: Theme.of(context).canvasColor
                        ,fontWeight: FontWeight.w500),),
                        Icon(Icons.arrow_forward_ios,color: Theme.of(context).canvasColor.withOpacity(0.5),size: 17,),
                      ],
                    )
                    ),
                    Divider(color: Theme.of(context).canvasColor.withOpacity(0.2),),



                    // Theme changing text
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 7, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Dark mode",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
              SizedBox(height: 25),
              
              // LOG OUT AND ACCOUNT DELETE BUTTONS
              Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                  BoxShadow(
                  color: const Color.fromARGB(255, 32, 32, 32).withOpacity(0.10),
                  spreadRadius: 12,
                  blurRadius: 15,
                  offset: Offset(0, 3),
                ),
                ],
                  color:Theme.of(context).hintColor,
                  borderRadius: BorderRadius.circular(20),
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

                    Divider(color: Theme.of(context).primaryColorDark.withOpacity(0.6),),

                    SizedBox(height: 1),
                    _buildElevatedButton(
                      onPressed: () => _deleteAccount(context),
                      text: 'Delete account',
                      icon: Icons.delete_outline,
                      backgroundColor:  Colors.red.shade200,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildElevatedButton({
    required VoidCallback onPressed,
    required String text,
    double fontSize = 16,
    IconData? icon,
    Color backgroundColor = AppColors.foregroundColor,
  }) {
    return SizedBox(
      
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: EdgeInsets.all(5),
          backgroundColor: Theme.of(context).hintColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: backgroundColor,
                size: 20,
              ),
              SizedBox(width: 10),
            ],
            Text(
              text,
              style: GoogleFonts.poppins(
                color:backgroundColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
