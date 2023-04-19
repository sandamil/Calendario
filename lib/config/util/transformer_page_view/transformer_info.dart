import 'package:flutter/material.dart';

const int kMaxValue = 2000000000;
const int kMiddleValue = 1000000000;

///  Default auto play transition duration (in millisecond)
const int kDefaultTransactionDuration = 300;

class TransformInfo {
  /// The `width` of the `TransformerPageView`
  final double width;

  /// The `height` of the `TransformerPageView`
  final double height;

  /// The `position` of the widget pass to [PageTransformer.transform]
  ///  A `position` describes how visible the widget is.
  ///  The widget in the center of the screen' which is  full visible, position is 0.0.
  ///  The widge in the left ,may be hidden, of the screen's position is less than 0.0, -1.0 when out of the screen.
  ///  The widge in the right ,may be hidden, of the screen's position is greater than 0.0,  1.0 when out of the screen
  ///
  ///
  final double position;

  /// The `index` of the widget pass to [PageTransformer.transform]
  final int index;

  /// The `activeIndex` of the PageView
  final int activeIndex;

  /// The `activeIndex` of the PageView, from user start to swipe
  /// It will change when user end drag
  final int fromIndex;

  /// Next `index` is greater than this `index`
  final bool forward;

  /// User drag is done.
  final bool done;

  /// Same as [TransformerPageView.viewportFraction]
  final double viewportFraction;

  /// Copy from [TransformerPageView.scrollDirection]
  final Axis scrollDirection;

  TransformInfo(
      {required this.index,
      required this.position,
      required this.width,
      required this.height,
      required this.activeIndex,
      required this.fromIndex,
      required this.forward,
      required this.done,
      required this.viewportFraction,
      required this.scrollDirection});
}
