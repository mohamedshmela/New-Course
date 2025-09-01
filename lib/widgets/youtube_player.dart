import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter/services.dart';

/*
This widget is showing the user the video of the lesson 
if the video is invalid it will show a message that something went wrong

*/

class MyYoutubePlayerIframe extends StatefulWidget {
  const MyYoutubePlayerIframe({super.key, required this.videoId});

  final String? videoId;

  @override
  State<MyYoutubePlayerIframe> createState() => _MyYoutubePlayerIframeState();
}

class _MyYoutubePlayerIframeState extends State<MyYoutubePlayerIframe> {
  late YoutubePlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId ?? '',
      autoPlay: true,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.videoId == null
        ? const Center(
            child: Text(
              'Something is wrong with the lesson\'s link 😥',
              style: TextStyle(fontSize: 30),
              textAlign: TextAlign.center,
            ),
          )
        : SingleChildScrollView(
            child: YoutubePlayerScaffold(
              controller: _controller,
              builder: (context, player) {
                return Column(
                  children: [
                    player,
                    const SizedBox(height: 20),
                    const Text('Enjoy your lesson!'),
                  ],
                );
              },
              defaultOrientations: [
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
              ],
              fullscreenOrientations: [
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ],
            ),
          );
  }
}
