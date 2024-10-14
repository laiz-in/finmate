import 'package:flutter/material.dart';
import 'package:moneyy/presentation/routes/routes.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerScreen extends StatelessWidget {
  const ShimmerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      toolbarHeight: 80,
      scrolledUnderElevation:0,
      automaticallyImplyLeading: false,
      // Title text
      
      // Action button
      actions: [IconButton(
        icon: Icon(Icons.notification_add_outlined, color:Theme.of(context).canvasColor,size: 25,),
        onPressed: () {
          // Add your notification logic here
        },
      ),
        IconButton(
          icon: Icon(Icons.person_outlined, color:Theme.of(context).canvasColor,size: 25,),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.profileScreen);
          },
        ),
        SizedBox(width: 20,),
      ],
    ),
    
    
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.fromLTRB(15,0,15,0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
          
            children: [
              SizedBox(height: 30,),
          
              Shimmer.fromColors(
                baseColor: Theme.of(context).highlightColor,
                highlightColor: Theme.of(context).highlightColor.withOpacity(0.7),
                child: Container(
                  width: double.infinity,
                  height: 205,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color:  Theme.of(context).highlightColor,
                    shape: BoxShape.rectangle,
                  ),
                ),
              ),
          
              SizedBox(height: 32),
          
              Shimmer.fromColors(
                baseColor:  Theme.of(context).highlightColor,
                highlightColor: Theme.of(context).highlightColor.withOpacity(0.7),
                child: Container(
                  width: double.infinity,
                  height: 165,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Theme.of(context).highlightColor,
                    shape: BoxShape.rectangle,
                  ),
                ),
              ),
          
              SizedBox(height: 12,),
              
                Shimmer.fromColors(
                baseColor: Theme.of(context).highlightColor,
                highlightColor:  Theme.of(context).highlightColor.withOpacity(0.7),
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color:  Theme.of(context).highlightColor,
                    shape: BoxShape.rectangle,
                  ),
                ),
              ),
          
              SizedBox(height: 37,),
          
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Shimmer.fromColors(
          
                baseColor: Theme.of(context).highlightColor,
                highlightColor: Theme.of(context).highlightColor.withOpacity(0.7),
                child: Container(
                  width:150,
                  height: 15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Theme.of(context).highlightColor,
                    shape: BoxShape.rectangle,
                  ),
                ),
              ),
          
              Shimmer.fromColors(
                
                baseColor: Theme.of(context).highlightColor,
                highlightColor: Theme.of(context).highlightColor.withOpacity(0.7),
                child: Container(
                  width: 100,
                  height: 15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Theme.of(context).highlightColor,
                    shape: BoxShape.rectangle,
                  ),
                ),
              ),
          
                ],
              ),
          
              SizedBox(height: 17,),
          
              Shimmer.fromColors(
                baseColor: Theme.of(context).highlightColor,
                highlightColor: Theme.of(context).highlightColor.withOpacity(0.7),
                child: Container(
                  width: double.infinity,
                  height: 175,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
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
