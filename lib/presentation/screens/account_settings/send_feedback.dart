import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/common/widgets/success_snackbar.dart';
import 'package:moneyy/domain/usecases/settings/send_feedback.dart';
import 'package:moneyy/service_locator.dart';

class SendFeedbackScreen extends StatefulWidget {
  const SendFeedbackScreen({super.key});

  @override
  State<SendFeedbackScreen> createState() => _SendFeedbackScreenState();
}

class _SendFeedbackScreenState extends State<SendFeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // SEND FEEDBACK LOGIC
void _sendFeedback() async {
  if (_formKey.currentState?.validate() ?? false) {
    setState(() {
      _isLoading = true;
    });

    String feedback = _feedbackController.text;
    final sendFeedbackUseCase = sl<SendFeedbackUseCase>();
    final result = await sendFeedbackUseCase.call(feedback: feedback);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    result.fold(
      // ERROR CASE
      (l) {
        errorSnackbar(context, l.toString());
      },
      // SUCCESS CASE
      (r) {
        successSnackbar(context, 'Feedback has been added!');
        Navigator.pop(context);
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

                      // FEEDBACK HEADING
                      Padding(
                        padding: EdgeInsets.all(20.w), // PADDING
                        child: Row(
                          children: [
                            Text(
                              ' Send Feedback',
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).canvasColor,
                                fontSize: 25.sp, // FONT SIZE
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 10.w), // SPACING
                            Icon(
                              Symbols.feedback,
                              color: Theme.of(context).canvasColor,
                              size: 35.sp, // ICON SIZE
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 15.h), // SPACING

                      // FEEDBACK TEXT FIELD
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0), // PADDING
                        child: TextFormField(
                          controller: _feedbackController,
                          cursorColor: Theme.of(context).canvasColor.withOpacity(0.7),
                          style: GoogleFonts.poppins(
                            color: Theme.of(context).canvasColor,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none,
                            fontSize: 14.sp, // FONT SIZE
                          ),
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: null, // ALLOWS THE FIELD TO EXPAND
                          decoration: InputDecoration(
                            fillColor: Theme.of(context).cardColor,
                            filled: true,
                            contentPadding: EdgeInsets.all(16.w), // PADDING
                            prefixIcon: Icon(
                              Symbols.feedback,
                              color: Theme.of(context).canvasColor.withOpacity(0.7),
                              size: 22.sp, // ICON SIZE
                            ),
                            label: Text(
                              'Enter your feedback',
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
                              return 'Please enter your feedback';
                            }
                            return null;
                          },
                        ),
                      ),

                      SizedBox(height: 15.h), // SPACING

                      // SEND BUTTON
                      InkWell(
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: _sendFeedback,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h), // PADDING
                          child: Container(
                            height: 55.h, // HEIGHT
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
                                  SizedBox(width: 10.w), // SPACING
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
                          'Note: Your feedback is valuable to us. Thank you for taking the time to share your thoughts.',
                          style: GoogleFonts.poppins(
                            color: Theme.of(context).canvasColor.withOpacity(0.7),
                            fontSize: 12.sp, // FONT SIZE
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