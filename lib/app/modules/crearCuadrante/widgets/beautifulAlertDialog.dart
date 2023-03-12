import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BeautifulAlertDialog extends StatelessWidget {
  const BeautifulAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.only(right: 16.0),
          height: 250.h,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100.r),
                  bottomLeft: Radius.circular(100.r),
                  topRight: Radius.circular(10.r),
                  bottomRight: Radius.circular(10.r))),
          child: Row(
            children: <Widget>[
              SizedBox(width: 20.w),
              CircleAvatar(
                radius: 55.r,
                backgroundColor: Colors.grey.shade200,
                child: Icon(
                  Icons.do_not_disturb,
                  color: Colors.red,
                  size: 100.sp,
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Atención!",
                        style: TextStyle(color: Colors.red, fontSize: 25.sp,fontWeight: FontWeight.bold)),
                    SizedBox(height: 10.h),
                    Flexible(
                      child: Text(
                        "Debes añadir fecha de inicio y de fin, además de crear un cuadrante con uno o mas días.",
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                    SizedBox(height: 25.h),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r)),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 10.h),
                                textStyle: TextStyle(
                                    fontSize: 30.sp, fontWeight: FontWeight.bold)),
                            // colorBrightness: Brightness.dark,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("OK"),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
