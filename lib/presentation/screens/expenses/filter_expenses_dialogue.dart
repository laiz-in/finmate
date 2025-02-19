// FILEPATH: /C:/Users/Hp/Desktop/moneyy - Copy/moneyy/lib/presentation/screens/expenses/filter_expenses_dialogue.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // IMPORT SCREENUTIL
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:moneyy/core/colors/colors.dart';

class FilterBottomSheet extends StatefulWidget {
  final Function(bool) onSortByAmount;
  final Function(String?) onFilterByCategory;
  final Function(DateTime?, DateTime?) onFilterByDate;
  final Function() onClearFilters;

  const FilterBottomSheet({
    required this.onSortByAmount,
    required this.onFilterByCategory,
    required this.onFilterByDate,
    required this.onClearFilters,
  });

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _category;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _sortByAmountEnabled = false;
  bool _sortAscending = true;
  bool _filterByDateEnabled = false;
  bool _filterByCategoryEnabled = false;

  final List<String> categories = [
    'All Categories',
    'Groceries',
    'Stationary',
    'Food',
    'Entertainment',
    'Transport',
    'Bills',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)), // USE SCREENUTIL FOR BORDER RADIUS
      ),
      padding: EdgeInsets.fromLTRB(30.w, 15.h, 30.w, 30.h), // USE SCREENUTIL FOR PADDING
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                height: 3.h, // USE SCREENUTIL FOR HEIGHT
                width: 100.w, // USE SCREENUTIL FOR WIDTH
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor.withOpacity(0.3),
                ),
              ),
            ),

            SizedBox(height: 20.h), // USE SCREENUTIL FOR HEIGHT

            // SORT BY AMOUNT TOGGLE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort by amount',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).canvasColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp, // USE SCREENUTIL FOR FONT SIZE
                  ),
                ),
                CupertinoSwitch(
                  value: _sortByAmountEnabled,
                  onChanged: (value) => setState(() => _sortByAmountEnabled = value),
                  activeColor: AppColors.foregroundColor,
                  thumbColor: Color.fromARGB(255, 231, 230, 230),
                ),
              ],
            ),

            SizedBox(height: 5.h), // USE SCREENUTIL FOR HEIGHT

            if (_sortByAmountEnabled)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSortButton('Low to high', true),
                  SizedBox(width: 10.w), // USE SCREENUTIL FOR WIDTH
                  _buildSortButton('High to low', false),
                ],
              ),

            SizedBox(height: 10.h), // USE SCREENUTIL FOR HEIGHT
            Divider(color: Theme.of(context).canvasColor.withOpacity(0.5)),
            SizedBox(height: 10.h), // USE SCREENUTIL FOR HEIGHT

            // FILTER BY DATE TOGGLE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter by date',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).canvasColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp, // USE SCREENUTIL FOR FONT SIZE
                  ),
                ),
                CupertinoSwitch(
                  value: _filterByDateEnabled,
                  onChanged: (value) {
                    setState(() {
                      _filterByDateEnabled = value;
                    });
                  },
                  activeColor: AppColors.foregroundColor,
                  thumbColor: Color.fromARGB(255, 231, 230, 230),
                ),
              ],
            ),
            SizedBox(height: 10.h), // USE SCREENUTIL FOR HEIGHT
            if (_filterByDateEnabled)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDateButton('From', _startDate, (picked) {
                    setState(() {
                      _startDate = picked;
                    });
                  }),
                  SizedBox(width: 10.w), // USE SCREENUTIL FOR WIDTH
                  _buildDateButton('To', _endDate, (picked) {
                    setState(() {
                      _endDate = picked;
                    });
                  }),
                ],
              ),
            
            SizedBox(height: 12.h), // USE SCREENUTIL FOR HEIGHT
            Divider(color: Theme.of(context).canvasColor.withOpacity(0.5)),
            SizedBox(height: 6.h), // USE SCREENUTIL FOR HEIGHT

            // FILTER BY CATEGORY TOGGLE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter by Category',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).canvasColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp, // USE SCREENUTIL FOR FONT SIZE
                  ),
                ),
                CupertinoSwitch(
                  value: _filterByCategoryEnabled,
                  onChanged: (value) {
                    setState(() {
                      _filterByCategoryEnabled = value;
                    });
                  },
                  activeColor: AppColors.foregroundColor,
                  thumbColor: Color.fromARGB(255, 231, 230, 230),
                ),
              ],
            ),
            SizedBox(height: 10.h), // USE SCREENUTIL FOR HEIGHT
            if (_filterByCategoryEnabled)
              _buildCategoryDropdown(),
            SizedBox(height: 7.h), // USE SCREENUTIL FOR HEIGHT
            Divider(color: Theme.of(context).canvasColor.withOpacity(0.5)),
            SizedBox(height: 12.h), // USE SCREENUTIL FOR HEIGHT

            // CLEAR FILTERS AND APPLY BUTTONS
            Row(
              children: [
                // CLEAR FILTERS BUTTON CONTAINER
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.shade100),
                      borderRadius: BorderRadius.all(Radius.circular(15.r)), // USE SCREENUTIL FOR BORDER RADIUS
                    ),
                    padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 5.w), // USE SCREENUTIL FOR PADDING
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            widget.onClearFilters();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Clear all',
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp, // USE SCREENUTIL FOR FONT SIZE
                              color: Theme.of(context).canvasColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.close,
                          color: Theme.of(context).canvasColor,
                          size: 20.sp, // USE SCREENUTIL FOR SIZE
                        ),
                      ],
                    ),
                  ),
                ),

                // SPACING BETWEEN BUTTONS
                SizedBox(width: 8.w), // USE SCREENUTIL FOR WIDTH

                // APPLY FILTERS BUTTON CONTAINER
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.all(Radius.circular(15.r)), // USE SCREENUTIL FOR BORDER RADIUS
                    ),
                    padding: EdgeInsets.symmetric(vertical: 2.h), // USE SCREENUTIL FOR PADDING
                    child: TextButton(
                      onPressed: () {
                        if (_sortByAmountEnabled) {
                          widget.onSortByAmount(_sortAscending); 
                        }
                        if (_filterByCategoryEnabled) {
                          widget.onFilterByCategory(_category);
                        }
                        if (_filterByDateEnabled) {
                          widget.onFilterByDate(_startDate, _endDate);
                        }
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Apply',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp, // USE SCREENUTIL FOR FONT SIZE
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          
            SizedBox(height: 10.h), // USE SCREENUTIL FOR HEIGHT
            Row(
              children: [
                Icon(Symbols.info, color: Theme.of(context).canvasColor.withOpacity(0.6), size: 15.sp), // USE SCREENUTIL FOR SIZE
                SizedBox(width: 10.w), // USE SCREENUTIL FOR WIDTH
                Text(
                  'Please load all data for effective search',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp, // USE SCREENUTIL FOR FONT SIZE
                    color: Theme.of(context).canvasColor.withOpacity(0.4),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h), // USE SCREENUTIL FOR HEIGHT
          ],
        ),
      ),
    );
  }

  Widget _buildSortButton(String text, bool ascending) {
    return TextButton(
      onPressed: () {
        setState(() {
          _sortAscending = ascending;
        });
      },
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r), // USE SCREENUTIL FOR BORDER RADIUS
        ),
        backgroundColor: _sortAscending == ascending
            ? Theme.of(context).canvasColor
            : Theme.of(context).canvasColor.withOpacity(0.2),
        minimumSize: Size(125.w, 30.h), // USE SCREENUTIL FOR SIZE
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Theme.of(context).primaryColor,
          fontSize: 12.sp, // USE SCREENUTIL FOR FONT SIZE
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime? date, Function(DateTime) onDatePicked) {
    return SizedBox(
      width: 125.w, // USE SCREENUTIL FOR WIDTH
      height: 32.h, // USE SCREENUTIL FOR HEIGHT
      child: TextButton(
        onPressed: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (picked != null) {
            onDatePicked(picked);
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).canvasColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r), // USE SCREENUTIL FOR BORDER RADIUS
          ),
        ),
        child: Text(
          date == null ? label : DateFormat('d/M/y').format(date),
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Theme.of(context).primaryColor,
            fontSize: 12.sp, // USE SCREENUTIL FOR FONT SIZE
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      width: double.infinity,
      height: 40.h, // USE SCREENUTIL FOR HEIGHT
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).canvasColor, width: 1.w), // USE SCREENUTIL FOR BORDER WIDTH
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(15.r), // USE SCREENUTIL FOR BORDER RADIUS
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.w, 8.h, 8.w, 8.h), // USE SCREENUTIL FOR PADDING
              child: DropdownButton<String>(
                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                icon: Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor, size: 15.sp), // USE SCREENUTIL FOR SIZE
                borderRadius: BorderRadius.circular(20.r), // USE SCREENUTIL FOR BORDER RADIUS
                value: _category,
                underline: Container(),
                style: GoogleFonts.poppins(color: Theme.of(context).primaryColor),
                hint: Text(
                  'Select Category',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).canvasColor,
                    fontSize: 15.sp, // USE SCREENUTIL FOR FONT SIZE
                    fontWeight: FontWeight.w500,
                  ),
                ),
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 0.h), // USE SCREENUTIL FOR PADDING
                      child: Text(
                        category,
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).canvasColor,
                          fontSize: 15.sp, // USE SCREENUTIL FOR FONT SIZE
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _category = newValue == 'All Categories' ? null : newValue;
                  });
                },
              ),
            ),
          ),
          Transform.rotate(
            angle: 1.5708, // 90 DEGREES IN RADIANS
            child: Icon(
              Icons.arrow_forward_ios,
              size: 17.sp, // USE SCREENUTIL FOR SIZE
              color: Theme.of(context).canvasColor,
            ),
          ),
          SizedBox(width: 10.w), // USE SCREENUTIL FOR WIDTH
        ],
      ),
    );
  }
}