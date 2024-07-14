// ignore_for_file: unnecessary_string_interpolations

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyy/styles/themes.dart';

class FilterDialog extends StatefulWidget {
  final Function(double?, bool) onSortByAmount;
  final Function(String?) onFilterByCategory;
  final Function(DateTime?, DateTime?) onFilterByDate;

  FilterDialog({
    required this.onSortByAmount,
    required this.onFilterByCategory,
    required this.onFilterByDate,
  });

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  double? _amount;
  String? _category;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _sortByAmountEnabled = false;
  bool _sortAscending = true;
  bool _filterByDateEnabled = false;
  bool _filterByCategoryEnabled = false;
  List<String> categories = [
    'All Categories',
    'Groceries',
    'Stationary',
    'Food',
    'Entertainment',
    'Transport',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26.0),
        
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Sort by amount toggle switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort by amount',
                  style: GoogleFonts.montserrat(
                      color: Theme.of(context).cardColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
                CupertinoSwitch(
                  value: _sortByAmountEnabled,
                  onChanged: (value) =>
                      setState(() => _sortByAmountEnabled = value),
                  activeColor: Theme.of(context).cardColor,
                  thumbColor: Theme.of(context).primaryColor,
                )
              ],
            ),
            if (_sortByAmountEnabled)
            Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Distribute evenly
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _sortAscending = true;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: _sortAscending
                          ? Theme.of(context).cardColor
                          :Theme.of(context).cardColor.withOpacity(0.4),
                      foregroundColor: _sortAscending
                          ? Theme.of(context).cardColor.withOpacity(0.4)
                          : Theme.of(context).cardColor,
                      minimumSize: Size(110, 30), // Fixed width and height
                    ),
                    child: Text(
                      'Low to high',
                      style: GoogleFonts.montserrat(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        _sortAscending = false;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: !_sortAscending
                          ? Theme.of(context).cardColor
                          : Theme.of(context).cardColor.withOpacity(0.4),
                      foregroundColor: _sortAscending
                          ? AppColors.myFadeblue
                          : Theme.of(context).cardColor.withOpacity(0.4),
                      minimumSize: Size(110, 30), // Fixed width and height
                    ),
                    child: Text(
                      'High to low',
                      style: GoogleFonts.montserrat(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            
            SizedBox(height: 10),
            Divider(color: Theme.of(context).cardColor,endIndent: 0,),
            SizedBox(height: 10),

            // Filter by date toggle switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter by date',
                  style: GoogleFonts.montserrat(
                      color: Theme.of(context).cardColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
                CupertinoSwitch(
                  value: _filterByDateEnabled,
                  onChanged: (value) {
                    setState(() {
                      _filterByDateEnabled = value;
                    });
                  },
                  activeColor: Theme.of(context).cardColor,
                  thumbColor:Theme.of(context).primaryColor ,
                )
              ],
            ),
            SizedBox(height: 8),
            if (_filterByDateEnabled)
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 110.0,
                    height: 30.0,
                    child: TextButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() {
                            _startDate = picked;
                          });
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                      child: Text(
                        _startDate == null
                            ? 'From'
                            : '${DateFormat('d/M/y').format(_startDate!)}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 110.0,
                    height: 30.0,
                    child: TextButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() {
                            _endDate = picked;
                          });
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                      child: Text(
                        _endDate == null
                            ? 'To'
                            : '${DateFormat('d/M/y').format(_endDate!)}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            
            SizedBox(height: 6),
            Divider(color: Theme.of(context).cardColor,endIndent: 0,),
            SizedBox(height: 6),
            
            // Filter by categpory toggle button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter by Category',
                  style: GoogleFonts.montserrat(
                      color: Theme.of(context).cardColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
                CupertinoSwitch(
                  value: _filterByCategoryEnabled,
                  onChanged: (value) {
                    setState(() {
                      _filterByCategoryEnabled = value;
                    });
                  },
                  activeColor: Theme.of(context).cardColor,
                  thumbColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
            SizedBox(height: 12),
            if (_filterByCategoryEnabled)
                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Container(
                  width: 232,
                  height: 30,
                  decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child:
                  
                  DropdownButton<String>(
                    dropdownColor: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    value: _category,
                    underline: Container(),
                    icon: Icon(
                      Icons.arrow_forward_ios, size: 14,// Use the downward arrow icon
                      color: Theme.of(context).primaryColor, // Set the desired color (e.g., red)
                    ),
                    hint: Text(
                      '                Select Category',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(color: Theme.of(context).primaryColor,
                    fontSize: 12,fontWeight: FontWeight.w600),
                    ),
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(

                        value: category,
                        child: Padding(
                        padding: const EdgeInsets.fromLTRB(48.0,0,0,0), // Adjust padding as needed
                        child: Text(
                          category,
                          style: GoogleFonts.montserrat(
                            color: Theme.of(context).primaryColor,
                            fontSize: 15.0, // Adjust font size as needed
                            fontWeight: FontWeight.w600,
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
              ],
            ),

            SizedBox(height: 10,),
            Divider(color: Theme.of(context).cardColor,endIndent: 0,),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel', style: GoogleFonts.montserrat(color: const Color.fromARGB(255, 202, 109, 109),fontWeight: FontWeight.w600)),
        ),
        ElevatedButton(
        style: ButtonStyle(
            
            backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).cardColor),
          ),
          child: Text('Apply',
          style: GoogleFonts.montserrat(fontSize: 14,
          color:Theme.of(context).primaryColor,fontWeight:  FontWeight.w600)
          ),
          onPressed: () {
            if (_sortByAmountEnabled) {
              widget.onSortByAmount(_amount, _sortAscending);
            }
            if (_filterByCategoryEnabled) {
              widget.onFilterByCategory(_category);
            }
            if (_filterByDateEnabled) {
              widget.onFilterByDate(_startDate, _endDate);
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
