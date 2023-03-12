// import 'package:calendario2/config/util/hexColor.dart';
// import 'package:flutter/material.dart';
//
//
// class EventMarker extends StatelessWidget {
//   const ({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return buildEventsMarker();
//   }
// }
//
//
//
// Widget buildEventsMarker(DateTime date, List events) {
//   return Container(
//     margin: const EdgeInsets.all(1.0),
//     //   padding: const EdgeInsets.all(10.0),
//     decoration: BoxDecoration(
//         color: events != null
//             ? HexColor(events[0].color).withAlpha(600)
//             : Theme.of(context).highlightColor,
//         border: events != null
//             ? Border.all(color: HexColor(events[0].color), width: 1)
//             : null,
//         borderRadius: DateFormat.yMd().format(date) !=
//             DateFormat.yMd().format(DateTime.now())
//             ? BorderRadius.circular(15)
//             : BorderRadius.circular(15)),
//     width: 100,
//     height: 100,
//     //  padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 0.0),
//     child: Container(
//       child: cuadranteMap[date]![0].title != null
//           ? Stack(
//         children: <Widget>[
//           Positioned.fill(
//             bottom: 0.0,
//             child: Align(
//               alignment: Alignment.bottomCenter,
//               child: Text(cuadranteMap[date]![0].title!.toUpperCase(),
//                   style: TextStyle(
//                       fontSize: 5 * SizeConfig.widthMultiplier,
//                       color: HexColor(events[0].color),
//                       fontWeight: FontWeight.w700)),
//             ),
//           )
//         ],
//       )
//           : null,
//     ),
//   );
// }