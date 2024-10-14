import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/common/widgets/success_snackbar.dart';
import 'package:moneyy/domain/entities/spending/expenses.dart';
import 'package:moneyy/firebase/firebase_utils.dart' as firebase_utils;
import 'package:moneyy/presentation/screens/expenses/update_expense.dart';

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
        return Icons.local_grocery_store;
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
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        padding: const EdgeInsets.fromLTRB(15, 0, 10, 0.0),
      
        decoration: BoxDecoration(
          boxShadow: [
      BoxShadow(
        color: const Color.fromARGB(255, 65, 64, 64).withOpacity(0.1), // Shadow color
        offset: const Offset(0, 4), // Horizontal and vertical offset
        blurRadius: 12.0, // Blur radius
        spreadRadius: 3.0, // Spread radius
      ),
    ],
          color: Theme.of(context).hintColor,
          borderRadius: BorderRadius.circular(25.0),
        ),

        child: Column(
          children: [

            ListTile(
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
                    '₹${widget.transaction.spendingAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).canvasColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  IconButton(
                    icon: Icon(
                      _expanded ? Icons.arrow_downward : Icons.arrow_forward_ios_sharp,
                      size: 17,
                      color: Theme.of(context).canvasColor.withOpacity(0.9),
                    ),
                    onPressed: _toggleExpanded,
                  ),
                ],
              ),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: Theme.of(context).canvasColor.withOpacity(0.3)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.transaction.spendingDescription,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).canvasColor.withOpacity(0.7),
                        ),
                      ),
                      Text(
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

            if (_expanded) ...[
              SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Theme.of(context).primaryColorDark,
                            elevation: 15,
                            title: Center(
                              child: Text(
                                'Are you sure you want to delete this expense?',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  color: Color.fromARGB(255, 197, 81, 73),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text(
                                      'No, cancel',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        color: Color.fromARGB(255, 173, 108, 103),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final userId = FirebaseAuth.instance.currentUser?.uid;
                                      final transactionId = widget.transaction.uidOfTransaction;

                                      if (userId == null) {
                                        errorSnackbar(context, 'User not logged in');
                                        return;
                                      }

                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              color: Theme.of(context).primaryColorDark,
                                            ),
                                          );
                                        },
                                      );

                                      try {
                                        await firebase_utils.deleteTransaction(context, userId, transactionId);
                                        Navigator.of(context).pop();
                                        widget.onDelete();
                                        successSnackbar(context, "Transaction has been deleted");
                                      } catch (e) {
                                        Navigator.of(context).pop();
                                        errorSnackbar(context, 'Failed to delete: ${e.toString()}');
                                      } finally {
                                        if (Navigator.of(context).canPop()) {
                                          Navigator.of(context).pop();
                                        }
                                      }
                                    },
                                    child: Text(
                                      'Yes, delete',
                                      style: GoogleFonts.montserrat(
                                        color: Color.fromARGB(255, 248, 245, 245),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      label: Text(
                        'Delete',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 133, 78, 78),
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 248, 214, 214),
                        ),
                        elevation: WidgetStateProperty.all<double>(0),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 7.0),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => UpdateSpendingDialog(
                            initialAmount: widget.transaction.spendingAmount,
                            initialCategory: widget.transaction.spendingCategory,
                            initialDescription: widget.transaction.spendingDescription,
                            initialDate: widget.transaction.spendingDate,
                            transactionId: widget.transaction.uidOfTransaction,
                            onSubmit: (amount, category, description, date) {
                              widget.onUpdate();
                            },
                          ),
                        );
                      },
                      label: Text(
                        'Edit',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          Color.fromARGB(255, 136, 182, 221),
                        ),
                        elevation: WidgetStateProperty.all<double>(0),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
