import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/common/widgets/info_snackbar.dart';
import 'package:moneyy/core/colors/colors.dart';
import 'package:moneyy/data/models/auth/create_user_req.dart';
import 'package:moneyy/domain/usecases/auth/sign_up.dart';
import 'package:moneyy/presentation/routes/routes.dart';
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
    super.key,
  });

  @override
  _RegisterButtonWidgetState createState() => _RegisterButtonWidgetState();
}

class _RegisterButtonWidgetState extends State<RegisterButtonWidget> {
  bool isLoading = false; // TRACK LOADING STATE

  // REGISTER BUTTON LOGIC
  Future<void> _onRegister() async {
    if (widget.formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // SHOW LOADING ANIMATION
      });

      var result = await sl<SignUpUseCase>().call(
        params: UserCreateReq(
          email: widget.emailController.text.trim(),
          firstName: widget.firstNameController.text.trim(),
          lastName: widget.lastNameController.text.trim(),
          uid: '',
        ),
        password: widget.passwordController.text.trim(),

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
          infoSnackbar(context, 'Please verify your email and login');
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.logIn, // DEFINE THIS ROUTE IN APP ROUTES
            (route) => false,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.w), // PADDING
      child: InkWell(
        onTap: _onRegister,
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
                        'Register',
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
}