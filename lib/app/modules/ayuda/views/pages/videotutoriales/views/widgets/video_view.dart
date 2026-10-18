import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../../../../../widgets/buttons/circle_buttons.dart';
import '../../../../../../../controllers/orientation_provider.dart';

class FullscreenVideoViewer extends ConsumerStatefulWidget {
  const FullscreenVideoViewer({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  ConsumerState<FullscreenVideoViewer> createState() =>
      _FullscreenVideoViewerState();
}

class _FullscreenVideoViewerState extends ConsumerState<FullscreenVideoViewer> {
  late final _controller = YoutubePlayerController.fromVideoId(
    videoId: widget.id,
    params: const YoutubePlayerParams(),
  );

  @override
  void initState() {
    super.initState();
    ref.read(orientationProvider.notifier).setOverride(
      [Axiss.horizontal, Axiss.vertical],
    );
  }

  @override
  void dispose() {
    // Liberar los recursos del reproductor al cerrar la pantalla.
    _controller.close();

    // Restaurar las orientaciones permitidas.
    ref.read(orientationProvider.notifier).setOverride(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final aspect = mediaQuery.orientation == Orientation.landscape
        ? mediaQuery.size.aspectRatio
        : 9 / 18;
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
