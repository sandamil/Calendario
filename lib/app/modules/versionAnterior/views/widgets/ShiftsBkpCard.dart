
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';

import '../../../../../config/util/hexColor.dart';
import '../../../../data/model/previousDatabase/previousShift.dart';


class ShiftsBkpCard extends StatelessWidget {
  const ShiftsBkpCard({
    required this.noteData,
    // required this.onTapAction,
    Key? key,
  }) : super(key: key);

  final PreviousShift noteData;
  // final Function(PreviousTask noteData) onTapAction;

  @override
  Widget build(BuildContext context) {


    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          color: HexColor(noteData.color!),
          border: Border.all(width: 0.8),
          borderRadius: BorderRadius.circular(5.r),
          boxShadow: const <BoxShadow>[
            BoxShadow(
                color: Colors.black45,
                offset: Offset(0, 1),
                blurRadius: 3),
          ]),
      margin:
      const EdgeInsets.only(top: 4.0, left: 5.0, right: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                noteData.title!,
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context)
                        .primaryTextTheme
                        .titleLarge
                        ?.color),
              ),
              const SizedBox(
                height: 5,
              ),
              noteData.timeFrom != null &&
                  noteData.timeTo != null &&
                  noteData.timeFrom != '' &&
                  noteData.timeTo != ''
                  ?
              Text(
                'De ${noteData.timeFrom} a ${noteData.timeTo}',
                style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context)
                        .primaryTextTheme
                        .titleLarge
                        ?.color),
              )
              : Container()
            ],
          ),
        ],
      ),
    );
  }


}
