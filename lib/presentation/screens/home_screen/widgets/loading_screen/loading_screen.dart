import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyy/presentation/routes/routes.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerScreen extends StatelessWidget {
  const ShimmerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        toolbarHeight: 80.h, // TOOLBAR HEIGHT
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,

        // ACTION BUTTONS
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Theme.of(context).canvasColor,
              size: 23.sp, // ICON SIZE
            ),
            onPressed: () {
              // ADD YOUR NOTIFICATION LOGIC HERE
            },
          ),
          IconButton(
            icon: Icon(
              Icons.person_outlined,
              color: Theme.of(context).canvasColor,
              size: 23.sp, // ICON SIZE
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profileScreen);
            },
          ),
          SizedBox(width: 20.w), // SPACING
        ],
      ),

      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.fromLTRB(15.w, 0, 15.w, 0), // PADDING
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20.h), // SPACING

              // FOR TITLE CARD
              Shimmer.fromColors(
                baseColor: Theme.of(context).highlightColor.withOpacity(0.7),
                highlightColor: Theme.of(context).highlightColor.withOpacity(0.6),
                child: Container(
                  width: double.infinity,
                  height: 205.h, // HEIGHT
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20.r)), // BORDER RADIUS
                    color: Theme.of(context).highlightColor,
                    shape: BoxShape.rectangle,
                  ),
                ),
              ),

              SizedBox(height: 32.h), // SPACING

              // FOR PERCENTAGE INDICATOR
              Shimmer.fromColors(
                baseColor: Theme.of(context).highlightColor.withOpacity(0.7),
                highlightColor: Theme.of(context).highlightColor.withOpacity(0.6),
                child: Container(
                  width: double.infinity,
                  height: 165.h, // HEIGHT
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20.r)), // BORDER RADIUS
                    color: Theme.of(context).highlightColor,
                    shape: BoxShape.rectangle,
                  ),
                ),
              ),

              SizedBox(height: 12.h), // SPACING

              // FOR BAR CHART
              Shimmer.fromColors(
                baseColor: Theme.of(context).highlightColor.withOpacity(0.7),
                highlightColor: Theme.of(context).highlightColor.withOpacity(0.6),
                child: Container(
                  width: double.infinity,
                  height: 120.h, // HEIGHT
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15.r)), // BORDER RADIUS
                    color: Theme.of(context).highlightColor,
                  ),
                ),
              ),

              SizedBox(height: 37.h), // SPACING

              // FOR ROW OF SHIMMER CONTAINERS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Shimmer.fromColors(
                    baseColor: Theme.of(context).highlightColor.withOpacity(0.8),
                    highlightColor: Theme.of(context).highlightColor.withOpacity(0.7),
                    child: Container(
                      width: 150.w, // WIDTH
                      height: 15.h, // HEIGHT
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15.r)), // BORDER RADIUS
                        color: Theme.of(context).highlightColor,
                        shape: BoxShape.rectangle,
                      ),
                    ),
                  ),
                  Shimmer.fromColors(
                    baseColor: Theme.of(context).highlightColor.withOpacity(0.7),
                    highlightColor: Theme.of(context).highlightColor.withOpacity(0.6),
                    child: Container(
                      width: 100.w, // WIDTH
                      height: 15.h, // HEIGHT
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15.r)), // BORDER RADIUS
                        color: Theme.of(context).highlightColor,
                        shape: BoxShape.rectangle,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 17.h), // SPACING

              // FOR LARGE SHIMMER CONTAINER
              Shimmer.fromColors(
                baseColor: Theme.of(context).highlightColor.withOpacity(0.7),
                highlightColor: Theme.of(context).highlightColor.withOpacity(0.6),
                child: Container(
                  width: double.infinity,
                  height: 175.h, // HEIGHT
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20.r)), // BORDER RADIUS
                    color: Theme.of(context).highlightColor,
                    shape: BoxShape.rectangle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}