
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  double _paidStatus = 0;

  final DateTime? _addedDate = DateTime.now();

  final TextEditingController _dateController = TextEditingController();
  bool _isLoading = false;
  
 // function to select the date
Future<void> _selectDate(BuildContext context) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: _billDueDate ?? DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );
  if (pickedDate != null && pickedDate != _billDueDate) {
    setState(() {
      // If the picked date is today, use the current time.
      if (pickedDate.isAtSameMomentAs(DateTime.now().toLocal())) {
        _billDueDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
            DateTime.now().hour, DateTime.now().minute, DateTime.now().second);
      } else {
        // Otherwise, set the time to 12:01 AM
        _billDueDate = pickedDate.add(Duration(minutes: 1));
      }

      _dateController.text = "${pickedDate.toLocal()}".split(' ')[0]; // Display the date only
    });
  }
}




  @override
  void initState() {
    super.initState();
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
                  'Add bill +',
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
                  errorStyle: GoogleFonts.poppins(),
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
                  else if (num.tryParse(value)!<=0){
                    return 'Please enter a valid amount';
      
                  }
                  else if (num.tryParse(value)! >999999){
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
      
              SizedBox(height: 15),

              // title field
              TextFormField(
                cursorColor: Theme.of(context).canvasColor.withOpacity(0.4),
                style: GoogleFonts.poppins(
                  color: Theme.of(context).canvasColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                
                ),
                decoration: InputDecoration(
                  errorStyle: GoogleFonts.poppins(),
                  hintText: 'Title',
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
                    return 'Please enter a title';
                  }
                  _billTitle = value;
                  return null;
                },
              ),

              // Description field
              TextFormField(
                cursorColor: Theme.of(context).canvasColor.withOpacity(0.4),
                style: GoogleFonts.poppins(
                  color: Theme.of(context).canvasColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                
                ),
                decoration: InputDecoration(
                  errorStyle: GoogleFonts.poppins(),
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
                  _billDescription = value;
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
                  errorStyle: GoogleFonts.poppins(),
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
                              successSnackbar(context, "bill has been added");
                              Navigator.of(context).pop();
                            },
                          );
                        }
                      },
                      child: _isLoading
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: SizedBox(
                                  height: 25,
                                  width: 25,
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
