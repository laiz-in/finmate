import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/firebase/firebase_utils.dart' as firebase_utils;

import 'each_transaction_card.dart';
import 'filter_spending.dart';

class AllSpendings extends StatefulWidget {
  @override
  _AllSpendingsState createState() => _AllSpendingsState();
}

class _AllSpendingsState extends State<AllSpendings> {
  bool isLoading = true;
  List<firebase_utils.CustomTransaction> transactions = [];
  List<firebase_utils.CustomTransaction> filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
  if (!mounted) return; // Ensure the widget is still mounted
  setState(() {
    isLoading = true;
  });

  try {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final fetchedTransactions = await firebase_utils.getAllSpendings(context, userId);
      if (!mounted) return; // Ensure the widget is still mounted
      setState(() {
        transactions = fetchedTransactions;
        filteredTransactions = fetchedTransactions;
        isLoading = false;
      });
    } else {
      if (!mounted) return; // Ensure the widget is still mounted
      setState(() {
        isLoading = false;
      });
    }
  } catch (e) {
    if (!mounted) return; // Ensure the widget is still mounted
    setState(() {
      isLoading = false;
    });
  }
}

  void sortByAmount(double? amount, bool ascending) {
    setState(() {
      if (ascending) {
        filteredTransactions.sort((a, b) => a.spendingAmount.compareTo(b.spendingAmount));
      } else {
        filteredTransactions.sort((a, b) => b.spendingAmount.compareTo(a.spendingAmount));
      }
    });
  }

  void filterByCategory(String? category) {
    setState(() {
      if (category == null || category == 'All Categories') {
        filteredTransactions = transactions;
      } else {
        filteredTransactions = transactions.where((transaction) {
          return transaction.spendingCategory == category;
        }).toList();
      }
    });
  }

  void filterByDate(DateTime? startDate, DateTime? endDate) {
    setState(() {
      if (startDate == null || endDate == null) {
        filteredTransactions = transactions;
      } else {
        filteredTransactions = transactions.where((transaction) {
          return transaction.date.isAfter(startDate) && transaction.date.isBefore(endDate);
        }).toList();
      }
    });
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
              'View all expenses',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).cardColor,
              ),
            ),
          ),
          
        ),
      ),
      
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
  child: Container(
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor.withOpacity(0.4),
      borderRadius: BorderRadius.circular(20.0),
    ),
    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
    child: Row(
      children: [
        Icon(
          Icons.search,
          color: Theme.of(context).primaryColorDark.withOpacity(0.5),
        ),
        SizedBox(width: 10.0), // Add some spacing between the icon and the text field
        Expanded(
          child: TextField(
            autofocus: false,
            onChanged: (value) {
              setState(() {
                filteredTransactions = transactions
                    .where((transaction) => transaction.spendingDescription
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                    .toList();
              });
            },
            autocorrect: false,
            enableSuggestions: false,
            style: GoogleFonts.montserrat(
                color: Theme.of(context).cardColor,
                fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Search..',
              hintStyle: GoogleFonts.montserrat(
                  color: Theme.of(context).primaryColorDark.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    ),
  ),
),
                SizedBox(width: 15),
                IconButton(
                  icon: Icon(Icons.sort, color: Theme.of(context).cardColor,size: 35,),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return FilterDialog(
                          onSortByAmount: sortByAmount,
                          onFilterByCategory: filterByCategory,
                          onFilterByDate: filterByDate,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 15,),
          Expanded(
            child: RefreshIndicator(
              color: Theme.of(context).primaryColorDark,
              backgroundColor: Colors.transparent,
              strokeWidth: 2,
              onRefresh: fetchTransactions,
              child: Container(
                color: Theme.of(context).primaryColor,
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColorDark,
                          strokeWidth: 1,
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          return TransactionCard(
                            transaction: filteredTransactions[index],
                            onDelete: fetchTransactions,
                            onUpdate: () {
                              fetchTransactions();
                            },
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    
    );
  }
}

