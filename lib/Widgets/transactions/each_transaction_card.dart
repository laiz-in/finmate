import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyy/firebase/firebase_utils.dart' as firebase_utils;
import 'package:moneyy/ui/error_snackbar.dart';
import 'package:moneyy/ui/succes_snackbar.dart';

import 'update_spending_screen.dart';

class TransactionCard extends StatefulWidget {
  final firebase_utils.CustomTransaction transaction;
  final Function onDelete;
  final Function onUpdate;

  const TransactionCard({
    Key? key,
    required this.transaction,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _TransactionCardState createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
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

  Future<void> _deleteTransaction() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await firebase_utils.deleteTransaction(context,userId, widget.transaction.uid);
        widget.onDelete();
      } catch (e) {
        errorSnackbar(context, "Failed to delete");
      }
    }
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
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 15.0),
        padding: EdgeInsets.fromLTRB(15, 10, 10, 10.0),
        decoration: BoxDecoration(
        
      color:Color.fromARGB(255, 238, 240, 238),
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: _toggleExpanded,

              // Category icon
              leading: Column(
                children: [
                  Icon(Icons.arrow_outward,color: Colors.red.shade200,),
                  Icon(
                    getIconForCategory(widget.transaction.spendingCategory),
                    size: 25,
                    color: Colors.red.shade200,
                  ),
                ],
              ),

              // Row for amount and forward icon
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${widget.transaction.spendingAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).cardColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  IconButton(
                    icon: Icon(
                      _expanded ? Icons.arrow_downward : Icons.arrow_forward_ios_sharp,
                      size: 20,
                      color: Theme.of(context).cardColor.withOpacity(0.9),
                    ),
                    onPressed: _toggleExpanded,
                  ),
                ],
              ),


              subtitle:Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: Color.fromARGB(255, 212, 214, 212),),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description text
                      Text(
                        widget.transaction.spendingDescription,
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).cardColor.withOpacity(0.7),
                        ),
                      ),

                      // Time ago text
                      Text(
                        timeAgo(widget.transaction.date),
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color:Theme.of(context).cardColor.withOpacity(0.5),
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),

            // Delete and edit buttons
            if (_expanded) ...[
              SizedBox(height: 10.0),
              Row(
                children: [

                  // Delete button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => Container(
                            padding: EdgeInsets.all(15),
                            child: AlertDialog(
                              backgroundColor: Theme.of(context).primaryColorDark,
                              elevation: 15,
                              title: Center(
                                child: Text('Are you sure you want to delete this expense?',textAlign:TextAlign.center,
                                style: GoogleFonts.montserrat(color: Color.fromARGB(255, 197, 81, 73),
                                fontWeight: FontWeight.w600,fontSize: 15)),
                              ),
                              actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                Container(
                                  padding: EdgeInsets.only(left: 15),
                                  color: Colors.transparent,
                                  child: TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text('No, cancel',style: GoogleFonts.montserrat(fontSize: 13,color: Color.fromARGB(255, 173, 108, 103),
                                    fontWeight: FontWeight.w600),),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                    color: Color.fromARGB(255, 235, 125, 117),
                                  ),
                                  child: TextButton(
                                    onPressed: () async {
                                      final userId = FirebaseAuth.instance.currentUser?.uid;
                                      final transactionId = widget.transaction.uid;

                                      if (userId == null) {
                                        errorSnackbar(context, 'User not logged in');
                                        return;
                                      }

                                      // Show a loading indicator immediately
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
                                        // Perform the deletion
                                        await firebase_utils.deleteTransaction(context, userId, transactionId);

                                        // Hide the loading indicator
                                        Navigator.of(context).pop();

                                        // Call the onDelete callback and show success snackbar
                                        widget.onDelete();
                                        successSnackbar(context, "Transaction has been deleted");
                                      } catch (e) {
                                        // Hide the loading indicator
                                        Navigator.of(context).pop();

                                        // Show error snackbar
                                        errorSnackbar(context, 'Failed to delete: ${e.toString()}');
                                      } finally {
                                        // Close the dialog if it's still open
                                        if (Navigator.of(context).canPop()) {
                                          Navigator.of(context).pop();
                                        }
                                      }
                                    },
                                    child: Text('Yes, delete',style: GoogleFonts.montserrat(color: Color.fromARGB(255, 248, 245, 245),fontSize: 15,
                                    fontWeight: FontWeight.w600),),
                                  ),
                                ),]),
                              ],
                            
                            
                            ),

                            
                          ),
                        );
                      },

                      label: Text('Delete',style: GoogleFonts.montserrat(fontWeight: FontWeight.w600,color: Color.fromARGB(255, 133, 78, 78)),),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(Color.fromARGB(255, 248, 214, 214)),
                        elevation: WidgetStateProperty.all<double>(0), // No elevation
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0), // Border radius
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 7.0),

                  // Edit button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => UpdateSpendingDialog(
                            initialAmount: widget.transaction.spendingAmount,
                            initialCategory: widget.transaction.spendingCategory,
                            initialDescription: widget.transaction.spendingDescription,
                            initialDate: widget.transaction.date,
                            transactionId: widget.transaction.uid,
                            onSubmit: (amount, category, description, date) {
                              widget.onUpdate();
                            },
                          ),
                        );
                      },
                      label: Text('Edit',style: GoogleFonts.montserrat(color:Colors.white,
                      fontWeight: FontWeight.w600),),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(Color.fromARGB(255, 136, 182, 221)),
                        elevation: WidgetStateProperty.all<double>(0), // No elevation
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0), // Border radius
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
