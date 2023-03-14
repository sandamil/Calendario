import 'package:calendario2/app/data/model/turnoCalendar.dart';
import 'package:calendario2/config/theme/my_theme.dart';
import 'package:calendario2/config/util/hexColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MarkerBuilderWidget extends StatelessWidget {
  const MarkerBuilderWidget(
      {super.key, required this.day, required this.events,});

  final DateTime day;
  final List<Cuadrante> events;

  @override
  Widget build(BuildContext context) {
    return events.isNotEmpty
        ? Container(
        margin: const EdgeInsets.all(1.0),
        //   padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: events != null
              ? HexColor(events[0].color!)
              .withAlpha(600)
              : Theme.of(context).highlightColor,
          border: events != null
              ? Border.all(
              color: HexColor(events[0].color!),
              width: 1)
              : null,
          borderRadius: BorderRadius.circular(5.r),
        ),
        width: 100,
        height: 100,
        //  padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 0.0),
        child: Container(
          child: events[0].title != null
              ? Stack(
            children: <Widget>[
              Positioned.fill(
                bottom: 0.0,
                child: Align(
                  alignment:
                  Alignment.bottomCenter,
                  child: Text(
                      events[0]
                          .title!
                          .toUpperCase(),
                      style: TextStyle(
                          fontSize: 15.sp,
                          color: HexColor(
                              events[0].color!),
                          fontWeight:
                          FontWeight.w700)),
                ),
              )
            ],
          )
              : null,
        ))
        : Container();
  }
}
