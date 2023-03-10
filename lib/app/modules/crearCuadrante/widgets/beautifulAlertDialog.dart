

import 'package:flutter/material.dart';

class BeautifulAlertDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(right: 16.0),
          height: 200,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100),
                  bottomLeft: Radius.circular(100),
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10)
              )
          ),
          child: Row(
            children: <Widget>[
              SizedBox(width: 20.0),
              CircleAvatar(radius: 55, backgroundColor: Colors.grey.shade200, child: Icon(Icons.do_not_disturb,color: Colors.red, size: 80.0,),),
              SizedBox(width: 20.0),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Atención!", style: TextStyle(color: Colors.red, fontSize: 25.0)),
                    SizedBox(height: 10.0),
                    Flexible(
                      child: Text(
                          "Debes añadir fecha de inicio y de fin, además de crear un cuadrante con uno o mas días"),
                    ),
                    SizedBox(height: 10.0),
                    Row(children: <Widget>[

                      Expanded(
                        child: ElevatedButton(
                          child: Text("OK"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                              textStyle: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold)),
                          // colorBrightness: Brightness.dark,
                          onPressed: (){Navigator.pop(context);},
                        ),
                      ),
                    ],)
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