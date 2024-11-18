import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../ui/error_snackbar.dart';
import '../../ui/succes_snackbar.dart';

class BorrowedCard extends StatefulWidget {
  final DocumentSnapshot BorrowedList;
  final String userId;

  BorrowedCard({required this.BorrowedList, required this.userId, Key? key}) : super(key: key);

  @override
  _BorrowedCardState createState() => _BorrowedCardState();
}

class _BorrowedCardState extends State<BorrowedCard> {
  
  bool isPaid = false;

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(15),
        child: AlertDialog(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 15,
          title: Center(
            child: Text(
              'You want to delete this liability?',
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
                Container(
                  padding: EdgeInsets.only(left: 15),
                  color: Colors.transparent,
                  child: TextButton(
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
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    color: Color.fromARGB(255, 235, 125, 117),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.userId)
                            .collection('borrowedMoney')
                            .doc(widget.BorrowedList.id)
                            .delete();
                                                    Navigator.of(context).pop();

                        successSnackbar(context, "Bill succesfully deleted");
                      } catch (e) {
                        errorSnackbar(context, "Failed to delete bill");
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final dueDate = widget.BorrowedList['borrowedReturnDate']?.toDate();
    final formattedDueDate = dueDate != null ? DateFormat('dd-MM-yy').format(dueDate) : 'No date';

    return Card(
      color:Color.fromARGB(255, 238, 240, 238),
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // Row that contains bill amount and bill title
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '₹${widget.BorrowedList['borrowedAmount'] ?? '0.00'}',
                  style: GoogleFonts.montserrat(
                    fontSize: 17,
                    color: Theme.of(context).cardColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 20,),
                Text(
              widget.BorrowedList['borrowedMoneyDescription'] ?? 'No name',
              style: GoogleFonts.montserrat(
                fontSize: 17,
                color: Theme.of(context).cardColor.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
            ],
            ),

            Divider(color: Color.fromARGB(255, 209, 211, 209),endIndent: 5,),
            
            // bill description
            Text(
              widget.BorrowedList['fromWho'] ?? 'No description',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Theme.of(context).cardColor.withOpacity(0.6),
              ),
            ),
            // Due on text
            Text(
              'due on - $formattedDueDate',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600 ,
                color: Theme.of(context).cardColor.withOpacity(0.6),
              ),
            ),

            SizedBox(height: 8.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              // Update button
              Container(
                  decoration: BoxDecoration(
                    
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color.fromARGB(255, 214, 236, 247),
                  ),
                  child: TextButton(
                  style: TextButton.styleFrom(
                    elevation: 25,
                      minimumSize: Size(70, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  onPressed: () {
                },
                    child: Text(
                      'update',
                      style: GoogleFonts.montserrat(
                        color: Color.fromARGB(255, 44, 83, 121),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

              // delete button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: Color.fromARGB(255, 248, 218, 216),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                  elevation: 25,
                    minimumSize: Size(70, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed:_showDeleteConfirmationDialog,
                  child: Text(
                    'delete',
                    style: GoogleFonts.montserrat(
                      color: Color.fromARGB(255, 223, 109, 109),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              ],
              
            ),
          ],
        ),
      ),
    );
  }
}
