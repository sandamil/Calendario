import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../../../../../widgets/buttons/circle_buttons.dart';
import '../../../../../../../controllers/app_controller.dart';

class FullscreenVideoViewer extends StatefulWidget {
  const FullscreenVideoViewer({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  State<FullscreenVideoViewer> createState() => _FullscreenVideoViewerState();
}

class _FullscreenVideoViewerState extends State<FullscreenVideoViewer> {
  final appController = Get.find<AppController>();

  late final _controller = YoutubePlayerController.fromVideoId(
    videoId: widget.id,
    params: const YoutubePlayerParams(),
  );

  @override
  void initState() {
    super.initState();
    appController.supportedOrientationsOverride = [Axiss.horizontal, Axiss.vertical];
  }

  @override
  void dispose() {
    // when view closes, remove the override
    appController.supportedOrientationsOverride = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double aspect = context.isLandscape ? MediaQuery.of(context).size.aspectRatio : 9 / 18;
    return SafeArea(
      // backgroundColor: Colors.black,
      child: Stack(
        children: [
          Center(
            child: YoutubePlayer(
              controller: _controller,
              aspectRatio: aspect,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(10.h),
              child: const BackBtn(),
            ),
          ),
        ],
      ),
    );
  }
}
