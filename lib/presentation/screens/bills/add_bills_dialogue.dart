import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/common/widgets/success_snackbar.dart';
import 'package:moneyy/data/models/bills/user_bills.dart';
import 'package:moneyy/domain/usecases/bills/add_bill_usecase.dart';
import 'package:moneyy/service_locator.dart';

class AddBillsBottomSheet extends StatefulWidget {
  const AddBillsBottomSheet({super.key});

  @override
  _AddBillsBottomSheetState createState() => _AddBillsBottomSheetState();
}

class _AddBillsBottomSheetState extends State<AddBillsBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  double _billAmount = 0.0;
  String _billTitle = '';
  String _billDescription = '';
  DateTime? _billDueDate = DateTime.now();

  final DateTime? _addedDate = DateTime.now();

  final TextEditingController _dateController = TextEditingController();
  bool _isLoading = false;

  // FUNCTION TO SELECT THE DATE
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _billDueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _billDueDate) {
      setState(() {
        // IF THE PICKED DATE IS TODAY, USE THE CURRENT TIME
        if (pickedDate.isAtSameMomentAs(DateTime.now().toLocal())) {
          _billDueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            DateTime.now().hour,
            DateTime.now().minute,
            DateTime.now().second,
          );
        } else {
          // OTHERWISE, SET THE TIME TO 12:01 AM
          _billDueDate = pickedDate.add(const Duration(minutes: 1));
        }

        _dateController.text = DateFormat('dd-MM-yyyy').format(_billDueDate!);
      });
    }
  }

 //INIT FUNCTION
  @override
  void initState() {
    super.initState();
    if (_billDueDate != null) {
      _dateController.text = DateFormat('dd-MM-yyyy').format(_billDueDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(30.w, 10.h, 30.w, 20.h), // PADDING
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25.r), // RADIUS
          topLeft: Radius.circular(25.r), // RADIUS
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 8.h), // SPACING

            Center(
              child: Container(
                height: 3.h,
                width: 100.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor.withOpacity(0.3),
                ),
              ),
            ),

            SizedBox(height: 10.h), // SPACING

            // TITLE ADD +
            Padding(
              padding: EdgeInsets.fromLTRB(5.w, 8.h, 5.w, 20.h), // PADDING
              child: Text(
                'Add bill +',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp, // FONT SIZE
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
                fontSize: 14.sp, // FONT SIZE
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                errorStyle: GoogleFonts.poppins(),
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
                  borderRadius: BorderRadius.all(Radius.circular(12.r)), // RADIUS
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
                  _billAmount = double.parse(value);
                } catch (e) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),

            SizedBox(height: 15.h), // SPACING

            // TITLE FIELD
            TextFormField(
              cursorColor: Theme.of(context).canvasColor.withOpacity(0.4),
              style: GoogleFonts.poppins(
                color: Theme.of(context).canvasColor,
                fontSize: 14.sp, // FONT SIZE
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                errorStyle: GoogleFonts.poppins(),
                hintText: 'Title',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14.sp, // FONT SIZE
                  color: Theme.of(context).canvasColor,
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.r)), // RADIUS
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

            // DESCRIPTION FIELD
            TextFormField(
              cursorColor: Theme.of(context).canvasColor.withOpacity(0.4),
              style: GoogleFonts.poppins(
                color: Theme.of(context).canvasColor,
                fontSize: 14.sp, // FONT SIZE
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                errorStyle: GoogleFonts.poppins(),
                hintText: 'Description',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14.sp, // FONT SIZE
                  color: Theme.of(context).canvasColor,
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.r)), // RADIUS
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

            // DATE FIELD
            TextFormField(
              style: GoogleFonts.poppins(
                color: Theme.of(context).canvasColor,
                fontSize: 14.sp, // FONT SIZE
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                errorStyle: GoogleFonts.poppins(),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.r)), // RADIUS
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

            SizedBox(height: 20.h), // SPACING

            // ADD BUTTON
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.r)), // RADIUS
                color: Theme.of(context).canvasColor,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r), // RADIUS
                        ),
                        padding: EdgeInsets.fromLTRB(8.w,12.h,8.w,12.h), // PADDING8
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });

                          var result = await sl<AddBillUsecase>().call(
                            params: BillModel(
                              uidOfBill: "",
                              billAmount: _billAmount,
                              billDueDate: _billDueDate!,
                              billDescription: _billDescription,
                              billTitle: _billTitle,
                              addedDate: _addedDate!,
                              paidStatus: 0,
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
                              successSnackbar(context, "Bill has been added");
                              Navigator.of(context).pop();
                            },
                          );
                        }
                      },
                      child: _isLoading
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.all(3.w), // PADDING
                                child: SizedBox(
                                  height: 25.h, // HEIGHT
                                  width: 25.w, // WIDTH
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    strokeWidth: 2.w, // STROKE WIDTH
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              'Add +',
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp, // FONT SIZE
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