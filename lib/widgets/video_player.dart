// import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

// class VideoScreen extends StatefulWidget {
//   const VideoScreen({super.key, required this.videoUrl});
//
//   final String videoUrl;
//   @override
//   VideoScreenState createState() => VideoScreenState();
// }
//
// class VideoScreenState extends State<VideoScreen> {
//   late VideoPlayerController _videoPlayerController;
//  // late ChewieController _chewieController;
//
//   @override
//   void initState() {
//     super.initState();
//     // ignore: deprecated_member_use
//     _videoPlayerController = VideoPlayerController.network(
//       widget.videoUrl,
//     );
//     // _chewieController = ChewieController(
//     //   videoPlayerController: _videoPlayerController,
//     //   autoPlay: false,
//     //   looping: false,
//     //   // Other customization options...
//     // );
//   }
//
//   @override
//   void dispose() {
//     _videoPlayerController.dispose();
//     //_chewieController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//
//     return SizedBox(
//       width: size.width * 0.3,
//       child: const Center(
//         child:SizedBox() ,
//         // Chewie(
//         //   controller: _chewieController,
//         // ),
//       ),
//     );
//   }
// }

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({super.key, required this.videoUrl});

  final String videoUrl;
  @override
  // ignore: library_private_types_in_public_api
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override

  @override
  void initState() {
    super.initState();

    // Check if the videoUrl is a network URL (starts with http/https) or a local file path
    if (widget.videoUrl.startsWith("http") || widget.videoUrl.startsWith("https")) {
      // Initialize VideoPlayerController with a network URL
      _controller = VideoPlayerController.network(widget.videoUrl)
        ..initialize().then((_) {
          setState(() {}); // Update the UI when the video is initialized
        }).catchError((error) {
          print("Error initializing video from network: $error"); // Debug log for errors
        });
    } else {
      // Initialize VideoPlayerController with a file path
      File videoFile = File(widget.videoUrl);
      _controller = VideoPlayerController.file(videoFile)
        ..initialize().then((_) {
          setState(() {}); // Update UI when the video is initialized
        }).catchError((error) {
          print("Error initializing video from file: $error"); // Debug log for errors
        });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: _controller.value.isInitialized
              ?
              // ? AspectRatio(
              //     aspectRatio: _controller.value.aspectRatio,
              //     child: VideoPlayer(_controller),
              //   )
              VideoPlayer(_controller)
              : Container(),
        ),
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
            child: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
