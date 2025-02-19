// FILEPATH: /C:/Users/Hp/Desktop/moneyy - Copy/moneyy/lib/presentation/screens/income/each_income.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // IMPORT SCREENUTIL
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:moneyy/domain/entities/income/income.dart';
import 'package:moneyy/presentation/screens/income/delete_income.dart';
import 'package:moneyy/presentation/screens/income/update_income.dart';

class IncomeCard extends StatefulWidget {
  final IncomeEntity transaction;
  final Function onUpdate; // CALLBACK FOR UPDATE
  final Function onDelete; // CALLBACK FOR DELETE

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
        return Symbols.work; // ACTIVE CATEGORY ICON
      case 'passive':
        return Symbols.heart_check; // PASSIVE CATEGORY ICON
      default:
        return Symbols.add_a_photo; // DEFAULT ICON TO BE RETURNED
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
        margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 15.w), // USE SCREENUTIL FOR MARGIN
        padding: EdgeInsets.fromLTRB(15.w, 0, 10.w, 0.0), // USE SCREENUTIL FOR PADDING
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 65, 64, 64).withOpacity(0.10), // SHADOW COLOR
              offset: const Offset(0, 4), // HORIZONTAL AND VERTICAL OFFSET
              blurRadius: 12.0, // BLUR RADIUS
              spreadRadius: 3.0, // SPREAD RADIUS
            ),
          ],
          color: Theme.of(context).hintColor,
          borderRadius: BorderRadius.circular(20.r), // USE SCREENUTIL FOR BORDER RADIUS
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
                    size: 25.sp, // USE SCREENUTIL FOR SIZE
                  ),
                  Icon(
                    getIconForCategory(widget.transaction.incomeCategory),
                    size: 25.sp, // USE SCREENUTIL FOR SIZE
                    color: Colors.green.shade400,
                  ),
                ],
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    overflow: TextOverflow.ellipsis,
                    widget.transaction.incomeAmount.toStringAsFixed(2),
                    style: GoogleFonts.montserrat(
                      fontSize: 15.sp, // USE SCREENUTIL FOR FONT SIZE
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).canvasColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleExpanded,
                    child: _expanded
                        ? Transform.rotate(
                            angle: 1.5708, // ROTATE 90 DEGREES
                            child: Icon(
                              Icons.arrow_forward_ios_sharp,
                              size: 15.sp, // USE SCREENUTIL FOR SIZE
                              color: Theme.of(context).canvasColor.withOpacity(0.7),
                            ),
                          )
                        : Icon(
                            Icons.arrow_forward_ios_sharp,
                            size: 15.sp, // USE SCREENUTIL FOR SIZE
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
                        overflow: TextOverflow.ellipsis,
                        widget.transaction.incomeRemarks,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp, // USE SCREENUTIL FOR FONT SIZE
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).canvasColor.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 3.h), // USE SCREENUTIL FOR HEIGHT
                      Text(
                        overflow: TextOverflow.ellipsis,
                        timeAgo(widget.transaction.incomeDate),
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp, // USE SCREENUTIL FOR FONT SIZE
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).canvasColor.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // EXPANSION CONTAINS DELETE AND UPDATE BUTTON
            if (_expanded) ...[
              SizedBox(height: 10.h), // USE SCREENUTIL FOR HEIGHT
              Padding(
                padding: EdgeInsets.only(bottom: 8.h), // USE SCREENUTIL FOR PADDING
                child: Row(
                  children: [
                    // BUTTON TO DELETE EXPENSE
                    DeleteIncomeButton(
                      onDeleteConfirmed: () async {
                        widget.onDelete();
                      },
                    ),
                    // BUTTON TO UPDATE EXPENSE
                    SizedBox(width: 7.w), // USE SCREENUTIL FOR WIDTH
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => UpdateIncomeDialog(
                              initialcreatedAt: widget.transaction.createdAt,
                              initialAmount: widget.transaction.incomeAmount,
                              initialCategory: widget.transaction.incomeCategory,
                              initialRemarks: widget.transaction.incomeRemarks,
                              initialDate: widget.transaction.incomeDate,
                              incomeId: widget.transaction.uidOfIncome,
                              onSubmit: (amount, category, description, date) {
                                widget.onUpdate();
                              },
                              uidOfIncome: widget.transaction.uidOfIncome,
                            ),
                          );
                        },
                        label: Text(
                          'Update',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp, // USE SCREENUTIL FOR FONT SIZE
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
                              borderRadius: BorderRadius.circular(12.r), // USE SCREENUTIL FOR BORDER RADIUS
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