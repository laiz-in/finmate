import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.fromLTRB(15,0,15,15),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
          
            children: [
          
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: double.infinity,
                  height: 175,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.grey,
                    shape: BoxShape.rectangle,
                    border: Border.all(color: Colors.grey, width: 5),
                  ),
                ),
              ),
          
              SizedBox(height: 37),
          
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.grey,
                    shape: BoxShape.rectangle,
                    border: Border.all(color: Colors.grey, width: 5),
                  ),
                ),
              ),
          
              SizedBox(height: 12,),
              
                Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: double.infinity,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Colors.grey,
                    shape: BoxShape.rectangle,
                    border: Border.all(color: Colors.grey, width: 5),
                  ),
                ),
              ),
          
              SizedBox(height: 37,),
          
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Shimmer.fromColors(
          
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width:150,
                  height: 15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Colors.grey,
                    shape: BoxShape.rectangle,
                    border: Border.all(color: Colors.grey, width: 5),
                  ),
                ),
              ),
          
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 100,
                  height: 15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Colors.grey,
                    shape: BoxShape.rectangle,
                    border: Border.all(color: Colors.grey, width: 5),
                  ),
                ),
              ),
          
                ],
              ),
          
              SizedBox(height: 17,),
          
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: double.infinity,
                  height: 175,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.grey,
                    shape: BoxShape.rectangle,
                    border: Border.all(color: Colors.grey, width: 5),
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
