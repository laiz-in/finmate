import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/common/widgets/success_snackbar.dart';
import 'package:moneyy/domain/usecases/settings/reset_daily_limit.dart';
import 'package:moneyy/service_locator.dart';

class ResetDailyLimit extends StatefulWidget {
  const ResetDailyLimit({super.key});

  @override
  State<ResetDailyLimit> createState() => _ResetDailyLimitState();
}

class _ResetDailyLimitState extends State<ResetDailyLimit> {
  final TextEditingController _limitController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Reset daily limit logic
  void _resetDailyLimit() async {

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      int newLimit = int.parse(_limitController.text);
      final resetDailyLimitUseCase = sl<ResetDailyLimitUseCase>();
      final result = await resetDailyLimitUseCase.call(dailyLimit: newLimit);

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
              successSnackbar(context, 'Daily limit has been updated');
              Navigator.pop(context);

              }
            },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
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


                      // change limit heading
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
                              'Reset daily limit',
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
                            fillColor: Theme.of(context).highlightColor,
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
                        onTap: _resetDailyLimit,
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
                          'Note: Your daily limit will remain the same until you update it next time',
                          style: GoogleFonts.poppins(
                                color: Theme.of(context).canvasColor.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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
