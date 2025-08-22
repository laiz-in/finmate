import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/common/widgets/success_snackbar.dart';
import 'package:moneyy/data/models/expenses/user_expenses.dart';
import 'package:moneyy/domain/usecases/expenses/update_expense_usecase.dart';
import 'package:moneyy/service_locator.dart';
import 'package:moneyy/styles/themes.dart';

class UpdateSpendingDialog extends StatefulWidget {
  final String uidOfTransaction;
  final DateTime initialcreatedAt;
  final double initialAmount;
  final String initialCategory;
  final String initialDescription;
  final DateTime initialDate;
  final String transactionId;
  final Function(double, String, String, DateTime) onSubmit;

  const UpdateSpendingDialog({
    super.key,
    required this.uidOfTransaction,
    required this.initialcreatedAt,
    required this.initialAmount,
    required this.initialCategory,
    required this.initialDescription,
    required this.initialDate,
    required this.transactionId,
    required this.onSubmit,
  });

  @override
  _UpdateSpendingDialog createState() => _UpdateSpendingDialog();
}

class _UpdateSpendingDialog extends State<UpdateSpendingDialog> {
  final _formKey = GlobalKey<FormState>();
  late double _spendingAmount;
  late String _spendingCategory;
  late String _spendingDescription;
  late DateTime _spendingDate;
  final TextEditingController _dateController = TextEditingController();
  bool isloading = false;

  final List<String> _categories = [
    'Groceries',
    'Stationary',
    'Food',
    'Entertainment',
    'Transport',
    'Bills',
    'Other'
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _spendingDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _spendingDate) {
      setState(() {
        _spendingDate = pickedDate;
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _spendingAmount = widget.initialAmount;
    _spendingCategory = widget.initialCategory;
    _spendingDescription = widget.initialDescription;
    _spendingDate = widget.initialDate;
    _dateController.text = "${_spendingDate.toLocal()}".split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.fromLTRB(10.w, 20.h, 10.w, 10.h), // PADDING
      contentPadding: EdgeInsets.fromLTRB(23.w, 10.h, 23.w, 10.h), // PADDING
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26.0.r), // RADIUS
      ),
      elevation: 15,
      backgroundColor: Theme.of(context).primaryColor,

      // TITLE TEXT
      title: Text(
        'Edit your expense',
        style: GoogleFonts.poppins(
          fontSize: 17.sp, // FONT SIZE
          color: Theme.of(context).canvasColor,
          fontWeight: FontWeight.w500,
        ),
      ),

      // FORM CONTENT
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(height: 10.h), // SPACING

              // AMOUNT FIELD
              TextFormField(
                cursorColor: Theme.of(context).canvasColor.withOpacity(0.4),

                initialValue: _spendingAmount.toString(),
                style: GoogleFonts.poppins(
                  color: Theme.of(context).canvasColor,
                  fontSize: 14.sp, // FONT SIZE
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  labelText: '0.00',
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 14.sp, // FONT SIZE
                    color: Theme.of(context).canvasColor,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0.r)), // RADIUS
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w), // PADDING
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
                  _spendingAmount = double.parse(value);
                } catch (e) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              ),
              SizedBox(height: 15.h), // SPACING

              // DESCRIPTION FIELD
              TextFormField(
                cursorColor: Theme.of(context).canvasColor.withOpacity(0.4),

                initialValue: _spendingDescription,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).canvasColor,
                  fontSize: 14.sp, // FONT SIZE
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0.r)), // RADIUS
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w), // PADDING
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  _spendingDescription = value;
                  return null;
                },
              ),
              SizedBox(height: 15.h), // SPACING

              // DROPDOWN TO SELECT CATEGORY
              DropdownButtonFormField<String>(
                value: _spendingCategory,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).canvasColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 15.sp, // FONT SIZE
                ),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 14.sp, // FONT SIZE
                    color: Theme.of(context).canvasColor,
                    fontWeight: FontWeight.w400,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0.r)), // RADIUS
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w), // PADDING
                ),
                dropdownColor: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(15.r)), // RADIUS
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 0.w), // PADDING
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12.r)), // RADIUS
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 0.w), // PADDING
                        child: Text(
                          category,
                          style: GoogleFonts.poppins(
                            color: Theme.of(context).canvasColor,
                            fontSize: 14.sp, // FONT SIZE
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _spendingCategory = value!;
                  });
                },
                isExpanded: true,
              ),
              SizedBox(height: 15.h), // SPACING

              // DATE FIELD
              TextFormField(
                style: GoogleFonts.poppins(
                  color: Theme.of(context).canvasColor,
                  fontSize: 14.sp, // FONT SIZE
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0.r)), // RADIUS
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w), // PADDING
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
              SizedBox(height: 8.h), // SPACING
            ],
          ),
        ),
      ),

      // ACTION BUTTONS
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
                        fontSize: 15.sp, // FONT SIZE
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
                  width: 150.w, // WIDTH
                  height: 50.h, // HEIGHT
                  color: Colors.transparent,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).canvasColor, // BACKGROUND COLOR
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0.r), // RADIUS
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 28.w), // PADDING
                    ),
                    child: isloading
                        ? SizedBox(
                            width: 20.w, // WIDTH
                            height: 20.h, // HEIGHT
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                strokeWidth: 2.w, // STROKE WIDTH
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              'Update',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp, // FONT SIZE
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
                        final updatedExpense = ExpensesModel(
                          uidOfTransaction: widget.uidOfTransaction,
                          spendingDescription: _spendingDescription,
                          spendingCategory: _spendingCategory,
                          spendingAmount: _spendingAmount,
                          spendingDate: _spendingDate,
                          createdAt: widget.initialcreatedAt,
                        );

                        final updateExpensesUseCase = sl<UpdateExpensesUseCase>();

                        final result = await updateExpensesUseCase.call(
                          uidOfTransaction: widget.transactionId,
                          updatedExpense: updatedExpense,
                        );
                        
                        if(mounted){
                          setState(() {
                              isloading = false;
                            });
                        }
                        result.fold(
                          (failureMessage) {
                            if (mounted) {
                              errorSnackbar(context, failureMessage);
                            }
                            
                          },
                          (successMessage) {
                            if (mounted) {
                              successSnackbar(context, successMessage);
                            }

                            widget.onSubmit(_spendingAmount, _spendingCategory, _spendingDescription, _spendingDate);
                            Navigator.of(context).pop();
                          },
                        );
                        // CLEAR FORM FIELDS
                        setState(() {
                          _spendingAmount = 0.0;
                          _spendingCategory = 'Groceries';
                          _spendingDescription = '';
                          _spendingDate = DateTime.now();
                          _dateController.text = "${_spendingDate.toLocal()}".split(' ')[0];
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