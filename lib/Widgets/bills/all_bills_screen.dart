import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'add_bills.dart';
import 'bill_card.dart';

class AllBills extends StatefulWidget {
  @override
  _AllBillsState createState() => _AllBillsState();
}

class _AllBillsState extends State<AllBills> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(110.0), // Adjust this height as needed
        child: AppBar(
          scrolledUnderElevation: 0,
          elevation: 0,
          toolbarHeight: 90,
          iconTheme: IconThemeData(
            color: Theme.of(context).cardColor,
            size: 30,
          ),
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            "Bills to Pay",
            style: GoogleFonts.montserrat(
              color: Theme.of(context).cardColor,
              fontSize: 25,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
            Tab(text: "Upcoming Bills"),
            Tab(text: "Paid Bills"),
            ],
            labelColor: Theme.of(context).cardColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).cardColor,
            labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold,fontSize: 17),
            unselectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),


          actions: [
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: EdgeInsets.all(25),
                  child: AddBillDialog(),
                ),
              );
            },
            icon: Icon(Icons.add, color: Theme.of(context).cardColor, size: 30),
            label: Text(
              "Add bill",
              style: GoogleFonts.montserrat(
                color: Theme.of(context).cardColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        ),
      ),
      body: user == null
          ? Center(child: Text("Please log in to see your bills.", style: TextStyle(color: Theme.of(context).cardColor)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBillList(user.uid, false),
                _buildBillList(user.uid, true),
              ],
            ),

      floatingActionButton: FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(25),
            child: AddBillDialog(),
          ),
        );
      },
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      child:Icon(Icons.add, color: Theme.of(context).primaryColor, size: 30),
    ),


    );
  }

  Widget _buildBillList(String userId, bool isPaid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('bills')
          .where('paidStatus', isEqualTo: isPaid ? 1 : 0)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error fetching bills.", style: TextStyle(color: Theme.of(context).cardColor)));
        }
        final bills = snapshot.data?.docs ?? [];
        if (bills.isEmpty) {
          return Center(child: Text(isPaid ? "No paid bills." : "No upcoming bills.", style: TextStyle(color: Theme.of(context).cardColor)));
        }
        return ListView.builder(
          padding: EdgeInsets.all(15.0),
          itemCount: bills.length,
          itemBuilder: (context, index) {
            return BillCard(
              key: ValueKey(bills[index].id),
              bill: bills[index],
              userId: userId,
            );
          },
        );
      },
    );
  }
}
