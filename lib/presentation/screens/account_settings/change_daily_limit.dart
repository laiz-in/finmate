import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  // RESET DAILY LIMIT LOGIC
  void _resetDailyLimit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      int newLimit = int.parse(_limitController.text);
      final resetDailyLimitUseCase = sl<ResetDailyLimitUseCase>();
      final result = await resetDailyLimitUseCase.call(dailyLimit: newLimit);

      result.fold(
        // IF ANY ERROR OCCURRED
        (l) {
          errorSnackbar(context, l.toString());
          setState(() {
            _isLoading = false;
          });
        },
        // IF LIMIT UPDATION IS SUCCESS
        (r) {
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
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
      backgroundColor: Colors.transparent,

      // BODY
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // DISMISSES THE KEYBOARD WHEN TAPPING OUTSIDE THE TEXT FIELD
        },
        child: SingleChildScrollView(
          child: Stack(
            children: [
              // ALIGN FOR THE EMAIL AND BUTTON TEXT FIELDS
              Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 15.h), // SPACING

                        Center(
                          child: Container(
                            height: 3.h,
                            width: 100.w,
                            decoration: BoxDecoration(
                              color: Theme.of(context).canvasColor.withOpacity(0.3),
                            ),
                          ),
                        ),

                        SizedBox(height: 40.h), // SPACING

                        // CHANGE LIMIT HEADING
                        Padding(
                          padding: EdgeInsets.all(20.w), // PADDING
                          child: Row(
                            children: [
                              Icon(
                                Icons.settings,
                                color: Theme.of(context).canvasColor,
                                size: 35.sp, // ICON SIZE
                              ),
                              SizedBox(width: 10.w), // SPACING
                              Text(
                                'Reset daily limit',
                                style: GoogleFonts.poppins(
                                  color: Theme.of(context).canvasColor,
                                  fontSize: 25.sp, // FONT SIZE
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 15.h), // SPACING

                        // AMOUNT FIELD
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0), // PADDING
                          child: TextFormField(
                            controller: _limitController,
                            cursorColor: Theme.of(context).canvasColor.withOpacity(0.7),
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).canvasColor,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none,
                              fontSize: 20.sp, // FONT SIZE
                            ),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              fillColor: Theme.of(context).cardColor,
                              filled: true,
                              contentPadding: EdgeInsets.all(16.w), // PADDING
                              prefixIcon: Icon(
                                Icons.currency_rupee,
                                color: Theme.of(context).canvasColor.withOpacity(0.7),
                                size: 22.sp, // ICON SIZE
                              ),
                              label: Text(
                                'Enter new daily limit',
                                style: GoogleFonts.poppins(
                                  fontSize: 15.sp, // FONT SIZE
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).canvasColor.withOpacity(0.7),
                                ),
                              ),
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0.r), // RADIUS
                                borderSide: BorderSide(color: Theme.of(context).scaffoldBackgroundColor, width: 0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0.r), // RADIUS
                                borderSide: BorderSide(color: Theme.of(context).scaffoldBackgroundColor, width: 0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0.r), // RADIUS
                                borderSide: BorderSide(color: Theme.of(context).scaffoldBackgroundColor, width: 0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0.r), // RADIUS
                                borderSide: BorderSide(
                                  color: Colors.red.shade200,
                                  width: 1.w, // BORDER WIDTH
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0.r), // RADIUS
                                borderSide: BorderSide(
                                  color: Colors.red.shade200,
                                  width: 1.w, // BORDER WIDTH
                                ),
                              ),
                              errorStyle: GoogleFonts.poppins(
                                color: Colors.red.shade200,
                                fontSize: 12.sp, // FONT SIZE
                                fontWeight: FontWeight.w400,
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

                        SizedBox(height: 15.h), // SPACING

                        // SEND BUTTON
                        InkWell(
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onTap: _resetDailyLimit,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h), // PADDING
                            child: Container(
                              height: 63.h, // HEIGHT
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColorDark,
                                borderRadius: BorderRadius.circular(15.0.r), // RADIUS
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Submit',
                                      style: GoogleFonts.poppins(
                                        color: Theme.of(context).hintColor,
                                        fontSize: 25.sp, // FONT SIZE
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 15.w), // SPACING

                                    if (_isLoading)
                                      SizedBox(
                                        height: 20.h, // HEIGHT
                                        width: 20.w, // WIDTH
                                        child: CircularProgressIndicator(
                                          color: Theme.of(context).hintColor,
                                          strokeWidth: 3.w, // STROKE WIDTH
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // INSTRUCTIONS
                        Padding(
                          padding: EdgeInsets.all(20.w), // PADDING
                          child: Text(
                            softWrap: true,
                            'Note: Your daily limit will remain the same until you update it next time',
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).canvasColor.withOpacity(0.7),
                              fontSize: 12.sp, // FONT SIZE
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
      ),
    );
  }
}