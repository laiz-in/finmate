import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/common/widgets/success_snackbar.dart';
import 'package:moneyy/domain/usecases/settings/name_reset.dart';
import 'package:moneyy/service_locator.dart';

class ResetProfileName extends StatefulWidget {
  const ResetProfileName({super.key});

  @override
  State<ResetProfileName> createState() => _ResetProfileNameState();
}

class _ResetProfileNameState extends State<ResetProfileName> {
  final TextEditingController _firstnamecontroller = TextEditingController();
  final TextEditingController _lastnamecontroller = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // RESET MONTHLY LIMIT LOGIC
  void _resetProfileName() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      String firstName = _firstnamecontroller.text.trim();
      String lastName = _lastnamecontroller.text.trim();
      final resetProfileName = sl<ResetNameUseCase>();
      final result = await resetProfileName.call(firstName:firstName, lastName: lastName);

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
            successSnackbar(context, 'Profile name has been updated');
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

                      // MONTHLY RESET HEADING
                      Padding(
                        padding: EdgeInsets.all(20.w), // PADDING
                        child: Row(
                          children: [
                            Icon(
                              Symbols.person_edit,
                              color: Theme.of(context).canvasColor,
                              size: 35.sp, // ICON SIZE
                            ),
                            SizedBox(width: 10.w), // SPACING
                            Text(
                              'Change profile name',
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).canvasColor,
                                fontSize: 20.sp, // FONT SIZE
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 15.h), // SPACING

                      // FIRST NAME FIELD
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0), // PADDING
                        child: TextFormField(
                          controller: _firstnamecontroller,
                          cursorColor: Theme.of(context).canvasColor.withOpacity(0.7),
                          style: GoogleFonts.poppins(
                            color: Theme.of(context).canvasColor,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none,
                            fontSize: 15.sp, // FONT SIZE
                          ),
                          decoration: InputDecoration(
                            fillColor: Theme.of(context).cardColor,
                            filled: true,
                            contentPadding: EdgeInsets.all(16.w), // PADDING
                            
                            label: Text(
                              'First name',
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
                              return 'Please enter a name';
                            }
                            
                            return null;
                          },
                        ),
                      ),


                      // LAST NAME FIELD
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0), // PADDING
                        child: TextFormField(
                          controller: _lastnamecontroller,
                          cursorColor: Theme.of(context).canvasColor.withOpacity(0.7),
                          style: GoogleFonts.poppins(
                            color: Theme.of(context).canvasColor,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none,
                            fontSize: 15.sp, // FONT SIZE
                          ),
                          decoration: InputDecoration(
                            fillColor: Theme.of(context).cardColor,
                            filled: true,
                            contentPadding: EdgeInsets.all(16.w), // PADDING
                            
                            label: Text(
                              'Last name',
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
                            
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 15.h), // SPACING

                      // SEND BUTTON
                      InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: _resetProfileName,
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
                                      fontSize: 23.sp, // FONT SIZE
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