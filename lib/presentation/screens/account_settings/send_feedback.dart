
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/common/widgets/success_snackbar.dart';
import 'package:moneyy/domain/usecases/settings/send_feedback.dart';
import 'package:moneyy/service_locator.dart';
import 'package:moneyy/styles/themes.dart';
import 'package:moneyy/ui/error_snackbar.dart';

class SendFeedbackScreen extends StatefulWidget {
  const SendFeedbackScreen({super.key});

  @override
  State<SendFeedbackScreen> createState() => _SendFeedbackScreenState();
}

class _SendFeedbackScreenState extends State<SendFeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Send feedback logic
  void _sendFeedback() async {

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      String feedback = _feedbackController.text; // Updated feedback text controller
      final sendFeedbackUseCase = sl<SendFeedbackUseCase>();
      final result = await sendFeedbackUseCase.call(feedback: feedback);

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
              successSnackbar(context, 'Feedback has been added!');
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
          FocusScope.of(context).unfocus();
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

                      SizedBox(height: 10,),

                      // Feedback heading
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(
                              Icons.feedback,
                                color: Theme.of(context).canvasColor,
                              size: 35,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Send your feedback',
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).canvasColor,
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 15,),

                      // Feedback text field
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.0, 20, 20, 0),
                        child: TextFormField(
                          
                          controller: _feedbackController,
                          cursorColor: Theme.of(context).canvasColor.withOpacity(0.7),
                          style: GoogleFonts.poppins(
                            color:Theme.of(context).canvasColor,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                            fontSize: 17,
                            letterSpacing: 0.1,
                          ),
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: null, // Allows the field to expand
                          decoration: InputDecoration(
                            
                            fillColor: Theme.of(context).highlightColor,
                            filled: true,
                            contentPadding: EdgeInsets.all(16),
                            
                            label: Text(
                              'Enter your feedback',
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
                              return 'Please enter your feedback';
                            }
                            return null;
                          },
                        ),
                      ),
                      
                      SizedBox(height: 20),

                      // Submit button
                      InkWell(
                        onTap: _sendFeedback,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.0, 10, 20, 20),
                          child: Container(
                            padding: EdgeInsets.all(10),
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
