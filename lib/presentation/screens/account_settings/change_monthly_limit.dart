import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/common/widgets/success_snackbar.dart';
import 'package:moneyy/domain/usecases/settings/reset_monthly_limit.dart';
import 'package:moneyy/service_locator.dart';
import 'package:moneyy/styles/themes.dart';


class ResetMonthlyLimit extends StatefulWidget {
  const ResetMonthlyLimit({super.key});


  @override
  State<ResetMonthlyLimit> createState() => _ResetMonthlyLimitState();
}

class _ResetMonthlyLimitState extends State<ResetMonthlyLimit> {
  final TextEditingController _limitController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Reset monthly limit logic
  void _resetMonthlyLimit() async {

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      int newLimit = int.parse(_limitController.text);
      final resetMonthlyLimitUseCase = sl<ResetMonthlyLimitUseCase>();
      final result = await resetMonthlyLimitUseCase.call(monthlyLimit: newLimit);

      result.fold(
        // If any error occured
        (l) {
          errorSnackbar(context, l.toString());
          setState(() {
          _isLoading = false;
          });

        },
        // If limit updation is success
        (r) {
              setState(() {
              _isLoading = false;
              });
              if(mounted){
              successSnackbar(context, 'Monthly limit has been updated');
              Navigator.pop(context);

              }
            },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,


      // BODY
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            

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
                        SizedBox(height: 15,),

                          Center(
                child: Container(
                  height: 3,
                  width:100 ,
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor.withOpacity(0.3)
                  ),
                ),
              ),
                      SizedBox(height: 40,),

                      // Monthly reset heading
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(
                              Icons.settings,
                              color:Theme.of(context).canvasColor,
                              size: 35,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Reset monthly limit',
                              style: GoogleFonts.poppins(
                              color:Theme.of(context).canvasColor,
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 15,),

                      // Amount field
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.0, 20, 20, 0),
                        child: TextFormField(
                          controller: _limitController,
                          cursorColor: Theme.of(context).canvasColor.withOpacity(0.7),
                          style: GoogleFonts.poppins(
                            color:Theme.of(context).canvasColor,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                            fontSize: 20,
                          ),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            fillColor: Theme.of(context).cardColor,
                            filled: true,
                            contentPadding: EdgeInsets.all(16),
                            prefixIcon: Icon(
                              Icons.currency_rupee,
                              color:Theme.of(context).canvasColor.withOpacity(0.7),
                            ),
                            label: Text(
                              'Enter amount',
                              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400, color: Theme.of(context).canvasColor.withOpacity(0.7)),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelStyle: GoogleFonts.poppins(
                              color: AppColors.myFadeblue,
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
                              return 'Please enter an amount';
                            }
                            if (!RegExp(r'^\d+$').hasMatch(value)) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      
                      SizedBox(height: 20),

                      // Send button
                      InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: _resetMonthlyLimit,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.0, 10, 20, 20),
                          child: Container(
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
                                  SizedBox(width: 15,),
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
                        ),
                      ),


                      // Instructions
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          softWrap: true,
                          'Note: Your monthly limit will remain the same until you update it next time',
                          style: GoogleFonts.poppins(
                                color: Theme.of(context).canvasColor.withOpacity(0.5),
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
