import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../firebase/user_service.dart';
// import '../../ui/dialogue_box.dart';
//import '../../ui/error_snackbar.dart';



class SetLimits extends StatefulWidget {
  const SetLimits({super.key});
  

  @override
  State<SetLimits> createState() => _SetLimitsState();
}

class _SetLimitsState extends State<SetLimits> {
  final TextEditingController _monthlyLimitController = TextEditingController();
  final TextEditingController _dailyLimitController = TextEditingController();

  late UserService _userService;
  Map<String, dynamic> _userData = {};


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
              'Set your limits',
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
            padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Theme.of(context).primaryColorDark
          ),
          child: Row(
            children:[
              Text('hgfchf')
            ],
          ),
        ),
      ),
    );
  }
}



