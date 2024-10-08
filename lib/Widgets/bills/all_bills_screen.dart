import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
          toolbarHeight: 50,
          iconTheme: IconThemeData(
            color: Theme.of(context).cardColor,
            size: 30,
          ),
          backgroundColor: Colors.white,
          title: Text(
            "Bills",
            style: GoogleFonts.montserrat(
              color: Theme.of(context).cardColor,
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "All Bills"),
              Tab(text: "Upcoming Bills"),
              Tab(text: "Paid Bills"),
            ],
            labelColor: Theme.of(context).cardColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).cardColor,
            labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 17),
            unselectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: user == null
          ? Center(child: Text("Please log in to see your bills.", style: TextStyle(color: Theme.of(context).cardColor)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBillList(user.uid, null), // All Bills
                _buildBillList(user.uid, false), // Upcoming Bills
                _buildBillList(user.uid, true), // Paid Bills
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
        child: Icon(Icons.add, color: Theme.of(context).primaryColor, size: 30),
      ),
    );
  }

  Widget _buildBillList(String userId, bool? isPaid) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('bills');

    if (isPaid != null) {
      query = query.where('paidStatus', isEqualTo: isPaid ? 1 : 0);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error fetching bills.", style: TextStyle(color: Theme.of(context).cardColor)));
        }
        final bills = snapshot.data?.docs ?? [];
        if (bills.isEmpty) {
          return Center(child:Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Lottie.asset(
          'assets/animations/nobills.json',
          width: 180,
          height: 180,
          fit: BoxFit.fill,
        ),
        Text("No bills to show",style: GoogleFonts.montserrat(fontSize:20, color:Theme.of(context).cardColor.withOpacity(0.7)),)

          ],
          ));
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
