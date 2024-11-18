import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
      ),
      padding: const EdgeInsets.fromLTRB(30,15,30,30),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

      
              Center(
                child: Container(
                  height: 3,
                  width:100 ,
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor.withOpacity(0.3)
                  ),
                ),
              ),

            SizedBox(height: 20,),
            // Sort by amount toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort by amount',
                  style: GoogleFonts.poppins(
                      color: Theme.of(context).canvasColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14),
                ),
                CupertinoSwitch(
                  value: _sortByAmountEnabled,
                  onChanged: (value) =>
                      setState(() => _sortByAmountEnabled = value),
                  activeColor: AppColors.foregroundColor,
                  thumbColor: Color.fromARGB(255, 231, 230, 230),
                ),
              ],
            ),

            const SizedBox(height: 5),

            if (_sortByAmountEnabled)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSortButton('Low to high', true),
                  SizedBox(width: 10),
                  _buildSortButton('High to low', false),
                ],
              ),

            const SizedBox(height: 10),
            Divider(color: Theme.of(context).canvasColor.withOpacity(0.5)),
            const SizedBox(height: 10),

            // Filter by date toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter by date',
                  style: GoogleFonts.poppins(
                      color: Theme.of(context).canvasColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14),
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
            const SizedBox(height: 10),
            if (_filterByDateEnabled)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDateButton('From', _startDate, (picked) {
                    setState(() {
                      _startDate = picked;
                    });
                  }),
                  SizedBox(width: 10),
                  _buildDateButton('To', _endDate, (picked) {
                    setState(() {
                      _endDate = picked;
                    });
                  }),
                ],
              ),
            
            const SizedBox(height:12),
            Divider(color: Theme.of(context).canvasColor.withOpacity(0.5)),
            const SizedBox(height: 6),

            // Filter by category toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter by Category',
                  style: GoogleFonts.poppins(
                      color: Theme.of(context).canvasColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14),
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
            const SizedBox(height: 10),
            if (_filterByCategoryEnabled)
              _buildCategoryDropdown(),
            const SizedBox(height: 7),
            Divider(color: Theme.of(context).canvasColor.withOpacity(0.5)),
            const SizedBox(height: 12),

            // Clear filters and Apply buttons
            Row(
              children: [
                // Clear filters button container
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).canvasColor),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 5,),
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
                              fontSize: 15,
                              color: Theme.of(context).canvasColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.close,
                          color: Theme.of(context).canvasColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                // Spacing between buttons
                const SizedBox(width: 8),

                // Apply filters button container
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 2),
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
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildSortButton(String text, bool ascending) {
    return TextButton(
      onPressed: () {
        setState(() {
          _sortAscending = ascending;
        });
      },
      
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          
          borderRadius: BorderRadius.circular(10.0),
        ),
        
        backgroundColor: _sortAscending == ascending
            ? Theme.of(context).canvasColor
            : Theme.of(context).canvasColor.withOpacity(0.2),
        minimumSize: const Size(125, 30),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Theme.of(context).primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime? date, Function(DateTime) onDatePicked) {
    return SizedBox(
      width: 125.0,
      height: 32.0,
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
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Text(
          date == null ? label : DateFormat('d/M/y').format(date),
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
              color: Theme.of(context).primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).canvasColor,width: 1),
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10,8,8,8),
              child: DropdownButton<String>(
                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                icon: Icon(Icons.arrow_forward_ios,color: Theme.of(context).primaryColor,size: 15,),
                borderRadius: BorderRadius.circular(20),
                value: _category,
                underline: Container(),
                style: GoogleFonts.poppins(color: Theme.of(context).primaryColor),
                hint: Text(
                  'Select Category',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      color: Theme.of(context).canvasColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0, 0, 0),
                      child: Text(
                        category,
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).canvasColor,
                          fontSize: 15.0,
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
          angle: 1.5708, // 90 degrees in radians
          child: Icon(
            Icons.arrow_forward_ios,
            size: 17,
            color: Theme.of(context).canvasColor,
          ),
        ),          SizedBox(width: 10,)
        ],
      ),
    );
  }
}
