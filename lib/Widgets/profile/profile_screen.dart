// C:\Users\Hp\Desktop\moneyy\moneyy\lib\Widgets\profile\profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/Widgets/user_auth/password_reset_screen.dart';
import 'package:moneyy/ui/succes_snackbar.dart';

import '../../firebase/user_service.dart';
import '../../styles/theme_bloc.dart';
import '../../styles/theme_event.dart';
import '../../styles/themes.dart';
import '../../ui/dialogue_box.dart';
import '../../ui/error_snackbar.dart';


class ProfileSettings extends StatefulWidget {
  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _monthlyLimitController = TextEditingController();
  final TextEditingController _dailyLimitController = TextEditingController();
  bool _isDarkMode = false;

  late UserService _userService;
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _userService = UserService();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      _userData = await _userService.fetchUserData(context);
      setState(() {
        _emailController.text = _userData['userName'] ?? '';
        _monthlyLimitController.text = _userData['monthlyLimit']?.toString() ?? '';
        _dailyLimitController.text = _userData['dailyLimit']?.toString() ?? '';
      });
    } catch (e) {
      if (mounted) {
        showCustomSnackBarError(context, "Error loading user data");
      }
    }
  }

  void _updateEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      errorSnackbar(context, "Email cannot be empty");
      return;
    }
    try {
      await _userService.updateEmail(email);
      showCustomSnackBar(context, "Email updated successfully");
    } catch (e) {
      errorSnackbar(context, "Login again to perform this action");
    }
  }

  void _updateMonthlyLimit() async {
    final text = _monthlyLimitController.text.trim();
    if (text.isEmpty) {
      errorSnackbar(context, "Monthly limit cannot be empty");
      return;
    }
    final limit = double.tryParse(text);
    if (limit == null) {
      errorSnackbar(context, "Invalid monthly limit");
      return;
    }
    try {
      await _userService.updateMonthlyLimit(_userData['uid'], limit);
      setState(() {
        _userData['monthlyLimit'] = limit;
      });
      showCustomSnackBar(context, "Monthly limit updated successfully");
    } catch (e) {
      errorSnackbar(context, "Error updating monthly limit");
    }
  }

  void _updateDailyLimit() async {
    final text = _dailyLimitController.text.trim();
    if (text.isEmpty) {
      errorSnackbar(context, "Daily limit cannot be empty");
      return;
    }
    final limit = double.tryParse(text);
    if (limit == null) {
      errorSnackbar(context, "Invalid daily limit");
      return;
    }
    try {
      await _userService.updateDailyLimit(_userData['uid'], limit);
      setState(() {
        _userData['dailyLimit'] = limit;
      });
      successSnackbar(context, "Daily limit updated successfully");
    } catch (e) {
      errorSnackbar(context, "Error updating daily limit");
      print(e);
    }
  }

  void _updatePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResetPassword()),
    );
  }

  void _logout(BuildContext context) {
    showSignOutConfirmationDialog(context);
  }

  void _deleteAccount() {
    _userService.deleteAccount(_userData['uid']);
  }

  void _toggleTheme() {
    context.read<ThemeBloc>().add(ToggleThemeEvent());
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
      backgroundColor: Theme.of(context).primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Adjust this height as needed
        child: AppBar(
          scrolledUnderElevation: 0,
          elevation: 0,
          toolbarHeight: 90,
          iconTheme: IconThemeData(color: Theme.of(context).cardColor,size: 30),
          backgroundColor: Theme.of(context).primaryColor,
          title: Container(
            alignment: Alignment.bottomLeft, // Align title to the bottom-left
            child: Text(
              'Profile settings',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).cardColor,
              ),
            ),
          ),
          
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 15, 20, 15),

        child: SingleChildScrollView(
          child: Column(
            children: [


              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 32, 32, 32).withOpacity(0.10),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: Offset(0, 5), // changes position of shadow
                ),
              ],
                  color: Theme.of(context).primaryColorDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Text button to change email
                    TextButton(onPressed: _updateEmail,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Text("Update your email",
                        style: GoogleFonts.montserrat(fontSize: 16,color: Theme.of(context).cardColor
                        ,fontWeight: FontWeight.w600),),
                        Icon(Icons.arrow_forward_ios,color: Theme.of(context).cardColor,),
                      ],
                    )
                    ),
                    Divider(color: Theme.of(context).cardColor.withOpacity(0.6),),
                    
                    // Text button to update password
                    TextButton(onPressed: (){},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Text("Update your password",
                        style: GoogleFonts.montserrat(fontSize: 16,color: Theme.of(context).cardColor
                        ,fontWeight: FontWeight.w600),),
                        Icon(Icons.arrow_forward_ios,color: Theme.of(context).cardColor,),
                      ],
                    )
                    ),
                    Divider(color: Theme.of(context).cardColor.withOpacity(0.6),),
                    
                    // Text button to change daily limit
                    TextButton(onPressed: (){},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Text("Reset your daily limit",
                        style: GoogleFonts.montserrat(fontSize: 16,color: Theme.of(context).cardColor
                        ,fontWeight: FontWeight.w600),),
                        Icon(Icons.arrow_forward_ios,color: Theme.of(context).cardColor,),
                      ],
                    )
                    ),
                    Divider(color: Theme.of(context).cardColor.withOpacity(0.6),),

                    // Textb button to change monthly limit
                    TextButton(onPressed: (){},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Text("Reset your monthly limit",
                        style: GoogleFonts.montserrat(fontSize: 16,color: Theme.of(context).cardColor
                        ,fontWeight: FontWeight.w600),),
                        Icon(Icons.arrow_forward_ios,color: Theme.of(context).cardColor,),
                      ],
                    )
                    ),
                    Divider(color: Theme.of(context).cardColor.withOpacity(0.6),),
                    
                    // Theme changing text
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                        Text("   Change theme",
                        style: GoogleFonts.montserrat(fontSize: 16,color: Theme.of(context).cardColor
                        ,fontWeight: FontWeight.w600),),

                        IconButton(
                        icon: Icon(Icons.sunny,color: Theme.of(context).cardColor,),
                        onPressed: _toggleTheme,
                        ),
                      ],
                    ),


                    
                  ],
                ),
              ),
              SizedBox(height: 15),
              
              SizedBox(height: 20),

              Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                  BoxShadow(
                  color: const Color.fromARGB(255, 32, 32, 32).withOpacity(0.18),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: Offset(0, 3),
                ),
                ],
                  color:Theme.of(context).primaryColorDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    _buildElevatedButton(
                      onPressed: () => _logout(context),
                      text: 'Log out',
                      icon: Icons.logout,
                      backgroundColor: Color.fromARGB(255, 151, 175, 224),
                    ),
                    SizedBox(height: 20),
                    _buildElevatedButton(
                      onPressed: _deleteAccount,
                      text: 'Delete account',
                      icon: Icons.delete_outline,
                      backgroundColor: AppColors.myOrange,
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

  Widget _buildTextField({required TextEditingController controller, required String hintText, bool isEmail = false}) {
    return Container(
      padding: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.montserrat(color: AppColors.myFadeblue),
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.number,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.montserrat(color: AppColors.myFadeblue),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildElevatedButton({
    required VoidCallback onPressed,
    required String text,
    double fontSize = 16,
    IconData? icon,
    Color backgroundColor = AppColors.myFadeblue,
  }) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: AppColors.myDark,
                size: 20,
              ),
              SizedBox(width: 8),
            ],
            Text(
              text,
              style: GoogleFonts.montserrat(
                color: AppColors.myDark,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
