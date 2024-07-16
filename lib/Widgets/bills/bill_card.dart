import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';


class BillCard extends StatefulWidget {
  final DocumentSnapshot bill;
  final String userId;

  BillCard({required this.bill, required this.userId, Key? key}) : super(key: key);

  @override
  _BillCardState createState() => _BillCardState();
}

class _BillCardState extends State<BillCard> {
  bool isPaid = false;

  @override
  void initState() {
    super.initState();
    isPaid = widget.bill['paidStatus'] == 1;
  }

  void _togglePaidStatus() async {
    final newStatus = isPaid ? 0 : 1;
    setState(() {
      isPaid = !isPaid;
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('bills')
        .doc(widget.bill.id)
        .update({'paidStatus': newStatus});
  }

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
              'Are you sure you want to delete this bill?',
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
                            .collection('bills')
                            .doc(widget.bill.id)
                            .delete();
                        Navigator.of(context).pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to delete'),
                          ),
                        );
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

  void _updateBill() {
    // Implement update functionality here
  }

  @override
  Widget build(BuildContext context) {
    final dueDate = widget.bill['billDueDate']?.toDate();
    final formattedDueDate = dueDate != null ? DateFormat('dd-MM-yy').format(dueDate) : 'No date';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
    
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      color: Theme.of(context).cardColor,
      child: ListTile(
        contentPadding: EdgeInsets.fromLTRB(15.0,15,15,5),

        // bill title
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '₹${widget.bill['billAmount'] ?? '0.00'}',
              style: GoogleFonts.montserrat(
                fontSize: 25,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 20), // Adjust the width as needed for spacing
            
            // Correct the Text widget structure and properties
            Expanded(
              child: Text(
                widget.bill['billTitle'] ?? 'No name',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 25,
                  color: Theme.of(context).primaryColorDark.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),



        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
              overflow: TextOverflow.ellipsis,
              widget.bill['billDescription'] ?? 'No name',
              style: GoogleFonts.montserrat(
                fontSize: 15,
                color: Theme.of(context).primaryColor.withOpacity(0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
                Text(
                  'Due Date: $formattedDueDate',
                  style: GoogleFonts.montserrat(
                    color: Theme.of(context).primaryColor.withOpacity(0.6),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [



                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                      onPressed: _updateBill,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color:Colors.orange.shade200),
                      onPressed: _showDeleteConfirmationDialog,
                    ),
                  ],
                ),


                Row(
                  children: [
                    Text(
                      'Paid already?',
                      style: GoogleFonts.montserrat(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Checkbox(
                      shape: CircleBorder(eccentricity:0.8),
                      value: isPaid,
                      onChanged: (value) {
                        _togglePaidStatus();
                      },
                      
                      activeColor: Theme.of(context).primaryColorDark,
                      checkColor: Theme.of(context).cardColor,
                    ),
                  ],
                ),



              ],
            ),
          ],
        ),
      ),
    );
  }
}
