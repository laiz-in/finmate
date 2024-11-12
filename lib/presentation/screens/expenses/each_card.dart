import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/common/widgets/success_snackbar.dart';
import 'package:moneyy/domain/entities/spending/expenses.dart';
import 'package:moneyy/domain/usecases/expenses/delete_expenses_usecase.dart';
import 'package:moneyy/presentation/screens/expenses/delete_expense_button.dart';
import 'package:moneyy/presentation/screens/expenses/update_expense.dart';
import 'package:moneyy/service_locator.dart';

class TransactionCard extends StatefulWidget {
  final ExpensesEntity transaction;
  final Function onUpdate; // Callback for update
  final Function onDelete; // Callback for delete

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  TransactionCardState createState() => TransactionCardState();
}

class TransactionCardState extends State<TransactionCard> {
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
      case 'food':
        return Icons.fastfood;
      case 'transport':
        return Icons.directions_bus;
      case 'entertainment':
        return Icons.movie;
      case 'bills':
        return Icons.receipt;
      case 'stationary':
        return Icons.shopping_cart;
      case 'groceries':
        return Icons.store;
      case 'others':
        return Icons.category;
      default:
        return Icons.add;
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
                    Icons.arrow_outward,
                    color: Colors.red.shade200,
                    size: 20,
                  ),
                  Icon(
                    getIconForCategory(widget.transaction.spendingCategory),
                    size: 20,
                    color: Colors.red.shade200,
                  ),
                ],
              ),

              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    overflow:TextOverflow.ellipsis,
                    widget.transaction.spendingAmount.toStringAsFixed(2),
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).canvasColor,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    highlightColor:Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    splashRadius:null,
                    icon: _expanded
                          ? Transform.rotate(
                              angle: 1.5708, // Rotate 90 degrees to make the arrow point downward
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
                    onPressed: _toggleExpanded,
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
                        widget.transaction.spendingDescription,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).canvasColor.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 3,),
                      Text(
                        overflow: TextOverflow.ellipsis,
                        timeAgo(widget.transaction.spendingDate),
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
                      // Execute delete action here
                      final deleteExpensesUseCase = sl<DeleteExpensesUseCase>();
                      final result = await deleteExpensesUseCase.call(uidOfTransaction:widget.transaction.uidOfTransaction);

                      result.fold(
                        (failureMessage) {
                          errorSnackbar(context, "failed to delete expense");
                          widget.onDelete();
                        },
                        (successMessage) {
                          successSnackbar(context, "expense has been deleted");
                          widget.onDelete();

                        },
                      );
                    },
                  ),
                



                  // BUTTON TO UPDATE EXPENSE
                    SizedBox(width: 7.0),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => UpdateSpendingDialog(
                              
                              initialcreatedAt:widget.transaction.createdAt,
                              initialAmount: widget.transaction.spendingAmount,
                              initialCategory: widget.transaction.spendingCategory,
                              initialDescription: widget.transaction.spendingDescription,
                              initialDate: widget.transaction.spendingDate,
                              transactionId: widget.transaction.uidOfTransaction,
                              onSubmit: (amount, category, description, date) {
                                widget.onUpdate();
                              }, uidOfTransaction: widget.transaction.uidOfTransaction,
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
