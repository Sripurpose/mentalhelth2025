import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mentalhelth/screens/journal_list_screen/provider/journal_list_provider.dart';
import 'package:mentalhelth/utils/theme/app_decoration.dart';
import 'package:provider/provider.dart';

import '../../../utils/core/image_constant.dart';
import '../../../utils/theme/colors.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// your imports…
final AudioPlayer globalAudioPlayer = AudioPlayer();
String? currentPlayingUrl;

class JournalAudioPlayer extends StatefulWidget {
  const JournalAudioPlayer({super.key, required this.url});
  final String url;

  @override
  State<JournalAudioPlayer> createState() => _JournalAudioPlayerState();
}

class _JournalAudioPlayerState extends State<JournalAudioPlayer> {
  bool isPlaying = false;
  Duration duration = Duration.zero;  // total
  Duration position = Duration.zero;  // current

  @override
  void initState() {
    super.initState();

    // Player state listener
    globalAudioPlayer.onPlayerStateChanged.listen((event) {
      if (!mounted) return;
      setState(() {
        isPlaying =
            event == PlayerState.playing && currentPlayingUrl == widget.url;
      });
    });

    // TOTAL duration listener (right side)
    globalAudioPlayer.onDurationChanged.listen((newDuration) {
      if (!mounted) return;
      setState(() {
        duration = newDuration;
      });
    });

    // CURRENT position listener (left side)
    globalAudioPlayer.onPositionChanged.listen((newPosition) {
      if (!mounted) return;
      if (currentPlayingUrl == widget.url) {
        setState(() {
          position = newPosition;
        });
      }
    });

    // Preload audio (just for duration)
    _preloadDuration();
  }

  Future<void> _preloadDuration() async {
    try {
      await globalAudioPlayer.setSource(UrlSource(widget.url));
      // After this, onDurationChanged will fire and set duration
    } catch (e) {
      debugPrint('Error preloading audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 8),
      decoration: BoxDecoration(
        color: ColorsContent.newThemeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Consumer<JournalListProvider>(
        builder: (context, journalListProvider, _) {
          return Row(
            children: [
              GestureDetector(
                onTap: () async {
                  if (isPlaying) {
                    // Pause current
                    await globalAudioPlayer.pause();
                    setState(() {
                      currentPlayingUrl = null;
                    });
                  } else {
                    // Stop other audio if any
                    if (currentPlayingUrl != null &&
                        currentPlayingUrl != widget.url) {
                      await globalAudioPlayer.stop();
                    }
                    // Play this url
                    currentPlayingUrl = widget.url;
                    await globalAudioPlayer.play(UrlSource(widget.url));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    Slider(
                      min: 0,
                      max: duration.inSeconds
                          .toDouble()
                          .clamp(0.0, double.infinity),
                      value: position.inSeconds
                          .toDouble()
                          .clamp(0.0, duration.inSeconds.toDouble()),
                      onChanged: (value) async {
                        final newPosition = Duration(seconds: value.toInt());
                        await globalAudioPlayer.seek(newPosition);
                        await globalAudioPlayer.resume();
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // current time (left)
                        Text(
                          _formatDuration(position),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        // total time (right)
                        Text(
                          _formatDuration(duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// time format helper
String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}



final AudioPlayer globalAudioPlayerGrid = AudioPlayer();
String? currentPlayingUrlGrid;

class GridAudioPlayer extends StatefulWidget {
  final String url;
  const GridAudioPlayer({super.key, required this.url});

  @override
  State<GridAudioPlayer> createState() => _GridAudioPlayerState();
}

class _GridAudioPlayerState extends State<GridAudioPlayer>
    with SingleTickerProviderStateMixin {
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);

    globalAudioPlayerGrid.onPlayerStateChanged.listen((event) {
      if (mounted) {
        setState(() {
          isPlaying = event == PlayerState.playing && currentPlayingUrlGrid == widget.url;
          if (isPlaying) {
            _animationController.repeat(reverse: true);
          } else {
            _animationController.stop();
          }
        });
      }
    });

    globalAudioPlayerGrid.onDurationChanged.listen((newDuration) {
      if (mounted && currentPlayingUrlGrid == widget.url) {
        setState(() => duration = newDuration);
      }
    });

    globalAudioPlayerGrid.onPositionChanged.listen((newPosition) {
      if (mounted && currentPlayingUrlGrid == widget.url) {
        setState(() => position = newPosition);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (isPlaying) {
      await globalAudioPlayerGrid.pause();
      setState(() => currentPlayingUrlGrid = null);
    } else {
      if (currentPlayingUrlGrid != null && currentPlayingUrlGrid != widget.url) {
        await globalAudioPlayerGrid.stop();
      }
      currentPlayingUrlGrid = widget.url;
      await globalAudioPlayerGrid.play(UrlSource(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = duration.inMilliseconds == 0
        ? 0.0
        : position.inMilliseconds / duration.inMilliseconds;

    return Center(
      child: Container(
        width: 340,
        height: 250,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
        decoration: BoxDecoration(
          color: ColorsContent.newThemeColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔊 Animated Waveform
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(20, (index) {
                    final t = sin((_animationController.value * 2 * pi) + (index / 2));
                    final height = 10 + 20 * (t.abs());
                    final barProgress = index / 20;
                    final isFilled = barProgress <= progress;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: height,
                        width: 5,
                        decoration: BoxDecoration(
                          color: isFilled
                              ? ColorsContent.newThemeColor
                              : ColorsContent.newThemeColor.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),

            const SizedBox(height: 25),

            // ▶️ Play / Pause Button
            GestureDetector(
              onTap: _togglePlayPause,
              child: CircleAvatar(
                radius: 28,
              //  backgroundColor: ColorsContent.newThemeColor,
                child: SvgPicture.asset(
                  isPlaying
                      ? ImageConstant.gridVideoPauseIconNumu
                      : ImageConstant.gridVideoPlayIconNumu,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ⏱ Duration Text
            Text(
              _formatDuration(position),
              style: TextStyle(
                color: ColorsContent.newThemeColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}


