

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/my_colors.dart';
import '../../config/util/app_icons.dart';

/// Shared methods across button types
Widget _buildIcon(BuildContext context, AppIcons icon, {required bool isSecondary, required double? size}) =>
    AppIcon(icon, color: isSecondary ? black : offWhite, size: size ?? 18);

/// The core button that drives all other buttons.
class AppBtn extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  AppBtn({
    Key? key,
    required this.onPressed,
    required this.semanticLabel,
    this.enableFeedback = true,
    this.pressEffect = true,
    this.child,
    this.padding,
    this.expand = false,
    this.isSecondary = false,
    this.circular = false,
    this.minimumSize,
    this.bgColor,
    this.border,
  })  : _builder = null,
        super(key: key);

  AppBtn.from({
    Key? key,
    required this.onPressed,
    this.enableFeedback = true,
    this.pressEffect = true,
    this.padding,
    this.expand = false,
    this.isSecondary = false,
    this.minimumSize,
    this.bgColor,
    this.border,
    String? semanticLabel,
    String? text,
    AppIcons? icon,
    double? iconSize,
  })  : child = null,
        circular = false,
        super(key: key) {
    if (semanticLabel == null && text == null) throw ('AppBtn.from must include either text or semanticLabel');
    this.semanticLabel = semanticLabel ?? text ?? '';
    _builder = (context) {
      if (text == null && icon == null) return SizedBox.shrink();
      Text? txt = text == null
          ? null
          : Text(text.toUpperCase(),
              style: TextStyle(fontSize : 14.sp, fontWeight: FontWeight.w500, letterSpacing : 2, height: 14), textHeightBehavior: TextHeightBehavior(applyHeightToFirstAscent: false));
      Widget? icn = icon == null ? null : _buildIcon(context, icon, isSecondary: isSecondary, size: iconSize);
      if (txt != null && icn != null) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [txt, SizedBox(width: 8.w,), icn],
        );
      } else {
        return (txt ?? icn)!;
      }
    };
  }

  // ignore: prefer_const_constructors_in_immutables
  AppBtn.basic({
    Key? key,
    required this.onPressed,
    required this.semanticLabel,
    this.enableFeedback = true,
    this.pressEffect = true,
    this.child,
    this.padding = EdgeInsets.zero,
    this.isSecondary = false,
    this.circular = false,
    this.minimumSize,
  })  : expand = false,
        bgColor = Colors.transparent,
        border = null,
        _builder = null,
        super(key: key);

  // interaction:
  final VoidCallback? onPressed;
  late final String semanticLabel;
  final bool enableFeedback;

  // content:
  late final Widget? child;
  late final WidgetBuilder? _builder;

  // layout:
  final EdgeInsets? padding;
  final bool expand;
  final bool circular;
  final Size? minimumSize;

  // style:
  final bool isSecondary;
  final BorderSide? border;
  final Color? bgColor;
  final bool pressEffect;

  @override
  Widget build(BuildContext context) {
    Color defaultColor = isSecondary ? white : greyStrong;
    Color textColor = isSecondary ? black : white;
    BorderSide side = border ?? BorderSide.none;

    Widget content = _builder?.call(context) ?? child ?? SizedBox.shrink();
    if (expand) content = Center(child: content);

    OutlinedBorder shape = circular
        ? CircleBorder(side: side)
        : RoundedRectangleBorder(side: side, borderRadius: BorderRadius.circular(8));

    ButtonStyle style = ButtonStyle(
      minimumSize: ButtonStyleButton.allOrNull<Size>(minimumSize ?? Size.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      splashFactory: NoSplash.splashFactory,
      backgroundColor: ButtonStyleButton.allOrNull<Color>(bgColor ?? defaultColor),
      overlayColor: ButtonStyleButton.allOrNull<Color>(Colors.transparent), // disable default press effect
      shape: ButtonStyleButton.allOrNull<OutlinedBorder>(shape),
      padding: ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(padding ?? EdgeInsets.all(24.h)),

      enableFeedback: enableFeedback,
    );

    Widget button = _CustomFocusBuilder(
      builder: (context, focus) => Stack(
        children: [
          TextButton(
            onPressed: onPressed,
            style: style,
            focusNode: focus,
            child: DefaultTextStyle(
              style: DefaultTextStyle.of(context).style.copyWith(color: textColor),
              child: content,
            ),
          ),
          if (focus.hasFocus)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: accent1, width: 3))),
              ),
            )
        ],
      ),
    );

    // add press effect:
    if (pressEffect) button = _ButtonPressEffect(button);

    // add semantics?
    if (semanticLabel.isEmpty) return button;
    return Semantics(
      label: semanticLabel,
      button: true,
      container: true,
      child: ExcludeSemantics(child: button),
    );
  }
}

/// //////////////////////////////////////////////////
/// _ButtonDecorator
/// Add a transparency-based press effect to buttons.
/// //////////////////////////////////////////////////
class _ButtonPressEffect extends StatefulWidget {
  const _ButtonPressEffect(this.child, {Key? key}) : super(key: key);
  final Widget child;

  @override
  State<_ButtonPressEffect> createState() => _ButtonPressEffectState();
}

class _ButtonPressEffectState extends State<_ButtonPressEffect> {
  bool _isDown = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      excludeFromSemantics: true,
      onTapDown: (_) => setState(() => _isDown = true),
      onTapUp: (_) => setState(() => _isDown = false), // not called, TextButton swallows this.
      onTapCancel: () => setState(() => _isDown = false),
      behavior: HitTestBehavior.translucent,
      child: Opacity(
        opacity: _isDown ? 0.7 : 1,
        child: ExcludeSemantics(child: widget.child),
      ),
    );
  }
}

class _CustomFocusBuilder extends StatefulWidget {
  const _CustomFocusBuilder({Key? key, required this.builder}) : super(key: key);
  final Widget Function(BuildContext context, FocusNode focus) builder;

  @override
  State<_CustomFocusBuilder> createState() => _CustomFocusBuilderState();
}

class _CustomFocusBuilderState extends State<_CustomFocusBuilder> {
  late final _focusNode = FocusNode()..addListener(() => setState(() {}));

  @override
  Widget build(BuildContext context) {
    return widget.builder.call(context, _focusNode);
  }
}
