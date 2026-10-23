import 'package:calendario2/app/modules/ayuda/views/pages/videotutoriales/views/widgets/video_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../../../config/theme/my_colors.dart';
import '../../../../../../../../config/util/app_image.dart';
import '../../../../../../../../widgets/buttons/buttons.dart';

class YouTubeThumbnail extends StatelessWidget {
  const YouTubeThumbnail({Key? key, required this.id,}) : super(key: key);
  final String id;


  String get imageUrl => 'https://img.youtube.com/vi/$id/hqdefault.jpg';

  @override
  Widget build(BuildContext context) {
    void handlePressed() => context.push('/videotutoriales/${id}');
    return MergeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          children: [
            AppBtn.basic(
              semanticLabel: 'Youtube thumbnail',
              onPressed: handlePressed,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                      scale: 1.0,
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: black.withValues(alpha: 0.66),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: white,
                            size: 48.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h,),
            // Padding(
            //     padding: EdgeInsets.symmetric(horizontal: 24.w),
            //     child: Text(caption, style: TextStyle(fontSize: 14, height: 20, fontWeight: FontWeight.w500))),
          ],
        ),
      ),
    );
  }
}