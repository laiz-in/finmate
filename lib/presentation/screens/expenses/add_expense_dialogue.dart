
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/common/widgets/success_snackbar.dart';
import 'package:moneyy/data/models/expenses/user_expenses.dart';
import 'package:moneyy/domain/usecases/expenses/add_expense_usecase.dart';
import 'package:moneyy/service_locator.dart';


class AddSpendingBottomSheet extends StatefulWidget {
  @override
  _AddSpendingBottomSheetState createState() => _AddSpendingBottomSheetState();
}

class _AddSpendingBottomSheetState extends State<AddSpendingBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  double _spendingAmount = 0.0;
  String _spendingCategory = 'Groceries';
  String _spendingDescription = '';
  DateTime? _spendingDate = DateTime.now();
  final DateTime? _createdAt = DateTime.now();

  final TextEditingController _dateController = TextEditingController();
  bool _isLoading = false;
  




  final List<String> _categories = [
    'Groceries',
    'Stationary',
    'Food',
    'Entertainment',
    'Transport',
    'Bills',
    'Other'
  ];

 // function to select the date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _spendingDate ?? DateTime.now(),
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
    _dateController.text = "${_spendingDate?.toLocal()}".split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
      decoration: BoxDecoration(
        
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(
        Radius.circular(20)
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            // Title add +
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 8, 5, 20),
              child: Text(
                'Add Expense +',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Theme.of(context).canvasColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Amount field
            TextFormField(
              cursorColor: Theme.of(context).canvasColor.withOpacity(0.4),
              style: GoogleFonts.poppins(
                color: Theme.of(context).canvasColor,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: '0.00',
                labelStyle: GoogleFonts.poppins(
                  fontSize: 17,
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
                else if (num.tryParse(value!)! >999999){
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

            SizedBox(height: 15),

            // Dropdown to select category
            DropdownButtonFormField<String>(
              value: _spendingCategory,
              style: GoogleFonts.poppins(
                color: Theme.of(context).canvasColor,
                fontWeight: FontWeight.w500,
                fontSize: 17,
              ),
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
              ),
              dropdownColor: Theme.of(context).cardColor,
              borderRadius: BorderRadius.all(Radius.circular(15)),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                      child: Text(
                        category,
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).canvasColor,
                          fontSize: 17,
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

            // Description field
            TextFormField(
              cursorColor: Theme.of(context).canvasColor.withOpacity(0.4),
              style: GoogleFonts.montserrat(
                color: Theme.of(context).canvasColor,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              
              ),
              decoration: InputDecoration(
                hintText: 'Description',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 17,
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                _spendingDescription = value;
                return null;
              },
            ),

            SizedBox(height: 15),

            // Date field
            TextFormField(
              style: GoogleFonts.poppins(
                color: Theme.of(context).canvasColor,
                fontSize: 17,
                fontWeight: FontWeight.w500,
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
            
            SizedBox(height: 20),
            
            // Add button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
      
                TextButton(
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 158, 88, 87),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
      
                SizedBox(width: 15,),
      
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).canvasColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 30.0),
                  ),
                  child: _isLoading
                      ?Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0,right: 16,top:3,bottom:3),
                          child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Center(  // Center the CircularProgressIndicator
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                        ),
                      )
                      : Text(
                          'Add +',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),


                  
                  onPressed: () async {
                    if (_formKey.currentState!.validate())
                    {
                      // set the state
                      setState(() {
                        _isLoading = true;
                      });
                      
                      var result = await sl<AddExpensesUseCase>().call(
                          params: ExpensesModel(
                            uidOfTransaction: "",
                            spendingAmount: _spendingAmount,
                            spendingCategory: _spendingCategory,
                            spendingDate: _spendingDate!,
                            spendingDescription: _spendingDescription,
                            createdAt: _createdAt!,
                          ),
                        );

                      result.fold(
                          //ERROR
                          (l) {
                            setState(() {
                              _isLoading = false; // Hide animation on error
                            });
                            errorSnackbar(context, l.toString());
                          },

                          // SUCCESS
                          (r) {
                            setState(() {
                              _isLoading = false; // Hide animation on success
                            });
                            successSnackbar(context, "Expense added succesfully");
                            Navigator.of(context).pop();
                          },
                        );
                    }
                  }
                ),
      
              ],
            ),
          ],
        ),
      ),
    );
  }
}
