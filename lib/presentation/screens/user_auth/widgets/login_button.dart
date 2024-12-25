import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/core/colors/colors.dart';
import 'package:moneyy/data/models/auth/signin_user_req.dart';
import 'package:moneyy/domain/usecases/auth/sign_in.dart';
import 'package:moneyy/presentation/routes/routes.dart';
import 'package:moneyy/service_locator.dart';

class LoginButtonWidget extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;

  const LoginButtonWidget({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    super.key,
  });

  @override
  LoginButtonWidgetState createState() => LoginButtonWidgetState();
}

class LoginButtonWidgetState extends State<LoginButtonWidget> {
  bool isLoading = false; // TRACK LOADING STATE

  // HELPER METHOD FOR LOGIN BUTTON
  Widget _loginButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.w), // PADDING
      child: InkWell(
        onTap: () async {
          // VALIDATE THE FORM
          if (widget.formKey.currentState!.validate()) {
            setState(() {
              isLoading = true; // SHOW LOADING ANIMATION
            });

            // PERFORM SIGN-IN USE CASE
            var result = await sl<SignInUseCase>().call(
              params: UserSignInReq(
                email: widget.emailController.text.toString(),
                password: widget.passwordController.text.toString(),
              ),
            );

            result.fold(
              (error) {
                setState(() {
                  isLoading = false; // HIDE ANIMATION ON ERROR
                });
                errorSnackbar(context, error.toString());
              },
              (success) {
                setState(() {
                  isLoading = false; // HIDE ANIMATION ON SUCCESS
                });
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.mainScreen, // DEFINE THIS ROUTE IN APP ROUTES
                  (route) => false,
                );
              },
            );
          }
        },
        child: Container(
          height: 65.h, // HEIGHT
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(15.0.r), // RADIUS
          ),
          child: Center(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.foregroundColor,
                      strokeWidth: 2.w, // STROKE WIDTH
                    ),
                  ) // SHOW LOADING ANIMATION
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Login',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF4C7766),
                          fontSize: 28.sp, // FONT SIZE
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loginButton(context);
  }
}