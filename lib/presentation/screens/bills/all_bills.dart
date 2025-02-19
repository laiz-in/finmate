import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:moneyy/bloc/bills/bills_bloc.dart';
import 'package:moneyy/bloc/bills/bills_event.dart';
import 'package:moneyy/bloc/bills/bills_state.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/core/colors/colors.dart';
import 'package:moneyy/presentation/screens/bills/add_bills_dialogue.dart';
import 'package:moneyy/presentation/screens/bills/each_bills_card.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  BillScreenState createState() => BillScreenState();
}

class BillScreenState extends State<BillScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  String searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillsBloc>().add(FetchAllBillsEvent()); // Load all bills by default
    });
    _tabController.addListener(() {
      _handleTabSelection();
    });
  }

  @override
  void dispose() {
      _tabController.removeListener(_handleTabSelection);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.index == 0) {
      context.read<BillsBloc>().add(FetchAllBillsEvent());
    } else if (_tabController.index == 1) {
      context.read<BillsBloc>().add(FilterByPaidStatusEvent(paidStatus: 0)); // Pending
    } else if (_tabController.index == 2) {
      context.read<BillsBloc>().add(FilterByPaidStatusEvent(paidStatus: 1)); // Paid
    }
  }

  void _fetchBills() {
    context.read<BillsBloc>().add(FetchAllBillsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // APP BAR
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.h), // ADJUST THIS HEIGHT AS NEEDED
        child: AppBar(
          automaticallyImplyLeading: false, // Disable automatic back button
          scrolledUnderElevation: 0,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Container(
            alignment: Alignment.bottomLeft, // ALIGN TITLE TO THE BOTTOM-LEFT
            child: Text(
              ' Bills ',
              style: GoogleFonts.poppins(
                fontSize: 22.sp, // FONT SIZE
                fontWeight: FontWeight.w500,
                color: Theme.of(context).canvasColor,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        
        child: Column(
          children: [
            _buildSearchBar(),
            _buildTabBar(),
            Expanded(child: _buildBillsList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: const AddBillsBottomSheet(),
            );
          },
        ),
        backgroundColor: AppColors.foregroundColor,
        elevation: 5,
        child: Icon(Icons.add, color: Colors.white, size: 40.sp),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(1.w),
      margin: EdgeInsets.fromLTRB(15.w, 8.h, 15.w, 10.h),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 90, 89, 89).withOpacity(0.10),
            offset: const Offset(2, 4),
            blurRadius: 15.0.r,
            spreadRadius: 5.0.r,
          ),
        ],
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(15.r)),
      ),
      child: Row(
        children: [
          SizedBox(width: 10.w,),
          Icon(
            Icons.search,
            color: Theme.of(context).canvasColor.withOpacity(0.5),
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              style: GoogleFonts.poppins(
                color: Theme.of(context).canvasColor,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: Theme.of(context).canvasColor.withOpacity(0.5),
              onChanged: (value) {
                setState(() => searchQuery = value);
                context.read<BillsBloc>().add(SearchBillsEvent(searchQuery));
              },
              decoration: InputDecoration(
                hintText: 'search..',
                hintStyle: GoogleFonts.poppins(
                  color: Theme.of(context).canvasColor.withOpacity(0.5),
                  fontSize: 14.sp,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      padding: EdgeInsets.only(bottom: 10.h),
      dividerColor: Theme.of(context).canvasColor.withOpacity(0.3),
      dividerHeight: 1.h,
      controller: _tabController,
      indicatorColor: Theme.of(context).canvasColor,
      labelColor: Theme.of(context).canvasColor,
      unselectedLabelColor: Theme.of(context).canvasColor.withOpacity(0.5),
      labelStyle: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w500),
      tabs: const [
        Tab(text: 'All Bills',),
        Tab(text: 'Pending Bills'),
        Tab(text: 'Paid Bills'),
      ],
    );
  }

Widget _buildBillsList() {
  return RefreshIndicator(
    backgroundColor: Colors.transparent,
    color: Colors.white,
    strokeWidth: 2.w, // STROKE WIDTH
    displacement: 50.h, // DISPLACEMENT
    onRefresh: () async {
      if (_tabController.index != 0) {
        setState(() {
          _tabController.index = 0;
        });
      }
      _fetchBills();
    },
    child: BlocConsumer<BillsBloc, BillState>(
      listener: (context, state) {
        if (state is BillsError) {
          errorSnackbar(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is BillsLoading && state.isFirstFetch) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              color: Theme.of(context).canvasColor,
            ),
          );
        } else if (state is BillsLoaded) {
          final bills = state.bills;
          if (bills.isEmpty) return _buildEmptyBillsMessage();

          return ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];
              return BillCard(
                bill: bill,
                onUpdate: () => _fetchBills(),
                onDelete: () {
                  context.read<BillsBloc>().add(DeleteBillsEvent(bill.uidOfBill));
                  _fetchBills();
                },
              );
            },
          );
        } else if (state is BillsError) {
          return _buildErrorMessage();
        }

        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.w,
            color: Theme.of(context).canvasColor,
          ),
        );
      },
    ),
  );
}


  Widget _buildEmptyBillsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Symbols.search_off,
            size: 80.sp,
            color: Theme.of(context).canvasColor.withOpacity(0.2),
          ),
          Text(
            'No bills found!',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).canvasColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: 60.sp,
            color: Theme.of(context).canvasColor.withOpacity(0.2),
          ),
          Text(
            'Error while loading!',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).canvasColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
