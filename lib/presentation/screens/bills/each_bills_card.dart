// FILEPATH: /C:/Users/Hp/Desktop/moneyy - Copy/moneyy/lib/presentation/screens/bills/each_bills_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // IMPORT SCREENUTIL
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:moneyy/domain/entities/bills/bills.dart';
import 'package:moneyy/presentation/screens/bills/delete_bills_button.dart';
import 'package:moneyy/presentation/screens/bills/update_bills.dart';

class BillCard extends StatefulWidget {
  final BillsEntity bill;
  final Function onUpdate; // CALLBACK FOR UPDATE
  final Function onDelete; // CALLBACK FOR DELETE
  
  const BillCard({
    super.key,
    required this.bill,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  BillCardState createState() => BillCardState();
}

class BillCardState extends State<BillCard> {
  bool _expanded = false;
  bool isPaid = false;


  String _getDueStatusText(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return 'Overdue';
    } else if (difference <= 3) {
      return 'Due soon';
    } else {
      return 'Still have time';
    }
  }

  Color _getDueStatusColorForText(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return Colors.red.shade900; // RED FOR OVERDUE
    } else if (difference <= 3) {
      return Colors.orange.shade900; // ORANGE FOR DUE SOON
    } else {
      return Color.fromARGB(255, 117, 116, 27); // GREEN FOR ENOUGH TIME
    }
  }

