import 'package:flutter/material.dart';
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
  bool isLoading = false; // Track loading state

  Widget _loginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: InkWell(
        onTap: () async {
          // Validate the form
          if (widget.formKey.currentState!.validate()) {
            setState(() {
              isLoading = true; // Show loading animation
            });

            // Perform sign-in use case
            var result = await sl<SignInUseCase>().call(
              params: UserSignInReq(
                email: widget.emailController.text.toString(),
                password: widget.passwordController.text.toString(),
              ),
            );

            result.fold(
              (error) {
                setState(() {
                  isLoading = false; // Hide animation on error
                });
                errorSnackbar(context, error.toString());
              },
              (success) {
                setState(() {
                  isLoading = false; // Hide animation on success
                });
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.mainScreen, // Define this route in AppRoutes
                  (route) => false,
                );
              },
            );
          }
        },
        child: Container(
          height: 65,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Center(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.foregroundColor,strokeWidth: 2,)) // Show loading animation
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Login',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF4C7766),
                          fontSize: 28,
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
