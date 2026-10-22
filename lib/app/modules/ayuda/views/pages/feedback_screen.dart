import 'package:calendario2/app/components/toast.dart';
import 'package:calendario2/config/theme/my_colors.dart';
import 'package:calendario2/config/util/validation_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../config/theme/my_fonts.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String selectedExperience = "";
  bool _isKeyboardOpen = false;
  String _feedbackText = "";

  @override
  Widget build(BuildContext context) {
    _isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(body: _content());
  }

  Widget _content() {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          /*This method here will hide the soft keyboard.*/
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [_header(), const SizedBox(height: 12), _body()]),
      ),
    );
  }

  Widget _body() {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ..._rateYourExperience(),
            SizedBox(height: 20.h),
            Text("¿Como podríamos mejorar?",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800)),
            SizedBox(height: 12.h),
            _inputField(),
            SizedBox(height: 12.h),
            _sendFeedback()
          ]),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
        padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 16.h),
        // color: ACCENT_COLOR,
        child: IntrinsicHeight(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text("Tu Feedback",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22.sp, fontWeight: FontWeight.w800)),
                ),
                _aboveSaveButton()
              ],
            ),
            SizedBox(height: 16.h),
            Divider(height: 1.h, thickness: 0)
          ],
        )));
  }

  Widget _aboveSaveButton() {
    bool isEnable = isValidResponse();
    return Hero(
      tag: 'botonEnviarFeedbackHero',
      child: AnimatedOpacity(
        opacity: _isKeyboardOpen ? 1 : 0,
        duration: const Duration(milliseconds: 100),
        child: Align(
          alignment: Alignment.centerRight,
          child: InkWell(
              onTap: isEnable
                  ? () {
                      _feedbackSubmitted();
                    }
                  : null,
              child: IntrinsicWidth(
                child: Container(
                    height: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: isEnable
                            ? PRIMARY_COLOR
                            : MyColors.disableBgColorBtn,
                        borderRadius: BorderRadius.circular(5.r)),
                    child: Text(
                      'Enviar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: isEnable
                              ? MyColors.textButtom
                              : MyColors.textDisable,
                          fontWeight: FontWeight.w800),
                    )),
              )),
        ),
      ),
    );
  }

  List<Widget> _rateYourExperience() {
    var textWidget = Text("Valora tu experiencia",
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600));

    double gap = 6.w;
    var emojiRow = Row(children: [
      _emojiWidget("😠", isFirst: true),
      SizedBox(width: gap),
      _emojiWidget("😔"),
      SizedBox(width: gap),
      _emojiWidget("😐"),
      SizedBox(width: gap),
      _emojiWidget("🙂"),
      SizedBox(width: gap),
      _emojiWidget("😃")
    ]);
    return [textWidget, SizedBox(height: 12.h), emojiRow];
  }

  Widget _emojiWidget(String emoji, {bool isFirst = false}) {
    var isSelected = selectedExperience == emoji;
    return InkWell(
      onTap: isSelected
          ? null
          : () {
              setState(() {
                selectedExperience = emoji;
              });
            },
      child: Container(
        decoration: BoxDecoration(
            color: isSelected ? PRIMARY_COLOR.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(8.r)),
        padding: EdgeInsets.only(
            left: isFirst ? 0 : 4.w, right: 4.w, top: 6.h, bottom: 6.h),
        child: Text(
          emoji,
          style: CustomTextStyle.emojiStyle(
              context: context, fontSize: isSelected ? 40.sp : 32.sp),
        ),
      ),
    );
  }

  Widget _inputField() {
    return TextField(
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      maxLines: 8,
      onChanged: ((value) {
        setState(() {
          _feedbackText = value;
        });
      }),
      decoration: InputDecoration(
        hintText:
            "Cuentanos que es lo que te ha gustado, lo que no y si crees que podríamos implementar alguna mejora.",
        hintMaxLines: 4,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        hintStyle: TextStyle(
          fontSize: 16.sp,
          color: MyColors.textColor.withOpacity(0.26).withOpacity(0.3),
        ),
        // fillColor: ACCENT_COLOR,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(
            color: PRIMARY_COLOR.withOpacity(.75),
            width: 1.2,
          ),
        ),
      ),
    );
  }

  bool isValidResponse() {
    return ValidationUtils.isValidString(_feedbackText) &&
        ValidationUtils.isValidString(selectedExperience);
  }

  Widget _sendFeedback() {
    bool isEnable = isValidResponse();
    return Hero(
      tag: 'botonEnviarFeedbackHero',
      child: AnimatedOpacity(
        opacity: _isKeyboardOpen ? 0 : 1,
        duration: const Duration(milliseconds: 100),
        child: InkWell(
          onTap: isEnable
              ? () {
                  _feedbackSubmitted();
                }
              : null,
          child: Container(
            padding: EdgeInsets.only(top: 12.h),
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: isEnable ? PRIMARY_COLOR : MyColors.disableBgColorBtn,
                  boxShadow: [
                    BoxShadow(
                      color: PRIMARY_COLOR.withOpacity(0.03),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(5.r))),
              child: Text(
                "Enviar",
                style: TextStyle(
                    fontSize: 22.sp,
                    color:
                        isEnable ? MyColors.textButtom : MyColors.textDisable,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _feedbackSubmitted() {
    Toast.toast(
      context,
      msg: "Gracias por enviarnos el feedback 😊",
    );

    // Toast.toast(
    //     msg: "Thanks for submitting the feedback 😊",
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //     fontSize: 16.0);
    Navigator.of(context).pop();
  }
}
