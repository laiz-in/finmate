import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:moneyy/domain/entities/income/income.dart';
import 'package:moneyy/presentation/screens/expenses/delete_expense_button.dart';
import 'package:moneyy/presentation/screens/income/update_income.dart';


class IncomeCard extends StatefulWidget {
  final IncomeEntity transaction;
  final Function onUpdate; // Callback for update
  final Function onDelete; // Callback for delete

  const IncomeCard({
    super.key,
    required this.transaction,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  IncomeCardState createState() => IncomeCardState();
}

class IncomeCardState extends State<IncomeCard> {
  bool _expanded = false;

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  String timeAgo(DateTime date) {
    final DateFormat formatter = DateFormat('d MMMM y \'at\' h:mm a');
    return formatter.format(date);
  }

IconData getIconForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'active':
      return Symbols.work; // Active category icon
    case 'passive':
      return Symbols.heart_check; // Passive category icon
    default:
      return Symbols.add_a_photo; // Default icon to be returned
  }
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
        padding: const EdgeInsets.fromLTRB(15, 0, 10, 0.0),
      
        decoration: BoxDecoration(
          boxShadow: [
      BoxShadow(
        color: const Color.fromARGB(255, 65, 64, 64).withOpacity(0.13), // Shadow color
        offset: const Offset(0, 4), // Horizontal and vertical offset
        blurRadius: 12.0, // Blur radius
        spreadRadius: 3.0, // Spread radius
      ),
    ],
          color: Theme.of(context).hintColor,
          borderRadius: BorderRadius.circular(20.0),
        ),

        child: Column(
          children: [

            ListTile(
              
              splashColor: Colors.transparent,

              hoverColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              onTap: _toggleExpanded,

              leading: Column(
                children: [
                  Icon(
                    Symbols.south_west,
                    color: Colors.green,
                    size: 25,
                  ),
                  Icon(
                    getIconForCategory(widget.transaction.incomeCategory),
                    size: 25,
                    color: Colors.green.shade400,

                  ),
                ],
              ),

              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    overflow:TextOverflow.ellipsis,
                    widget.transaction.incomeAmount.toStringAsFixed(2),
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).canvasColor,
                    ),
                  ),
                GestureDetector(
                  onTap: _toggleExpanded,
                  child: _expanded
                      ? Transform.rotate(
                          angle: 1.5708, // Rotate 90 degrees
                          child: Icon(
                            Icons.arrow_forward_ios_sharp,
                            size: 15,
                            color: Theme.of(context).canvasColor.withOpacity(0.7),
                          ),
                        )
                      : Icon(
                          Icons.arrow_forward_ios_sharp,
                          size: 15,
                          color: Theme.of(context).canvasColor.withOpacity(0.7),
                        ),
                ),
                ],
              ),
              
              subtitle: Column(
              
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: Theme.of(context).canvasColor.withOpacity(0.1)),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        maxLines: 3,
                        overflow:TextOverflow.ellipsis,
                        widget.transaction.incomeRemarks,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).canvasColor.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 3,),
                      Text(
                        overflow: TextOverflow.ellipsis,
                        timeAgo(widget.transaction.incomeDate),
                        style: GoogleFonts.poppins(
                        
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).canvasColor.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),


            // EXPANSION CONTIANS DELETE AND UPDATE BUTTON
            if (_expanded) ...[
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.only(bottom:8.0),
                child: Row(
                  children: [

                
                  // BUTTON TO DELETE EXPENSE
                  DeleteExpenseButton(
                    onDeleteConfirmed: () async {
                          widget.onDelete();
                    },
                  ),
                



                  // BUTTON TO UPDATE EXPENSE
                    SizedBox(width: 7.0),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => UpdateIncomeDialog(
                              
                              initialcreatedAt:widget.transaction.createdAt,
                              initialAmount: widget.transaction.incomeAmount,
                              initialCategory: widget.transaction.incomeCategory,
                              initialRemarks: widget.transaction.incomeRemarks,
                              initialDate: widget.transaction.incomeDate,
                              incomeId: widget.transaction.uidOfIncome,
                              onSubmit: (amount, category, description, date) {
                                widget.onUpdate();
                              }, uidOfIncome: widget.transaction.uidOfIncome,
                            ),
                          );
                        },
                        label: Text(
                          'Update',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                            Color.fromARGB(255, 136, 182, 221),
                          ),
                          elevation: WidgetStateProperty.all<double>(0),
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
