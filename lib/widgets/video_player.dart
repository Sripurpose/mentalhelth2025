import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

///build mental///
class VideoPlayerWidgetBuildMental extends StatefulWidget {
  const VideoPlayerWidgetBuildMental({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  _VideoPlayerWidgetBuildMentalState createState() => _VideoPlayerWidgetBuildMentalState();
}
class _VideoPlayerWidgetBuildMentalState extends State<VideoPlayerWidgetBuildMental> {
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
        // Center(
        //   child: GestureDetector(
        //     onTap: () {
        //       setState(() {
        //         _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
        //       });
        //     },
        //     child: Icon(
        //       _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
        //       color: Colors.white,
        //       size: 40,
        //     ),
        //   ),
        // ),
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5), // dark background
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),

      ],
    );
  }
}

class VideoPlayerWidgetViewAndAlreadyBuildMental extends StatefulWidget {
  const VideoPlayerWidgetViewAndAlreadyBuildMental({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  _VideoPlayerWidgetViewAndAlreadyBuildMentalState createState() => _VideoPlayerWidgetViewAndAlreadyBuildMentalState();
}
class _VideoPlayerWidgetViewAndAlreadyBuildMentalState extends State<VideoPlayerWidgetViewAndAlreadyBuildMental> {
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5), // dark background
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
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


class VideoPlayerWidgetViewAndAlreadyBuildMentalProgressBar extends StatefulWidget {
  const VideoPlayerWidgetViewAndAlreadyBuildMentalProgressBar({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  _VideoPlayerWidgetViewAndAlreadyBuildMentalProgressBarState createState() =>
      _VideoPlayerWidgetViewAndAlreadyBuildMentalProgressBarState();
}

class _VideoPlayerWidgetViewAndAlreadyBuildMentalProgressBarState
    extends State<VideoPlayerWidgetViewAndAlreadyBuildMentalProgressBar> {
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
        final response = await http.get(Uri.parse(widget.videoUrl));
        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final filePath =
              '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
          videoFile = File(filePath);
          await videoFile.writeAsBytes(response.bodyBytes);
        } else {
          throw Exception('Failed to download video');
        }
      } else {
        videoFile = File(widget.videoUrl);
      }

      _controller = VideoPlayerController.file(videoFile);
      await _controller.initialize();
      _controller.addListener(() {
        if (mounted) setState(() {});
      });
      _controller.play(); // Auto play
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error initializing video: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return  Center(
        child: CupertinoActivityIndicator(radius: 15, color: ColorsContent.newThemeColor),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                VideoPlayer(_controller),
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5), // dark background
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                            playedColor: ColorsContent.newThemeColor,
                            bufferedColor: Colors.grey.shade400,
                            backgroundColor: Colors.grey.shade300,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_controller.value.position),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            Text(
                              _formatDuration(_controller.value.duration),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

///-///




///Goals///
class VideoPlayerWidgetGoal extends StatefulWidget {
  const VideoPlayerWidgetGoal({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  _VideoPlayerWidgetGoalState createState() => _VideoPlayerWidgetGoalState();
}
class _VideoPlayerWidgetGoalState extends State<VideoPlayerWidgetGoal> {
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5), // dark background
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class VideoPlayerWidgetViewAndAlreadyGoal extends StatefulWidget {
  const VideoPlayerWidgetViewAndAlreadyGoal({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  _VideoPlayerWidgetViewAndAlreadyGoalState createState() => _VideoPlayerWidgetViewAndAlreadyGoalState();
}
class _VideoPlayerWidgetViewAndAlreadyGoalState extends State<VideoPlayerWidgetViewAndAlreadyGoal> {
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5), // dark background
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
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



class VideoPlayerWidgetViewAndAlreadyGoalProgressBar extends StatefulWidget {
  const VideoPlayerWidgetViewAndAlreadyGoalProgressBar({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  _VideoPlayerWidgetViewAndAlreadyGoalProgressBarState createState() =>
      _VideoPlayerWidgetViewAndAlreadyGoalProgressBarState();
}

class _VideoPlayerWidgetViewAndAlreadyGoalProgressBarState
    extends State<VideoPlayerWidgetViewAndAlreadyGoalProgressBar> {
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
        videoFile = File(widget.videoUrl);
      }

      _controller = VideoPlayerController.file(videoFile);
      await _controller.initialize();
      _controller.play(); // Auto-play video
      _controller.addListener(() {
        if (mounted) setState(() {});
      });

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error initializing video: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return  Center(
        child: CupertinoActivityIndicator(
          radius: 15,
          color: ColorsContent.newThemeColor,
        ),
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

    return FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.center,
      child: SizedBox(
        width: _controller.value.size.width,
        height: _controller.value.size.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            VideoPlayer(_controller),

            // Tap-to-play/pause
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying ? _controller.pause() : _controller.play();
                  });
                },
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5), // dark background
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),

            // Progress bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: ColorsContent.newThemeColor,
                        bufferedColor: Colors.grey.shade400,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_controller.value.position),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Text(
                          _formatDuration(_controller.value.duration),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

///-///


///Action///
class VideoPlayerWidgetAction extends StatefulWidget {
  const VideoPlayerWidgetAction({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  _VideoPlayerWidgetActionState createState() => _VideoPlayerWidgetActionState();
}
class _VideoPlayerWidgetActionState extends State<VideoPlayerWidgetAction> {
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5), // dark background
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class VideoPlayerWidgetViewAndAlreadyAction extends StatefulWidget {
  const VideoPlayerWidgetViewAndAlreadyAction({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  _VideoPlayerWidgetViewAndAlreadyActionState createState() => _VideoPlayerWidgetViewAndAlreadyActionState();
}
class _VideoPlayerWidgetViewAndAlreadyActionState extends State<VideoPlayerWidgetViewAndAlreadyAction> {
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5), // dark background
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
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



class VideoPlayerWidgetViewAndAlreadyActionProgressBar extends StatefulWidget {
  const VideoPlayerWidgetViewAndAlreadyActionProgressBar({
    super.key,
    required this.videoUrl,
  });

  final String videoUrl;

  @override
  _VideoPlayerWidgetViewAndAlreadyActionProgressBarState createState() =>
      _VideoPlayerWidgetViewAndAlreadyActionProgressBarState();
}

class _VideoPlayerWidgetViewAndAlreadyActionProgressBarState
    extends State<VideoPlayerWidgetViewAndAlreadyActionProgressBar> {
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
        videoFile = File(widget.videoUrl);
      }

      _controller = VideoPlayerController.file(videoFile);
      await _controller.initialize();
      _controller.play(); // Auto play
      _controller.addListener(() {
        if (mounted) setState(() {});
      });

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error initializing video: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return  Center(
        child: CupertinoActivityIndicator(
          radius: 15,
          color: ColorsContent.newThemeColor,
        ),
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

    return FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.center,
      child: SizedBox(
        width: _controller.value.size.width,
        height: _controller.value.size.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            VideoPlayer(_controller),

            // Tap to Play/Pause
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5), // dark background
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),

            // Progress Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: ColorsContent.newThemeColor,
                        bufferedColor: Colors.grey.shade400,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_controller.value.position),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Text(
                          _formatDuration(_controller.value.duration),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

///-///

