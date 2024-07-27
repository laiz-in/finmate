import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/firebase/firebase_utils.dart' as firebase_utils;


class AllLiabilites extends StatefulWidget {
  @override
  _AllLiabilitesState createState() => _AllLiabilitesState();
}

class _AllLiabilitesState extends State<AllLiabilites> {
  bool isLoading = true;
  List<firebase_utils.CustomTransaction> transactions = [];
  List<firebase_utils.CustomTransaction> filteredTransactions = [];

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Theme.of(context).primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Adjust this height as needed
        child: AppBar(
          scrolledUnderElevation: 0,
          elevation: 0,
          toolbarHeight: 90,
          iconTheme: IconThemeData(color: Theme.of(context).cardColor,size: 30),
          backgroundColor: Theme.of(context).primaryColor,
          title: Container(
            alignment: Alignment.bottomLeft, // Align title to the bottom-left
            child: Text(
              'Liabilities',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).cardColor,
              ),
            ),
          ),
          
        ),
      ),

    body: Padding(padding: EdgeInsets.all(15),
    child: Container(

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 180,
                  decoration: BoxDecoration(
                    
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Theme.of(context).cardColor.withOpacity(0.1),
                  ),
                  child: TextButton(
                  style: TextButton.styleFrom(
                    elevation: 25,
                      minimumSize: Size(70, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Text(
                          'Add borrowed',
                          style: GoogleFonts.montserrat(
                            color: Theme.of(context).cardColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(Icons.arrow_upward,color: Colors.red,)
                      ],
                    ),
                  ),
                ),
          SizedBox(width: 10,),
          Container(
            width: 180,
                  decoration: BoxDecoration(
                    
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Theme.of(context).cardColor.withOpacity(0.1),
                  ),
                  child: TextButton(
                  style: TextButton.styleFrom(
                    elevation: 25,
                      minimumSize: Size(70, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  onPressed: () {},
                   child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Add lent',
                          style: GoogleFonts.montserrat(
                            color: Theme.of(context).cardColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(Icons.arrow_downward,color: Colors.green,)
                      ],
                    ),
                  ),
                ),

        ],

      ),

    ),
    ),

    );
  }
}

