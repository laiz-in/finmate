import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/bloc/bills/bills_bloc.dart';
import 'package:moneyy/bloc/bills/bills_event.dart';
import 'package:moneyy/bloc/bills/bills_state.dart';
import 'package:moneyy/common/widgets/basicAppbar.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/core/colors/colors.dart';
import 'package:moneyy/presentation/screens/bills/add_bills_dialogue.dart';
import 'package:moneyy/presentation/screens/bills/each_bills_card.dart';
import 'package:vs_scrollbar/vs_scrollbar.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  BillScreenSatate createState() => BillScreenSatate();
}

class BillScreenSatate extends State<BillScreen> {
  final ScrollController _scrollController = ScrollController();
  String searchQuery = '';
  String? activeFilter = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillsBloc>().add(ResetBillsEvent());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


  void _fetchBills() {
    context.read<BillsBloc>().add(FetchAllBillsEvent());
  }

  void _clearFilters() {
    setState(() => searchQuery = '');
    context.read<BillsBloc>().add(ClearFiltersEvent());

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchAndFilterBar(),
            // _buildQuickFilterRow(),
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
              child: AddBillsBottomSheet(),
            );
          },
        ),
        backgroundColor: AppColors.foregroundColor,
        elevation: 5,
        child: Icon(Icons.add, color: Colors.white, size: 40),
      ),
    );
  }

  Widget _buildAppBar() {
    return CommonAppBar(heading: 'All Bills');
  }


  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.fromLTRB(15, 12, 15, 10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 65, 64, 64).withOpacity(0.10),
            offset: const Offset(0, 4),
            blurRadius: 10.0,
            spreadRadius: 3.0,
          ),
        ],
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.search,
                      color: Theme.of(context).canvasColor.withOpacity(0.5)),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextField(
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).canvasColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      cursorColor:
                          Theme.of(context).canvasColor.withOpacity(0.5),
                      onChanged: (value) {
                        setState(() => searchQuery = value);
                        context
                            .read<BillsBloc>()
                            .add(SearchBillsEvent(searchQuery));
                      },
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: GoogleFonts.poppins(
                          color:
                              Theme.of(context).canvasColor.withOpacity(0.5),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.sort,
                        color: Theme.of(context).canvasColor, size: 30),
                    onPressed: () {
                      // showModalBottomSheet(
                      //   backgroundColor: Theme.of(context).primaryColor,
                      //   // shape: RoundedRectangleBorder(
                      //   //   borderRadius: BorderRadius.only(
                      //   //     topLeft: Radius.circular(30),
                      //   //     topRight: Radius.circular(30),
                      //   //   ),
                      //   // ),
                      //   // context: context,
                      //   // isScrollControlled: true,
                      //   // builder: (_) => FilterBottomSheet(
                      //   //   onClearFilters: _clearFilters,
                      //   //   onSortByBillAmount: (ascending) {
                      //   //     context
                      //   //         .read<BillsBloc>()
                      //   //         .add(SortByBillAmount(ascending));
                      //   //   },
                      //   //   onSortByDueDate: (ascending) {
                      //   //     context
                      //   //         .read<BillsBloc>()
                      //   //         .add(SortByDueDate(ascending));
                      //   //   },
                          
                      //   // ),
                      // );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillsList() {
  return BlocConsumer<BillsBloc, BillState>(
    listener: (context, state) {
      if (state is BillsError) {
        errorSnackbar(context, state.message);
      }
    },
    builder: (context, state) {
      // Show loading indicator during initial load
      if (state is BillsLoading && state.isFirstFetch) {
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).canvasColor
          )
        );
      }
      
      // Show loaded expenses
      else if (state is BillsLoaded) {
        final bills = state.bills;

        // Show a message if no expenses are found
        if (bills.isEmpty) {
          return _buildEmptyBillsMessage();
        }

        // Show the list of expenses with "Load More" button if more items are available
        return RefreshIndicator(
          backgroundColor: Colors.transparent,
          color: Colors.white,
          strokeWidth: 2,
          displacement: 50,
          onRefresh: () async {

            context.read<BillsBloc>().add(RefreshBillsEvent());
          },
          child: VsScrollbar(
            scrollbarTimeToFade: Duration(milliseconds: 800),// default : Duration(milliseconds: 600)
            controller: _scrollController, // Attach the scroll controller
            isAlwaysShown:  false, // default false
            showTrackOnHover: true,// default false
            style: VsScrollbarStyle(
              
              color: Theme.of(context).canvasColor.withOpacity(0.8),
              thickness: 5
            ),
            child: ListView.builder(
              controller: _scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: bills.length + (state.hasMore && searchQuery.isEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < bills.length) {
                  final bill = bills[index];
                  return BillCard(
                    bill: bill,
                    onUpdate: () => _fetchBills(),
                    onDelete: () {
                      context.read<BillsBloc>().add(DeleteBillsEvent(bill.uidOfBill));
                      _fetchBills();
                    },
                  );
                }
                
                // Display "Load More" button
                else if (state.hasMore && searchQuery.isEmpty&& bills.length >=30)
                {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<BillsBloc>().add(LoadMoreBillsEvent());
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Button color
                        ),
                        child: Text(
                          'Load More',
                          style: GoogleFonts.poppins(
                            color:Theme.of(context).canvasColor.withOpacity(0.7 ),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                
                // Show an empty widget if no more items are available
                else {
                  return SizedBox.shrink();
                }
              },
            ),
          ),
        );
      }
      
      // Display error message if loading fails
      else if (state is BillsError) {
        return _buildErrorMessage();
      }

      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).canvasColor
        )
      );
    },
  );
}

  Widget _buildEmptyBillsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.disabled_by_default,
              size: 60, color: Theme.of(context).canvasColor.withOpacity(0.2)),
          Text(
            'No Bills Found!',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).canvasColor.withOpacity(0.7),
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
          Icon(Icons.error,
              size: 60, color: Theme.of(context).canvasColor.withOpacity(0.2)),
          Text(
            'Error while loading!',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).canvasColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}