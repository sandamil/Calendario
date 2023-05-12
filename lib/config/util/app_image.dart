

import 'dart:math';

import 'package:calendario2/config/util/num_duration_extensions.dart';
import 'package:calendario2/config/util/retry_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_fade/image_fade.dart';

import '../theme/my_colors.dart';
import 'app_loading_indicator.dart';

class AppImage extends StatefulWidget {
  const AppImage({
    Key? key,
    required this.image,
    this.fit = BoxFit.scaleDown,
    this.alignment = Alignment.center,
    this.duration,
    this.syncDuration,
    this.distractor = false,
    this.progress = false,
    this.color,
    this.scale,
  }) : super(key: key);

  final ImageProvider? image;
  final BoxFit fit;
  final Alignment alignment;
  final Duration? duration;
  final Duration? syncDuration;
  final bool distractor;
  final bool progress;
  final Color? color;
  final double? scale;

  @override
  State<AppImage> createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> {
  ImageProvider? _displayImage;
  ImageProvider? _sourceImage;

  @override
  void didChangeDependencies() {
    _updateImage();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(AppImage oldWidget) {
    _updateImage();
    super.didUpdateWidget(oldWidget);
  }

  void _updateImage() {
    if (widget.image == _sourceImage) return;
    _sourceImage = widget.image;
    _displayImage = _capImageSize(_addRetry(_sourceImage));
  }

  @override
  Widget build(BuildContext context) {
    return ImageFade(
      image: _displayImage,
      fit: widget.fit,
      alignment: widget.alignment,
      duration: widget.duration ?? Duration(milliseconds: 300),
      syncDuration: widget.syncDuration ?? 0.ms,
      loadingBuilder: (_, value, ___) {
        if (!widget.distractor && !widget.progress) return SizedBox();
        return Center(child: AppLoadingIndicator(value: widget.progress ? value : null, color: widget.color));
      },
      errorBuilder: (_, __) => Container(
        padding: EdgeInsets.all(8.h),
        alignment: Alignment.center,
        child: LayoutBuilder(builder: (_, constraints) {
          double size = min(constraints.biggest.width, constraints.biggest.height);
          if (size < 16) return SizedBox();
          return Icon(
            Icons.image_not_supported_outlined,
            color: white.withOpacity(0.1),
            size: min(size, 32.h),
          );
        }),
      ),
    );
  }

  ImageProvider? _addRetry(ImageProvider? image) {
    return image == null ? image : RetryImage(image);
  }

  ImageProvider? _capImageSize(ImageProvider? image) {
    if (image == null || widget.scale == null) return image;
    final MediaQueryData mq = MediaQuery.of(context);
    final Size screenSize = mq.size * mq.devicePixelRatio * widget.scale!;
    return ResizeImage(image, width: screenSize.width.round());
  }
}
