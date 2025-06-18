import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final file = File(widget.videoUrl);
      final exists = await file.exists();
      if (!exists) throw Exception('Local video file not found');

      _controller = VideoPlayerController.file(file);
      await _controller!.initialize();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Video initialization failed: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (_hasError || _controller == null) {
      return const Center(
        child: Text('Failed to load video', style: TextStyle(color: Colors.red)),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        ),
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
              });
            },
            child: Icon(
              _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }
}



//////////////////////// /////////////////////// ///////////////

class VideoPlayerWidgetViewAndAlready extends StatefulWidget {
  const VideoPlayerWidgetViewAndAlready({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  _VideoPlayerWidgetViewAndAlreadyState createState() => _VideoPlayerWidgetViewAndAlreadyState();
}

class _VideoPlayerWidgetViewAndAlreadyState extends State<VideoPlayerWidgetViewAndAlready> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      File videoFile;

      if (widget.videoUrl.startsWith('http')) {
        // Download video to local file
        final response = await http.get(Uri.parse(widget.videoUrl));
        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final filePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
          videoFile = File(filePath);
          await videoFile.writeAsBytes(response.bodyBytes);
        } else {
          throw Exception('Failed to download video');
        }
      } else {
        // Use directly if local path
        videoFile = File(widget.videoUrl);
      }

      _controller = VideoPlayerController.file(videoFile);
      await _controller.initialize();
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error initializing video: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return  Center(
          child:  CupertinoActivityIndicator(
            color: ColorsContent.newThemeColor,
            radius: 15,
          )
      );
    }

    if (_hasError) {
      return const Center(
        child: Text(
          'Failed to load video',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
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
              size: 40,
            ),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