  Color _getDueStatusColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return const Color.fromARGB(255, 247, 225, 227); // RED FOR OVERDUE
    } else if (difference <= 3) {
      return Colors.orange.shade100; // ORANGE FOR DUE SOON
    } else {
      return Color.fromARGB(255, 241, 240, 216); // GREEN FOR ENOUGH TIME
    }
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 15.w), // USE SCREENUTIL FOR MARGIN
        padding: EdgeInsets.fromLTRB(15.w, 0, 10.w, 0.0), // USE SCREENUTIL FOR PADDING
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 65, 64, 64).withOpacity(0.10), // SHADOW COLOR
              offset: const Offset(0, 4), // HORIZONTAL AND VERTICAL OFFSET
              blurRadius: 12.0.r, // USE SCREENUTIL FOR BLUR RADIUS
              spreadRadius: 3.0.r, // USE SCREENUTIL FOR SPREAD RADIUS
            ),
          ],
          color: Theme.of(context).hintColor,
          borderRadius: BorderRadius.circular(20.0.r), // USE SCREENUTIL FOR BORDER RADIUS
        ),
        child: Column(
          children: [
            ListTile(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              onTap: _toggleExpanded,

              // LEADING ICON AT THE FIRST
              leading: Icon(
                widget.bill.paidStatus == 1
                    ? Symbols.credit_score // ICON FOR PAID STATUS
                    : Symbols.avg_pace, // ICON FOR UNPAID STATUS
                color: widget.bill.paidStatus == 1
                    ? Theme.of(context).canvasColor // GREEN COLOR FOR PAID STATUS
                    : Theme.of(context).canvasColor, // RED COLOR FOR UNPAID STATUS
                size: 35.sp, // USE SCREENUTIL FOR ICON SIZE
              ),

              // TOP ROW THAT CONTAINS BILL TITLE AND AMOUNT
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BILL TITLE - 60%
                  Expanded(
                    flex: 5, // 60% OF THE WIDTH
                    child: Text(
                      widget.bill.billTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp, // USE SCREENUTIL FOR FONT SIZE
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).canvasColor.withOpacity(0.7),
                      ),
                    ),
                  ),

                  // BILL AMOUNT - 30%
                  Flexible(
                    flex: 4, // 30% OF THE WIDTH
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          widget.bill.billAmount.toStringAsFixed(1),
                          style: GoogleFonts.montserrat(
                            fontSize: 17.sp, // USE SCREENUTIL FOR FONT SIZE
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).canvasColor,
                          ),
                        ),
                        SizedBox(width: 8.w), // SPACE BETWEEN AMOUNT AND ICON
                      ],
                    ),
                  ),

                  // EXPAND ICON - 10%
                  Flexible(
                    flex: 1, // 10% OF THE WIDTH
                    child: GestureDetector(
                      onTap: _toggleExpanded,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _expanded
                            ? Transform.rotate(
                                angle: 1.5708, // ROTATE 90 DEGREES TO POINT DOWN
                                child: Icon(
                                  Icons.arrow_forward_ios_sharp,
                                  size: 15.sp, // USE SCREENUTIL FOR ICON SIZE
                                  color: Theme.of(context).canvasColor.withOpacity(0.7),
                                ),
                              )
                            : Icon(
                                Icons.arrow_forward_ios_sharp,
                                size: 15.sp, // USE SCREENUTIL FOR ICON SIZE
                                color: Theme.of(context).canvasColor.withOpacity(0.7),
                              ),
                      ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          // DATE TEXT TAKES 70% OF THE AVAILABLE WIDTH
                          Expanded(
                            flex: 6,
                            child: Text(
                              overflow: TextOverflow.ellipsis,
                              'Due on: ${DateFormat('dd-MM-yyyy').format(widget.bill.billDueDate)}',
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp, // USE SCREENUTIL FOR FONT SIZE
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).canvasColor.withOpacity(0.5),
                              ),
                            ),
                          ),

                          SizedBox(width: 10.w),


                          // CONTAINER TAKES 30% OF THE AVAILABLE WIDTH
                          if (widget.bill.paidStatus == 0)
                            Expanded(
                              flex: 4,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w), // USE SCREENUTIL FOR PADDING
                                decoration: BoxDecoration(
                                  color: _getDueStatusColor(widget.bill.billDueDate), // BACKGROUND COLOR
                                  borderRadius: BorderRadius.circular(10.0.r), // USE SCREENUTIL FOR BORDER RADIUS
                                ),
                                child: Text(
                                  _getDueStatusText(widget.bill.billDueDate), // STATUS TEXT
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.sp, // USE SCREENUTIL FOR FONT SIZE
                                    fontWeight: FontWeight.w500,
                                    color: _getDueStatusColorForText(widget.bill.billDueDate), // TEXT COLOR
                                  ),
                                  textAlign: TextAlign.center, // ALIGN THE TEXT IN THE CENTER OF THE CONTAINER
                                ),
                              ),
                            ),

                            // IF THE BILL IS PAID
                            if (widget.bill.paidStatus == 1)
                            Expanded(
                              flex: 4,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w), // USE SCREENUTIL FOR PADDING
                                decoration: BoxDecoration(
                                  color: Colors.green.shade600, // BACKGROUND COLOR
                                  borderRadius: BorderRadius.circular(10.0.r), // USE SCREENUTIL FOR BORDER RADIUS
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Paid", // STATUS TEXT
                                      style: GoogleFonts.poppins(
                                        fontSize: 10.sp, // USE SCREENUTIL FOR FONT SIZE
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white, // TEXT COLOR
                                      ),
                                      textAlign: TextAlign.center, // ALIGN THE TEXT IN THE CENTER OF THE CONTAINER
                                    ),
                                    SizedBox(width: 8.w,),
                                    Icon(Symbols.check_circle_sharp,color: Colors.white,size: 15.sp,)
                                  ],
                                ),
                              ),
                            ),


                        
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // EXPANSION CONTAINS DELETE AND UPDATE BUTTON
            if (_expanded) ...[
              SizedBox(height: 10.h), // USE SCREENUTIL FOR SPACING
              Padding(
                padding: EdgeInsets.only(bottom: 8.h), // USE SCREENUTIL FOR PADDING
                child: Row(
                  children: [
                    // BUTTON TO DELETE BILL
                    DeleteBillButton(
                      onDeleteConfirmed: () async {
                        widget.onDelete();
                      },
                    ),

                    // BUTTON TO UPDATE BILL
                    SizedBox(width: 7.w), // SPACING
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => UpdateBillDialog(
                              initialBillpaidStatus: widget.bill.paidStatus,
                              initialaddedDate: widget.bill.addedDate,
                              initialBillAmount: widget.bill.billAmount,
                              initialBillDescription: widget.bill.billDescription,
                              initialBillDueDate: widget.bill.billDueDate,
                              initialBillTitle: widget.bill.billTitle,
                              transactionId: widget.bill.uidOfBill,
                              onSubmit: (amount, category, description, date,paidStatus) {
                                widget.onUpdate();
                              },
                              uidOfBill: widget.bill.uidOfBill,
                            ),
                          );
                        },
                        label: Text(
                          'Update',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp, // FONT SIZE
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