// FILEPATH: /C:/Users/Hp/Desktop/moneyy - Copy/moneyy/lib/presentation/screens/income/update_income.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // IMPORT SCREENUTIL
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/common/widgets/success_snackbar.dart';
import 'package:moneyy/data/models/income/user_income.dart';
import 'package:moneyy/domain/usecases/income/update_income_usecase.dart';
import 'package:moneyy/service_locator.dart';
import 'package:moneyy/styles/themes.dart';

class UpdateIncomeDialog extends StatefulWidget {
  final String uidOfIncome;
  final DateTime initialcreatedAt;
  final double initialAmount;
  final String initialCategory;
  final String initialRemarks;
  final DateTime initialDate;
  final String incomeId;
  final Function(double, String, String, DateTime) onSubmit;

  const UpdateIncomeDialog({
    super.key,
    required this.uidOfIncome,
    required this.initialcreatedAt,
    required this.initialAmount,
    required this.initialCategory,
    required this.initialRemarks,
    required this.initialDate,
    required this.incomeId,
    required this.onSubmit,
  });

  @override
  _UpdateIncomeDialog createState() => _UpdateIncomeDialog();
}

class _UpdateIncomeDialog extends State<UpdateIncomeDialog> {
  final _formKey = GlobalKey<FormState>();
  late double _incomeAmount;
  late String _incomeCategory;
  late String _incomeRemarks;
  late DateTime _incomeDate;
  final TextEditingController _dateController = TextEditingController();
  bool isloading = false;

  final List<String> _categories = [
    'Active',
    'Passive',
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _incomeDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _incomeDate) {
      setState(() {
        _incomeDate = pickedDate;
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _incomeAmount = widget.initialAmount;
    _incomeCategory = widget.initialCategory;
    _incomeRemarks = widget.initialRemarks;
    _incomeDate = widget.initialDate;
    _dateController.text = "${_incomeDate.toLocal()}".split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.fromLTRB(5.w, 20.h, 0.w, 10.h), // USE SCREENUTIL FOR PADDING
      contentPadding: EdgeInsets.fromLTRB(23.w, 10.h, 23.w, 10.h), // USE SCREENUTIL FOR PADDING
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26.r), // USE SCREENUTIL FOR BORDER RADIUS
      ),
      elevation: 15,
      backgroundColor: Theme.of(context).primaryColor,

      // TITLE TEXT
      title: Text(
        'Edit your Income',
        style: GoogleFonts.poppins(
          fontSize: 17.sp, // USE SCREENUTIL FOR FONT SIZE
          color: Theme.of(context).canvasColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(height: 10.h), // USE SCREENUTIL FOR HEIGHT

              // INCOME AMOUNT FIELD
              TextFormField(
                initialValue: _incomeAmount.toString(),
                style: GoogleFonts.poppins(
                  color: Theme.of(context).canvasColor,
                  fontSize: 15.sp, // USE SCREENUTIL FOR FONT SIZE
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
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
                initialValue: _incomeRemarks,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).canvasColor,
                  fontSize: 15.sp, // USE SCREENUTIL FOR FONT SIZE
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
                decoration: InputDecoration(
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
                  fontWeight: FontWeight.w500,
                  fontSize: 15.sp, // USE SCREENUTIL FOR FONT SIZE
                ),
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.r)), // USE SCREENUTIL FOR BORDER RADIUS
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w), // USE SCREENUTIL FOR PADDING
                ),


                dropdownColor: Theme.of(context).primaryColor,
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
                            fontSize: 15.sp, // USE SCREENUTIL FOR FONT SIZE
                            fontWeight: FontWeight.w500,
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
                  fontSize: 15.sp, // USE SCREENUTIL FOR FONT SIZE
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
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

              SizedBox(height: 8.h), // USE SCREENUTIL FOR HEIGHT
            ],
          ),
        ),
      ),

      actions: <Widget>[
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // CANCEL BUTTON
              Expanded(
                child: Container(
                  color: Colors.transparent,
                  child: TextButton(
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp, // USE SCREENUTIL FOR FONT SIZE
                        fontWeight: FontWeight.w500,
                        color: AppColors.myOrange,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),

              // UPDATE BUTTON
              Expanded(
                child: Container(
                  width: 150.w, // USE SCREENUTIL FOR WIDTH
                  height: 50.h, // USE SCREENUTIL FOR HEIGHT
                  color: Colors.transparent,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).canvasColor, // BACKGROUND COLOR
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r), // USE SCREENUTIL FOR BORDER RADIUS
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 28.w), // USE SCREENUTIL FOR PADDING
                    ),
                    child: isloading
                        ? SizedBox(
                            width: 20.w, // USE SCREENUTIL FOR WIDTH
                            height: 20.h, // USE SCREENUTIL FOR HEIGHT
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              'Update',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp, // USE SCREENUTIL FOR FONT SIZE
                                color: Theme.of(context).scaffoldBackgroundColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isloading = true;
                        });
                        final updatedIncome = IncomeModel(
                          uidOfIncome: widget.uidOfIncome,
                          incomeRemarks: _incomeRemarks,
                          incomeCategory: _incomeCategory,
                          incomeAmount: _incomeAmount,
                          incomeDate: _incomeDate,
                          createdAt: widget.initialcreatedAt,
                        );

                        final updateIncomeUseCase = sl<UpdateIncomeUseCase>();

                        final result = await updateIncomeUseCase.call(
                          uidOfIncome: widget.incomeId,
                          updatedIncome: updatedIncome,
                        );

                        result.fold(
                          (failureMessage) {
                            if (mounted) {
                              errorSnackbar(context, failureMessage);
                            }
                            setState(() {
                              isloading = false;
                            });
                          },
                          (successMessage) {
                            if (mounted) {
                              successSnackbar(context, successMessage);
                            }
                            setState(() {
                              isloading = false;
                            });
                            widget.onSubmit(_incomeAmount, _incomeCategory, _incomeRemarks, _incomeDate);
                            Navigator.of(context).pop();
                          },
                        );
                        // CLEAR FORM FIELDS
                        setState(() {
                          _incomeAmount = 0.0;
                          _incomeCategory = 'Active';
                          _incomeRemarks = '';
                          _incomeDate = DateTime.now();
                          _dateController.text = "${_incomeDate.toLocal()}".split(' ')[0];
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}