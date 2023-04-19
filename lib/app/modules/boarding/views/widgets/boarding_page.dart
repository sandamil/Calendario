import 'package:calendario2/app/data/model/boarding_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BoardingPage extends StatelessWidget {
  const BoardingPage({
    Key? key,
    required this.data,
  }) : super(key: key);
  final BoardingModel data;
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 1,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(data.imagePath),
            fit: BoxFit.fill,
          ),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
              child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 50.h, left: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      data.subTitle,
                      style: TextStyle(
                          fontSize: 25.sp,
                          color: Colors.white.withOpacity(0.60),
                          fontFamily: 'Bebas'),
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                    Text(
                      data.title,
                      style: TextStyle(
                          fontSize: 50.sp,
                          color: Colors.white.withOpacity(0.60),
                          fontFamily: 'Bebas'),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 30.w),
                      child: Text(
                        data.description,
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white.withOpacity(0.80),
                            fontFamily: 'Lato'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
