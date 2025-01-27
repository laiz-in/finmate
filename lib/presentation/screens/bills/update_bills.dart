import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/common/widgets/success_snackbar.dart';
import 'package:moneyy/data/models/bills/user_bills.dart';
import 'package:moneyy/domain/usecases/bills/update_bill_usecase.dart';
import 'package:moneyy/service_locator.dart';
import 'package:moneyy/styles/themes.dart';

class UpdateBillDialog extends StatefulWidget {
  final String uidOfBill;
  final DateTime initialaddedDate;
  final double initialBillAmount;
  final String initialBillTitle;
  final String initialBillDescription;
  final double initialBillpaidStatus;
  final DateTime initialBillDueDate;
  final String transactionId;
  final Function(double, String, String, DateTime) onSubmit;

  const UpdateBillDialog({
    super.key,
    required this.uidOfBill,
    required this.initialaddedDate,
    required this.initialBillAmount,
    required this.initialBillTitle,
    required this.initialBillDescription,
    required this.initialBillpaidStatus,
    required this.initialBillDueDate,
    required this.transactionId,
    required this.onSubmit,
  });

  @override
  _UpdateBillDialog createState() => _UpdateBillDialog();
}

class _UpdateBillDialog extends State<UpdateBillDialog> {
  final _formKey = GlobalKey<FormState>();
  late double _billAmount;
  late String _billDescription;
  late String _billTitle;
  late DateTime _addedDate;
  late DateTime _billDueDate;
  final TextEditingController _dateController = TextEditingController();
  bool isloading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _billDueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _addedDate) {
      setState(() {
        _billDueDate = pickedDate;
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _billAmount = widget.initialBillAmount;
    _billTitle = widget.initialBillTitle;
    _billDescription = widget.initialBillDescription;
    _billDueDate = widget.initialBillDueDate;
    _addedDate = widget.initialaddedDate;
    _dateController.text = "${_addedDate.toLocal()}".split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.fromLTRB(5.w, 20.h, 0.w, 10.h), // PADDING
      contentPadding: EdgeInsets.fromLTRB(23.w, 10.h, 23.w, 10.h), // PADDING
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26.0.r), // RADIUS
      ),
      elevation: 15,
      backgroundColor: Theme.of(context).primaryColor,

      // TITLE TEXT
      title: Text(
        'Edit your bill',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 10.h), // SPACING

              //  BILL AMOUNT FIELD
              TextFormField(
                initialValue: _billAmount.toString(),
                style: GoogleFonts.poppins(
                  color: Theme.of(context).canvasColor,
                  fontSize: 15.sp, // FONT SIZE
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  labelText: '0.00',
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 15.sp, // FONT SIZE
                    color: Theme.of(context).canvasColor,
                    fontWeight: FontWeight.w500,
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
                  }
                  try {
                    _billAmount = double.parse(value);
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15.h), // SPACING

              // BILL TITLE FIELD
              TextFormField(
                initialValue: _billTitle,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).canvasColor,
                  fontSize: 15.sp, // FONT SIZE
                  fontWeight: FontWeight.w500,
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
                    return 'Please enter a title';
                  }
                  _billTitle = value;
                  return null;
                },
              ),
              SizedBox(height: 15.h), // SPACING

            // BILL DESCRIPTION FIELD
              TextFormField(
                initialValue: _billDescription,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).canvasColor,
                  fontSize: 15.sp, // FONT SIZE
                  fontWeight: FontWeight.w500,
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
                  _billDescription = value;
                  return null;
                },
              ),
              SizedBox(height: 15.h), // SPACING

            // DUE DATE HEADING
            Row(
              children: [
                SizedBox(width: 3.w,),
                Text("Bill due date", style: GoogleFonts.poppins(
                  fontSize: 12.sp, // FONT SIZE
                  color: Theme.of(context).canvasColor,
                  fontWeight: FontWeight.w400,
                ),),
              ],
            ),
            SizedBox(height: 8.h), // SPACING

            // DATE FIELD
            TextFormField(
              style: GoogleFonts.poppins(
                color: Theme.of(context).canvasColor,
                fontSize: 15.sp, // FONT SIZE
                fontWeight: FontWeight.w500,
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
                        final updatedBill = BillModel(
                          uidOfBill: widget.uidOfBill,
                          billAmount: _billAmount,
                          billDescription: _billDescription,
                          billTitle: _billTitle,
                          billDueDate: _billDueDate,
                          paidStatus: widget.initialBillpaidStatus,
                          addedDate: widget.initialaddedDate,
                        );

                        final updateBillUseCase = sl<UpdateBillUsecase>();

                        final result = await updateBillUseCase.call(
                          uidOfBill: widget.transactionId,
                          updatedBill: updatedBill,
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
                            widget.onSubmit(_billAmount, _billTitle, _billDescription, _billDueDate);
                            Navigator.of(context).pop();
                          },
                        );
                        // CLEAR FORM FIELDS
                        setState(() {
                          _billAmount = 0.0;
                          _billTitle = '';
                          _billDescription = '';
                          _billDueDate = DateTime.now();
                          _dateController.text = "${_billDueDate.toLocal()}".split(' ')[0];
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