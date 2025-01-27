import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyy/bloc/bills/bills_bloc.dart';
import 'package:moneyy/bloc/bills/bills_event.dart';
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
void _togglePaidStatus() {
  context.read<BillsBloc>().add(UpdateBillStatusEvent(widget.bill.uidOfBill));
}

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
    return Colors.red.shade900; // ORANGE FOR DUE SOON
  } else if (difference <= 3) {
    return Colors.orange.shade900; // ORANGE FOR OVERDUE
  } else {
    return Colors.green.shade700; // GREEN FOR ENOUGH TIME
  }
}

Color _getDueStatusColor(DateTime dueDate) {
  final now = DateTime.now();
  final difference = dueDate.difference(now).inDays;

  if (difference < 0) {
    return const Color.fromARGB(255, 247, 225, 227); // ORANGE FOR DUE SOON
  } else if (difference <= 3) {
    return Colors.orange.shade100; // ORANGE FOR OVERDUE
  } else {
    return const Color.fromARGB(255, 224, 243, 225); // GREEN FOR ENOUGH TIME
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
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 15.w), // MARGIN
        padding: EdgeInsets.fromLTRB(15.w, 0, 10.w, 0.0), // PADDING
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 65, 64, 64).withOpacity(0.13), // SHADOW COLOR
              offset: const Offset(0, 4), // HORIZONTAL AND VERTICAL OFFSET
              blurRadius: 12.0.r, // BLUR RADIUS
              spreadRadius: 3.0.r, // SPREAD RADIUS
            ),
          ],
          color: Theme.of(context).hintColor,
          borderRadius: BorderRadius.circular(20.0.r), // RADIUS
        ),
          child: Column(
          children: [
            ListTile(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              onTap: _toggleExpanded,

              // LEADING ICON
              leading: Icon(
                widget.bill.paidStatus == 1
                    ? Icons.beenhere_outlined // ICON FOR PAID STATUS
                    : Icons.schedule, // ICON FOR UNPAID STATUS
                color: widget.bill.paidStatus == 1
                    ? Colors.green.shade300 // GREEN COLOR FOR PAID STATUS
                    : Colors.red.shade200, // RED COLOR FOR UNPAID STATUS
                size: 35.sp, // ICON SIZE
              ),

              title: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // BILL TITLE - 60%
    Expanded(
      flex: 5, // 60% of the width
      child: Text(
        widget.bill.billTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          fontSize: 15.sp, // FONT SIZE
          fontWeight: FontWeight.w500,
          color: Theme.of(context).canvasColor.withOpacity(0.7),
        ),
      ),
    ),

    // BILL AMOUNT - 30%
    Flexible(
      flex: 4, // 30% of the width
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            widget.bill.billAmount.toStringAsFixed(1),
            style: GoogleFonts.montserrat(
              fontSize: 17.sp, // FONT SIZE
              fontWeight: FontWeight.w600,
              color: Theme.of(context).canvasColor,
            ),
          ),
          SizedBox(width: 8.w), // Space between amount and icon
        ],
      ),
    ),

    // EXPAND ICON - 10%
    Flexible(
      flex: 1, // 10% of the width
      child: GestureDetector(
        onTap: _toggleExpanded,
        child: Align(
          alignment: Alignment.centerRight,
          child: _expanded
              ? Transform.rotate(
                  angle: 1.5708, // Rotate 90 degrees to point down
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
                            // Text takes 70% of the available width
                            Expanded(
                              flex: 6,
                              child:  Text(
                                                overflow: TextOverflow.ellipsis,
                                                'Due on: ${DateFormat('dd-MM-yyyy').format(widget.bill.billDueDate)}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11.sp, // FONT SIZE
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context).canvasColor.withOpacity(0.5),
                                                ),
                                              ),
                            ),
                            SizedBox(width: 10.w), // Spacing between text and container
                            // Container takes 30% of the available width
                            if(widget.bill.paidStatus == 0)
                            Expanded(
                              flex: 4,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w), // PADDING
                                decoration: BoxDecoration(
                                  color: _getDueStatusColor(widget.bill.billDueDate), // BACKGROUND COLOR
                                  borderRadius: BorderRadius.circular(10.0.r), // BORDER RADIUS
                                ),
                                child: Text(
                                  _getDueStatusText(widget.bill.billDueDate), // STATUS TEXT
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.sp, // FONT SIZE
                                    fontWeight: FontWeight.w500,
                                  color: _getDueStatusColorForText(widget.bill.billDueDate), // BACKGROUND COLOR
                                  ),
                                  textAlign: TextAlign.center, // Align the text in the center of the container
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
              SizedBox(height: 10.h), // SPACING
              Padding(
                padding: EdgeInsets.only(bottom: 8.h), // PADDING
                child: Row(
                  children: [
                    // BUTTON TO DELETE EXPENSE
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
                              onSubmit: (amount, category, description, date) {
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
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                            const Color.fromARGB(255, 136, 182, 221),
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
                    
                    // MARK AS PAID BUTTON
                    SizedBox(width: 7.w), // SPACING
                    Container(
                height: 35,
                padding: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    
                    
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    color: Color.fromARGB(255, 189, 218, 198),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                          'Paid',
                          style: GoogleFonts.montserrat(
                            color: Color.fromARGB(255, 51, 88, 40),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                      ),
                      Checkbox(
                      focusColor: Colors.yellow,
                      shape: CircleBorder(eccentricity: 0.5),
                      value: isPaid,
                      onChanged: (value) {
                        _togglePaidStatus();
                      },
                      activeColor: Theme.of(context).primaryColor,
                      checkColor: Theme.of(context).cardColor,
                    ),
                    ],
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