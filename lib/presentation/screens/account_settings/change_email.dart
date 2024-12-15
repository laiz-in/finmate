import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/domain/usecases/auth/email_reset.dart';
import 'package:moneyy/presentation/routes/routes.dart';
import 'package:moneyy/service_locator.dart';
import 'package:moneyy/styles/themes.dart';

class ResetEmail extends StatefulWidget {
  const ResetEmail({super.key});

  @override
  State<ResetEmail> createState() => _ResetEmailState();
}

class _ResetEmailState extends State<ResetEmail> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;


  // Reset password logic
  void _resetEmail() async {
    if (_formKey.currentState!.validate()) {
        setState(() {
        _isLoading = true;
        });

        final resetPasswordUseCase = sl<ResetEmailUseCase>();
        final result = await resetPasswordUseCase.call(email: emailController.text.trim());

        result.fold(
          (l) {
            if(mounted){
            errorSnackbar(context, l.toString());}
            setState(() {
            _isLoading = false;
            });
          },

          (r) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.logIn, (route) => false);
          },
        );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor:Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color:Theme.of(context).canvasColor),
      ),


      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Dismisses the keyboard when tapping outside the text field
        },
        child: Stack(
          children: [
            // Container
            Container(
              decoration: BoxDecoration(
                color:Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            // Align for the email and button Text fields
            Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 40,),


                      // email reset heading
                      Padding(
                        padding:
                            EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Text(
                              ' Reset Email',
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).canvasColor,
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Symbols.email,
                              color:Theme.of(context).canvasColor,
                              size: 35,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 15,),
                      
                      // Email address field
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.0, 20, 20, 0),
                        child: TextFormField(
                          controller: emailController,
                          cursorColor: Theme.of(context).canvasColor.withOpacity(0.7),
                          style: GoogleFonts.poppins(
                            color:Theme.of(context).canvasColor,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                            fontSize: 20,
                          ),
                          decoration: InputDecoration(
                            fillColor: Theme.of(context).highlightColor,
                            filled: true,
                            contentPadding: EdgeInsets.all(16),
                            prefixIcon: Icon(
                              Symbols.email,
                              color:Theme.of(context).canvasColor.withOpacity(0.7),
                            ),
                            label: Text(
                              'Enter your new email',
                              style: GoogleFonts.poppins(fontSize: 15,fontWeight: FontWeight.w400,color: Theme.of(context).canvasColor.withOpacity(0.7)),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelStyle: GoogleFonts.montserrat(
                              color:AppColors.myFadeblue,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Theme.of(context).scaffoldBackgroundColor,width: 0),
                        
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Theme.of(context).scaffoldBackgroundColor,width: 0),
                        
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Theme.of(context).scaffoldBackgroundColor,width: 0),
                        
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Send button
                      InkWell(
                        onTap: _resetEmail,
                        child:Padding(
                          padding: EdgeInsets.fromLTRB(20.0, 10, 20, 20),
                        child:
                          Container(
                          height: 63,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorDark,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                            'Submit',
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).hintColor,
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                                SizedBox(width: 10),
                                if (_isLoading)
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Theme.of(context).hintColor,
                                          strokeWidth: 3,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      )
                      ),

                      // Instructions
                      Padding(
                      padding:EdgeInsets.all(20),
                            child: Text(
                              softWrap: true,
                              'Note : By clicking submit , you will be redirected to login page , please verify your new Email before login',
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).canvasColor.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                        
                  

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
