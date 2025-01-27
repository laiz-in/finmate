import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  UserEntity? _user; // HOLDS USER DATA
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
        // OPTIONALLY HANDLE THE ERROR (E.G., SHOW A SNACKBAR)
      },
      (user) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      },
    );
  }

  

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.transparent,));
    }

    return Container(
      padding: EdgeInsets.fromLTRB(15.w, 5.h, 5.w, 5.h), // PADDING
      margin: EdgeInsets.fromLTRB(15.w,0,15.w,0), // MARGIN
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 122, 121, 121).withOpacity(0.10),
            spreadRadius: 10.r,
            blurRadius: 8.r,
            offset: const Offset(2, 4), // CHANGES POSITION OF SHADOW
          ),
        ],
        color: Theme.of(context).hintColor,
        borderRadius: BorderRadius.circular(20.r), // RADIUS
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).canvasColor,
            radius: 30.r, // RADIUS
            child: Icon(
              Icons.person,
              size: 40.sp, // ICON SIZE
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(width: 20.w), // SPACING

          Expanded(
            child: SizedBox(
              height: 100.h, // HEIGHT
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp, // FONT SIZE
                      height: 1.h,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).canvasColor.withOpacity(0.5),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${_user?.firstName} ${_user?.lastName}',
                        style: GoogleFonts.poppins(
                          height: 0.5.h, // MATCHES THE LINE HEIGHT TO REMOVE GAPS
                          fontSize: 14.sp, // FONT SIZE
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).canvasColor,
                        ),
                      ),
                      SizedBox(width: 5.w), // SPACING
                      Icon(
                        Symbols.waving_hand,
                        size: 20.sp, // ICON SIZE
                        color: Theme.of(context).canvasColor.withOpacity(0.6),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h), // SPACING
                  Divider(
                    color: Theme.of(context).canvasColor.withOpacity(0.2),
                    endIndent: 10.w,
                  ),
                  Row(
                    children: [
                      Icon(
                        Symbols.email,
                        size: 15.sp, // ICON SIZE
                        color: Theme.of(context).canvasColor.withOpacity(0.5),
                      ),
                      SizedBox(width: 5.w), // SPACING
                      Expanded(
                        child: Text(
                          _user!.email ?? "email id",
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp, // FONT SIZE
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).canvasColor.withOpacity(0.5),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
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