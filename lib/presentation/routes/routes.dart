import 'package:flutter/material.dart';
import 'package:moneyy/presentation/screens/account_settings/change_daily_limit.dart';
import 'package:moneyy/presentation/screens/account_settings/change_email.dart';
import 'package:moneyy/presentation/screens/account_settings/change_monthly_limit.dart';
import 'package:moneyy/presentation/screens/account_settings/change_password.dart';
import 'package:moneyy/presentation/screens/account_settings/profile_settings_main_screen.dart';
import 'package:moneyy/presentation/screens/account_settings/send_feedback.dart';
import 'package:moneyy/presentation/screens/bills/all_bills.dart';
import 'package:moneyy/presentation/screens/expenses/all_expenses.dart';
import 'package:moneyy/presentation/screens/home_screen/home_screen.dart'; // Import main screen
import 'package:moneyy/presentation/screens/home_screen/widgets/loading_screen/loading_screen.dart';
import 'package:moneyy/presentation/screens/income/all_income.dart';
import 'package:moneyy/presentation/screens/user_auth/password_forgot/password_reset_screen.dart';
import 'package:moneyy/presentation/screens/user_auth/sign_in/sign_in.dart';
import 'package:moneyy/presentation/screens/user_auth/sign_up/sign_up.dart';


class AppRoutes {
  static const String signUp = '/signup';
  static const String logIn = '/login';
  static const String mainScreen = '/mainScreen';
  static const String passwordResetScreen = "/passwordResetScreen";
  static const String profileScreen = "/profileScreen";
  static const String passwordResetScreenForSettings = "/passwordResetScreenForSettings";
  static const String changeEmail ="/changeEmail";
  static const String changeDailyLimit ="/changeDailyLimit";
  static const String changeMonthlyLimit ="/changeMonthlyLimit";
  static const String sendFeedbackScreen = "/SendFeedbackScreen";
  static const String spendingScreen = '/SpendingScreen';
  static const String shimmerScreen = '/ShimmerScreen';
  static const String billScreen = '/BillScreen';
  static const String incomeScreen = '/IncomeScreen';







  static Route<dynamic> generateRoute(RouteSettings settings) {

    switch (settings.name) {

      case shimmerScreen:
        return MaterialPageRoute(builder: (_) => ShimmerScreen());

      case billScreen:
        return MaterialPageRoute(builder: (_) => BillScreen());

      case incomeScreen:
        return MaterialPageRoute(builder: (_) => IncomeScreen());

      case signUp:
        return MaterialPageRoute(builder: (_) => SignUpScreen());

      case spendingScreen:
        return MaterialPageRoute(builder: (_) => SpendingScreen());

      case logIn:
        return MaterialPageRoute(builder: (_) => LoginScreen());

      case mainScreen: // Define the route for main screen
        return MaterialPageRoute(builder: (_) => HomeScreen());

      case passwordResetScreen: // Define the route for main screen
        return MaterialPageRoute(builder: (_) => ResetPassword());
      
      case passwordResetScreenForSettings: // Define the route for main screen
        return MaterialPageRoute(builder: (_) => ResetPasswordForSettings());

      case profileScreen: // Define the route for main screen
        return MaterialPageRoute(builder: (_) => ProfileSettings());

      case changeEmail:
        return MaterialPageRoute(builder: (_) => ResetEmail());

      case changeDailyLimit:
        return MaterialPageRoute(builder: (_) => ResetDailyLimit());

      case changeMonthlyLimit:
        return MaterialPageRoute(builder: (_) => ResetMonthlyLimit());

      case sendFeedbackScreen:
        return MaterialPageRoute(builder: (_) => SendFeedbackScreen());


      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
