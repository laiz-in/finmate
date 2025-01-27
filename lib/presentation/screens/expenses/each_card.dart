import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:moneyy/domain/entities/spending/expenses.dart';
import 'package:moneyy/presentation/screens/expenses/delete_expense_button.dart';
import 'package:moneyy/presentation/screens/expenses/update_expense.dart';

class TransactionCard extends StatefulWidget {
  final ExpensesEntity transaction;
  final Function onUpdate; // CALLBACK FOR UPDATE
  final Function onDelete; // CALLBACK FOR DELETE

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
    final DateFormat formatter = DateFormat('d MMMM y \' : \' h:mm a');
    return formatter.format(date);
  }

  IconData getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Symbols.fastfood;
      case 'transport':
        return Symbols.tram;
      case 'entertainment':
        return Symbols.movie;
      case 'bills':
        return Icons.receipt;
      case 'stationary':
        return Icons.shopping_cart;
      case 'groceries':
        return Symbols.grocery;
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
        margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 15.w), // MARGIN
        padding: EdgeInsets.fromLTRB(15.w, 0, 10.w, 0.0), // PADDING
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 65, 64, 64).withOpacity(0.10), // SHADOW COLOR
              offset: const Offset(0, 4), // HORIZONTAL AND VERTICAL OFFSET
              blurRadius: 12.0.r, // BLUR RADIUS
              spreadRadius: 3.0.r, // SPREAD RADIUS
            ),
          ],
          color: Theme.of(context).hintColor,
          borderRadius: BorderRadius.circular(15.0.r), // RADIUS
        ),
        child: Column(
          children: [
            ListTile(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              onTap: _toggleExpanded,

              // LEADING ICONS
              leading: Column(
                children: [
                  Icon(
                    Symbols.north_east,
                    color: Colors.red.shade300,
                    size: 25.sp,
                    weight: 900,
                  ),
                  Icon(
                    getIconForCategory(widget.transaction.spendingCategory),
                    size: 25.sp, // ICON SIZE
                    color: Colors.red.shade300,
                    weight: 900,
                  ),
                ],
              ),

// EXPENSE TITLE AND SUBTITLE
title: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // 50%: EXPENSE TITLE
    Expanded(
      flex: 5, // 50%
      child: Text(
        widget.transaction.spendingDescription,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.montserrat(
          fontSize: 15.sp, // FONT SIZE
          fontWeight: FontWeight.w500,
          color: Theme.of(context).canvasColor.withOpacity(0.8),
        ),
      ),
    ),

    // 40%: EXPENSE AMOUNT
    Expanded(
      flex: 4, // 40%
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Align amount to the end
        children: [
          Flexible(
            child: Text(
              widget.transaction.spendingAmount.toStringAsFixed(1),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                fontSize: 15.sp, // FONT SIZE
                fontWeight: FontWeight.w600,
                color: Theme.of(context).canvasColor,
              ),
            ),
          ),
        ],
      ),
    ),

    // 10%: EXPAND ICON
    Expanded(
      flex: 1, // 10%
      child: GestureDetector(
        onTap: _toggleExpanded,
        child: _expanded
            ? Transform.rotate(
                angle: 1.5708, // ROTATE 90 DEGREES
                child: Icon(
                  Icons.arrow_forward_ios_sharp,
                  size: 15.sp, // ICON SIZE
                  color: Theme.of(context).canvasColor.withOpacity(0.7),
                ),
              )
            : Icon(
                Icons.arrow_forward_ios_sharp,
                size: 15.sp, // ICON SIZE
                color: Theme.of(context).canvasColor.withOpacity(0.7),
              ),
      ),
    ),
  ],
),


              // EXPENSE DATE
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: Theme.of(context).canvasColor.withOpacity(0.1)),
                  Text(
                    overflow: TextOverflow.ellipsis,
                    timeAgo(widget.transaction.spendingDate),
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp, // FONT SIZE
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).canvasColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),



            // EXPANSION CONTAINS DELETE AND UPDATE BUTTON
            if (_expanded) ...[
              SizedBox(height: 10.h), // HEIGHT
              Padding(
                padding: EdgeInsets.only(bottom: 8.h), // PADDING
                child: Row(
                  children: [
                    // BUTTON TO DELETE EXPENSE
                    DeleteExpenseButton(
                      onDeleteConfirmed: () async {
                        widget.onDelete();
                      },
                    ),
                    // BUTTON TO UPDATE EXPENSE
                    SizedBox(width: 7.w), // WIDTH
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => UpdateSpendingDialog(
                              initialcreatedAt: widget.transaction.createdAt,
                              initialAmount: widget.transaction.spendingAmount,
                              initialCategory: widget.transaction.spendingCategory,
                              initialDescription: widget.transaction.spendingDescription,
                              initialDate: widget.transaction.spendingDate,
                              transactionId: widget.transaction.uidOfTransaction,
                              onSubmit: (amount, category, description, date) {
                                widget.onUpdate();
                              },
                              uidOfTransaction: widget.transaction.uidOfTransaction,
                            ),
                          );
                        },
                        label: Text(
                          'Edit',
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp, // FONT SIZE
                            color: const Color.fromARGB(255, 1, 45, 88),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                            const Color.fromARGB(255, 208, 223, 235),
                          ),
                          elevation: WidgetStateProperty.all<double>(0),
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0.r), // RADIUS
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