import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/styles/themes.dart';
import 'package:moneyy/ui/error_snackbar.dart';

import '../../ui/succes_snackbar.dart';

class SendFeedbackScreen extends StatefulWidget {
  const SendFeedbackScreen({super.key});

  @override
  State<SendFeedbackScreen> createState() => _SendFeedbackScreenState();
}

class _SendFeedbackScreenState extends State<SendFeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Send feedback logic
  void _sendFeedback() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = _auth.currentUser;

        if (user != null) {
          String uid = user.uid;
          String feedbackText = _feedbackController.text; // Updated feedback text controller
          String addedUser = user.email ?? 'Anonymous'; // Use user's email or a default value
          DateTime addedDate = DateTime.now();

          await FirebaseFirestore.instance.collection('feedbacks').add({
            'uid': uid,
            'addedDate': addedDate,
            'feedBackText': feedbackText,
            'addedUser': addedUser,
          });

          successSnackbar(context, 'Feedback has been submitted');
        }
      } catch (e) {
        // Show error message if failed to submit
        errorSnackbar(context, "Unable to submit feedback");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        backgroundColor: Color(0xFF4C7766),
        iconTheme: IconThemeData(color: Colors.white.withOpacity(0.7)),
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
                color: Color(0xFF4C7766),
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
                              color: Colors.white.withOpacity(0.7),
                              size: 35,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Send your feedback',
                              style: GoogleFonts.montserrat(
                                color: Colors.white.withOpacity(0.7),
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
                          cursorColor: Colors.white.withOpacity(0.7),
                          style: GoogleFonts.montserrat(
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                            fontSize: 17,
                            letterSpacing: 0.1,
                          ),
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: null, // Allows the field to expand
                          decoration: InputDecoration(
                            
                            fillColor: Color.fromARGB(255, 134, 168, 163),
                            filled: true,
                            contentPadding: EdgeInsets.all(16),
                            label: Text(
                              'Enter your feedback',
                              style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.5)),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelStyle: GoogleFonts.montserrat(
                              color: AppColors.myFadeblue,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Color.fromARGB(255, 134, 168, 163), width: 0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Color.fromARGB(255, 134, 168, 163), width: 0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide(color: Color.fromARGB(255, 134, 168, 163), width: 0),
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
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(15.0),
                            ),

                            child: Center(
                              child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Submit',
                                    style: GoogleFonts.montserrat(
                                      color: Color(0xFF4C7766),
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
                                          color: Color(0xFF4C7766),
                                          strokeWidth: 2,
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
