import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/common/widgets/info_snackbar.dart';
import 'package:moneyy/data/models/auth/create_user_req.dart';
import 'package:moneyy/domain/usecases/auth/sign_up.dart';
import 'package:moneyy/presentation/routes/routes.dart';
import 'package:moneyy/presentation/screens/user_auth/widgets/loading_dots.dart'; // Loading animation widget
import 'package:moneyy/service_locator.dart';

class RegisterButtonWidget extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final GlobalKey<FormState> formKey;

  const RegisterButtonWidget({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.firstNameController,
    required this.lastNameController,
    Key? key,
  }) : super(key: key);

  @override
  _RegisterButtonWidgetState createState() => _RegisterButtonWidgetState();
}

class _RegisterButtonWidgetState extends State<RegisterButtonWidget> {
  bool isLoading = false; // Track loading state

  Future<void> _onRegister() async {
    if (widget.formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // Show loading animation
      });

      var result = await sl<SignUpUseCase>().call(
        params: UserCreateReq(
          email: widget.emailController.text.trim(),
          password: widget.passwordController.text.trim(),
          firstName: widget.firstNameController.text.trim(),
          lastName: widget.lastNameController.text.trim(),
        ),
      );

      result.fold(
        (l) {
          setState(() {
            isLoading = false; // Hide animation on error
          });
          errorSnackbar(context, l.toString());
        },

        (r) {
          setState(() {
            isLoading = false; // Hide animation on success
          });
          infoSnackbar(context, "Please verify email and proceed to login");
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.logIn, // Redirect to login screen
            (route) => false,
          );
        },
      );
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: InkWell(
        onTap: _onRegister,
        child: Container(
          height: 65,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Center(
            child: isLoading
                ? Center(child: LoadingDots()) // Show loading animation if isLoading is true
                : Text(
                    'Register',
                    style: GoogleFonts.poppins(
                      color: Color(0xFF4C7766),
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
