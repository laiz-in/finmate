import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:moneyy/domain/entities/auth/user.dart';

import '../../../data/sources/home/home_firebase_services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserEntity? _user; // Holds user data
  bool _isLoading = true;

  final FirebaseHomeService _firebaseHomeService = FirebaseHomeService();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final result = await _firebaseHomeService.fetchCurrentUserData();
    result.fold(
      (error) {
        setState(() {
          _isLoading = false;
        });
        // Optionally handle the error (e.g., show a snackbar)
      },
      (user) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      },
    );
  }


  Future<void> _editName(String fieldName) async {
    TextEditingController controller = TextEditingController();
    String? result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $fieldName"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: "Enter new $fieldName"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        if (fieldName == "First Name") {
          _user = _user?.copyWith(firstName: result);
        } else if (fieldName == "Last Name") {
          _user = _user?.copyWith(lastName: result);
        }
        // Update Firestore here if needed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: EdgeInsets.fromLTRB(15,5,5,5),
      margin: EdgeInsets.only(bottom:6),
      decoration: BoxDecoration(
        boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 122, 121, 121).withOpacity(0.10
                  ),
                  spreadRadius: 10,
                  blurRadius: 8,
                  offset: Offset(2, 4), // changes position of shadow
                ),
              ],
        color: Theme.of(context).hintColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [

          CircleAvatar(
            backgroundColor: Theme.of(context).canvasColor,
            radius: 30,
            child:  Icon(Icons.person,size: 40,color: Theme.of(context).primaryColor,),
          ),
          
          const SizedBox(width: 20),

          Expanded(
            child: Container(
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              
                  Text("Hello",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).canvasColor.withOpacity(0.5)
                  ),),
              
                  Row(
                    children: [
                      Text(
                          ('${_user?.firstName} ${_user?.lastName}'),
                  
                          style: GoogleFonts.poppins(
                            height: 0.5, // Matches the line height to remove gaps
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).canvasColor,
                          ),
                        ),
                        SizedBox(width: 5,),
                      Icon(
                        Symbols.waving_hand, size: 20,color: Theme.of(context).canvasColor.withOpacity(0.6),),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Divider(color: Theme.of(context).canvasColor.withOpacity(0.2),endIndent: 10,),
                  Row(
                    children: [
                      Icon(
                        Symbols.email, size: 15,color: Theme.of(context).canvasColor.withOpacity(0.5),),
                        SizedBox(width: 5,),
                      Text(_user!.email?? "email id",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).canvasColor.withOpacity(0.5)
                      ),),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
