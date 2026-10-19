import 'package:flutter/material.dart';

class CustomSnackBar {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static final _defaultBoxShadows = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 1),
      offset: const Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  static void showCustomSnackBar({
    required String title,
    required String message,
    Duration? duration,
  }) {
    _show(
      title: title,
      message: message,
      color: Colors.green,
      icon: Icons.check_circle,
      duration: duration ?? const Duration(seconds: 3),
      shadows: _defaultBoxShadows,
    );
  }

  static void showCustomErrorSnackBar({
    required String title,
    required String message,
    Color? color,
    Duration? duration,
  }) {
    _show(
      title: title,
      message: message,
      color: color ?? Colors.redAccent,
      icon: Icons.error,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  static void showCustomToast({
    String? title,
    required String message,
    Color? color,
    Duration? duration,
  }) {
    _show(
      title: title,
      message: message,
      color: color ?? Colors.green,
      duration: duration ?? const Duration(seconds: 4),
      onTap: _closeCurrent,
    );
  }

  static void showCustomErrorToast({
    String? title,
    required String message,
    Color? color,
    Duration? duration,
  }) {
    _show(
      title: title,
      message: message,
      color: color ?? Colors.redAccent,
      duration: duration ?? const Duration(seconds: 3),
      onTap: _closeCurrent,
    );
  }

  static void _closeCurrent() {
    messengerKey.currentState?.hideCurrentSnackBar();
  }

  static void _show({
    String? title,
    required String message,
    required Color color,
    IconData? icon,
    required Duration duration,
    List<BoxShadow>? shadows,
    VoidCallback? onTap,
  }) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          behavior: SnackBarBehavior.floating,
          backgroundColor: color,
          elevation: 4,
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          content: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null && title.isNotEmpty)
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      Text(
                        message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
