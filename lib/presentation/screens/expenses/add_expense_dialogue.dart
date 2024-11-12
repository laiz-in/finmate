
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/common/widgets/success_snackbar.dart';
import 'package:moneyy/data/models/expenses/user_expenses.dart';
import 'package:moneyy/domain/usecases/expenses/add_expense_usecase.dart';
import 'package:moneyy/service_locator.dart';


class AddSpendingBottomSheet extends StatefulWidget {

    const AddSpendingBottomSheet({super.key});


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
      // If the picked date is today, use the current time.
      if (pickedDate.isAtSameMomentAs(DateTime.now().toLocal())) {
        _spendingDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
            DateTime.now().hour, DateTime.now().minute, DateTime.now().second);
      } else {
        // Otherwise, set the time to 12:01 AM
        _spendingDate = pickedDate.add(Duration(minutes: 1));
      }

      _dateController.text = "${pickedDate.toLocal()}".split(' ')[0]; // Display the date only
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
        // height: (MediaQuery.of(context).size.height)*0.5,
        padding: EdgeInsets.fromLTRB(30, 10, 30, 20),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(topRight: Radius.circular(25),topLeft: Radius.circular(25))
        ),
        child: Form(
          
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              
              SizedBox(height: 8 ,),
      
              Center(
                child: Container(
                  height: 3,
                  width:100 ,
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor.withOpacity(0.3)
                  ),
                ),
              ),
              
              SizedBox(height: 10,),
      
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
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  labelText: '0.00',
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 17,
                    color: Theme.of(context).canvasColor,
                    fontWeight: FontWeight.w400,
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
                  else if (num.tryParse(value)!<=0){
                    return 'Please enter a valid amount';
      
                  }
                  else if (num.tryParse(value)! >999999){
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
      
              // Description field
              TextFormField(
                cursorColor: Theme.of(context).canvasColor.withOpacity(0.4),
                style: GoogleFonts.poppins(
                  color: Theme.of(context).canvasColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                
                ),
                decoration: InputDecoration(
                  hintText: 'Description',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 17,
                    color: Theme.of(context).canvasColor,
                    fontWeight: FontWeight.w400,
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
      
              // Dropdown to select category
              DropdownButtonFormField<String>(
                value: _spendingCategory,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).canvasColor,
                  fontWeight: FontWeight.w400,
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
      
              SizedBox(height: 15),
      
              // Date field
              TextFormField(
                style: GoogleFonts.poppins(
                  color: Theme.of(context).canvasColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
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
              Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: Theme.of(context).canvasColor,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
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
                              successSnackbar(context, "Expense has been added");
                              Navigator.of(context).pop();
                            },
                          );
                        }
                      },
                      child: _isLoading
                          ? Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : Text(
                              'Add +',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
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
