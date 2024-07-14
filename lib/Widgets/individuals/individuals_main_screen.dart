import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/firebase/firebase_utils.dart' as firebase_utils;


class AllIndividuals extends StatefulWidget {
  @override
  _AllIndividualsState createState() => _AllIndividualsState();
}

class _AllIndividualsState extends State<AllIndividuals> {
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
              'View all liabilities',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).cardColor,
              ),
            ),
          ),
          
        ),
      ),



    );
  }
}

