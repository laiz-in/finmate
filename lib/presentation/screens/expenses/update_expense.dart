import 'package:flutter/material.dart';
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


  const UpdateSpendingDialog({super.key,
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

      insetPadding: EdgeInsets.fromLTRB(5,20,0,10),
      contentPadding: EdgeInsets.fromLTRB(23,10,23,10),
      
      shape: RoundedRectangleBorder(
        
        borderRadius: BorderRadius.circular(26.0),
      ),
      elevation: 15,
      backgroundColor: Theme.of(context).primaryColor,

      // Title text
      title: Text(
        'Edit your expense',
        style: GoogleFonts.poppins(
          fontSize: 17,
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
              SizedBox(height: 10),

              // Amount field
              TextFormField(
                initialValue: _spendingAmount.toString(),
                style: GoogleFonts.poppins(
                  color: Theme.of(context).canvasColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  labelText: '0.00',
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Theme.of(context).canvasColor,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                  
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  try {
                    _spendingAmount = double.parse(value);
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Description field
              TextFormField(
                initialValue: _spendingDescription,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).canvasColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none
                ),
                decoration: InputDecoration(
                  
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  _spendingDescription = value;
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Dropdown to select category
              DropdownButtonFormField<String>(
                
                value: _spendingCategory,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).canvasColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 15,
                    color:Theme.of(context).canvasColor,
                    fontWeight: FontWeight.w500,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                ),
                dropdownColor: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    
                    value: category,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12))
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                        child: Text(
                          category,
                          style: GoogleFonts.poppins(
                            color: Theme.of(context).canvasColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
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
              SizedBox(height: 15),

              // Date field
              TextFormField(
                style: GoogleFonts.poppins(
                  color: Theme.of(context).canvasColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  
                  filled: true,
                  fillColor:Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
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

            SizedBox(height: 8,)
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

            
            
            // Cancel button
            Expanded(
              child: Container(
                color: Colors.transparent,
                child: TextButton(
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
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


            // Update button
            Expanded(
              child: Container(
                width: 150,height: 50,
                color: Colors.transparent,
                child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:Theme.of(context).canvasColor, // Background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0), // Set the border radius
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 28.0), // Optional padding
                ),
                child:isloading
                                      ? SizedBox(
                                        width: 20,height: 20,
                                        child: Center(
                                            child:CircularProgressIndicator(
                                              color: Theme.of(context).scaffoldBackgroundColor,strokeWidth: 2,
                                            )
                                          ),
                                      )
                                      : Center(
                                          child: Text(
                                            'Update',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
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

                    final result = await updateExpensesUseCase.call(uidOfTransaction: widget.transactionId,updatedExpense: updatedExpense,);

                    result.fold(
                      (failureMessage) {
                        if(mounted){
                        errorSnackbar(context, failureMessage);}
                        setState(() {
                          isloading =false;
                        });
                        
                      },
                      (successMessage) {
                        if(mounted){
                        successSnackbar(context, successMessage);}
                        setState(() {
                          isloading =false;
                        });
                        widget.onSubmit(_spendingAmount, _spendingCategory, _spendingDescription, _spendingDate);
                        Navigator.of(context).pop();
                      },
                    );
                      // Clear form fields
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
            ]
          ),


        )
      ],
    );
  }
}
