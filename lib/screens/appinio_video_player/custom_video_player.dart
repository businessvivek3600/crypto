import 'custom_video_player_controller.dart';
import 'embedded_video_player.dart';
import 'package:flutter/material.dart';

class CustomVideoPlayer extends StatelessWidget {
  final CustomVideoPlayerController customVideoPlayerController;
  const CustomVideoPlayer({
    Key? key,
    required this.customVideoPlayerController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmbeddedVideoPlayer(
      isFullscreen: false,
      customVideoPlayerController: customVideoPlayerController,
    );
  }
}
