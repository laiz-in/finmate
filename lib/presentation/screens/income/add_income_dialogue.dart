// FILEPATH: /C:/Users/Hp/Desktop/moneyy - Copy/moneyy/lib/presentation/screens/income/add_income_dialogue.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // IMPORT SCREENUTIL
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/common/widgets/success_snackbar.dart';
import 'package:moneyy/data/models/income/user_income.dart';
import 'package:moneyy/domain/usecases/income/add_income_usecase.dart';
import 'package:moneyy/service_locator.dart';

class AddIncomeBottomSheet extends StatefulWidget {
  const AddIncomeBottomSheet({super.key});

  @override
  _AddIncomeBottomSheetState createState() => _AddIncomeBottomSheetState();
}

class _AddIncomeBottomSheetState extends State<AddIncomeBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  double _incomeAmount = 0.0;
  String _incomeCategory = 'Active';
  String _incomeRemarks = '';
  DateTime? _incomeDate = DateTime.now();
  final DateTime? _createdAt = DateTime.now();

  final TextEditingController _dateController = TextEditingController();
  bool _isLoading = false;

  final List<String> _categories = [
    'Active',
    'Passive'
  ];

  // FUNCTION TO SELECT THE DATE
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _incomeDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _incomeDate) {
      setState(() {
        // IF THE PICKED DATE IS TODAY, USE THE CURRENT TIME.
        if (pickedDate.isAtSameMomentAs(DateTime.now().toLocal())) {
          _incomeDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
              DateTime.now().hour, DateTime.now().minute, DateTime.now().second);
        } else {
          // OTHERWISE, SET THE TIME TO 12:01 AM
          _incomeDate = pickedDate.add(Duration(minutes: 1));
        }

        _dateController.text = DateFormat('dd-MM-yyyy').format(_incomeDate!);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (_incomeDate != null) {
      _dateController.text = DateFormat('dd-MM-yyyy').format(_incomeDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(30.w, 10.h, 30.w, 20.h), // USE SCREENUTIL FOR PADDING
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25.r), // USE SCREENUTIL FOR BORDER RADIUS
          topLeft: Radius.circular(25.r), // USE SCREENUTIL FOR BORDER RADIUS
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 8.h), // USE SCREENUTIL FOR HEIGHT

            Center(
              child: Container(
                height: 3.h, // USE SCREENUTIL FOR HEIGHT
                width: 100.w, // USE SCREENUTIL FOR WIDTH
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor.withOpacity(0.3),
                ),
              ),
            ),

            SizedBox(height: 10.h), // USE SCREENUTIL FOR HEIGHT

            // TITLE ADD +
            Padding(
              padding: EdgeInsets.fromLTRB(5.w, 8.h, 5.w, 20.h), // USE SCREENUTIL FOR PADDING
              child: Text(
                'Add Income +',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp, // USE SCREENUTIL FOR FONT SIZE
                  color: Theme.of(context).canvasColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // AMOUNT FIELD
            TextFormField(
              cursorColor: Theme.of(context).canvasColor.withOpacity(0.4),
              style: GoogleFonts.poppins(
                color: Theme.of(context).canvasColor,
                fontSize: 17.sp, // USE SCREENUTIL FOR FONT SIZE
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                errorStyle: GoogleFonts.poppins(),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: '0.00',
                labelStyle: GoogleFonts.poppins(
                  fontSize: 14.sp, // USE SCREENUTIL FOR FONT SIZE
                  color: Theme.of(context).canvasColor,
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.r)), // USE SCREENUTIL FOR BORDER RADIUS
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w), // USE SCREENUTIL FOR PADDING
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                } else if (num.tryParse(value)! <= 0) {
                  return 'Please enter a valid amount';
                } else if (num.tryParse(value)! > 999999) {
                  return 'Maximum expense can be added is 999999';
                }
                try {
                  _incomeAmount = double.parse(value);
                } catch (e) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),

            SizedBox(height: 15.h), // USE SCREENUTIL FOR HEIGHT

            // DESCRIPTION FIELD
            TextFormField(
              cursorColor: Theme.of(context).canvasColor.withOpacity(0.4),
              style: GoogleFonts.poppins(
                color: Theme.of(context).canvasColor,
                fontSize: 14.sp, // USE SCREENUTIL FOR FONT SIZE
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                errorStyle: GoogleFonts.poppins(),
                hintText: 'Remarks',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14.sp, // USE SCREENUTIL FOR FONT SIZE
                  color: Theme.of(context).canvasColor,
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.r)), // USE SCREENUTIL FOR BORDER RADIUS
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w), // USE SCREENUTIL FOR PADDING
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                _incomeRemarks = value;
                return null;
              },
            ),

            SizedBox(height: 15.h), // USE SCREENUTIL FOR HEIGHT

            // DROPDOWN TO SELECT CATEGORY
            DropdownButtonFormField<String>(
              value: _incomeCategory,
              style: GoogleFonts.poppins(
                color: Theme.of(context).canvasColor,
                fontWeight: FontWeight.w400,
                fontSize: 14.sp, // USE SCREENUTIL FOR FONT SIZE
              ),
              decoration: InputDecoration(
                errorStyle: GoogleFonts.poppins(),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.r)), // USE SCREENUTIL FOR BORDER RADIUS
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w), // USE SCREENUTIL FOR PADDING
              ),
              dropdownColor: Theme.of(context).cardColor,
              borderRadius: BorderRadius.all(Radius.circular(15.r)), // USE SCREENUTIL FOR BORDER RADIUS
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 0.w), // USE SCREENUTIL FOR PADDING
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12.r)), // USE SCREENUTIL FOR BORDER RADIUS
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 0.w), // USE SCREENUTIL FOR PADDING
                      child: Text(
                        category,
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).canvasColor,
                          fontSize: 14.sp, // USE SCREENUTIL FOR FONT SIZE
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _incomeCategory = value!;
                });
              },
              isExpanded: true,
            ),

            SizedBox(height: 15.h), // USE SCREENUTIL FOR HEIGHT

            // DATE FIELD
            TextFormField(
              style: GoogleFonts.poppins(
                color: Theme.of(context).canvasColor,
                fontSize: 14.sp, // USE SCREENUTIL FOR FONT SIZE
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                errorStyle: GoogleFonts.poppins(),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.r)), // USE SCREENUTIL FOR BORDER RADIUS
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w), // USE SCREENUTIL FOR PADDING
              ),
              controller: _dateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a date';
                }
                return null;
              },
            ),

            SizedBox(height: 20.h), // USE SCREENUTIL FOR HEIGHT

            // ADD BUTTON
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12.r)), // USE SCREENUTIL FOR BORDER RADIUS
                color: Theme.of(context).canvasColor,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r), // USE SCREENUTIL FOR BORDER RADIUS
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.h), // USE SCREENUTIL FOR PADDING
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });

                          var result = await sl<AddIncomeUseCase>().call(
                            params: IncomeModel(
                              uidOfIncome: "",
                              incomeAmount: _incomeAmount,
                              incomeCategory: _incomeCategory,
                              incomeDate: _incomeDate!,
                              incomeRemarks: _incomeRemarks,
                              createdAt: _createdAt!,
                            ),
                          );

                          result.fold(
                            (l) {
                              setState(() {
                                _isLoading = false;
                              });
                              errorSnackbar(context, l.toString());
                            },
                            (r) {
                              setState(() {
                                _isLoading = false;
                              });
                              successSnackbar(context, "Income has been added");
                              Navigator.of(context).pop();
                            },
                          );
                        }
                      },
                      child: _isLoading
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.all(3.h), // USE SCREENUTIL FOR PADDING
                                child: SizedBox(
                                  height: 25.h, // USE SCREENUTIL FOR HEIGHT
                                  width: 25.w, // USE SCREENUTIL FOR WIDTH
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              'Add +',
                              style: GoogleFonts.poppins(
                                fontSize: 20.sp, // USE SCREENUTIL FOR FONT SIZE
                                color: Theme.of(context).scaffoldBackgroundColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}