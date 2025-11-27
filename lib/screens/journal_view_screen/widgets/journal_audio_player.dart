import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mentalhelth/screens/journal_list_screen/provider/journal_list_provider.dart';
import 'package:mentalhelth/utils/theme/app_decoration.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
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
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();

    globalAudioPlayer.onPlayerStateChanged.listen((event) {
      if (!mounted) return;
      setState(() {
        isPlaying = event == PlayerState.playing && currentPlayingUrl == widget.url;
      });
    });

    globalAudioPlayer.onDurationChanged.listen((newDuration) {
      if (!mounted) return;
      setState(() {
        duration = newDuration;
      });
    });

    globalAudioPlayer.onPositionChanged.listen((newPosition) {
      if (!mounted) return;
      if (currentPlayingUrl == widget.url) {
        setState(() {
          position = newPosition;
        });
      }
    });

    _preloadDuration();
  }

  Future<void> _preloadDuration() async {
    try {
      await globalAudioPlayer.setSource(UrlSource(widget.url));
    } catch (e) {
      debugPrint('Error preloading audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 8),
      decoration: BoxDecoration(
        color: ColorsContent.newThemeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Consumer(
        builder: (context, journalListProvider, _) {
          return Row(
            children: [
              GestureDetector(
                onTap: () async {
                  if (isPlaying) {
                    await globalAudioPlayer.pause();
                    setState(() {
                      currentPlayingUrl = null;
                    });
                  } else {
                    if (currentPlayingUrl != null && currentPlayingUrl != widget.url) {
                      await globalAudioPlayer.stop();
                    }
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
                    GestureDetector(
                      onTapDown: (details) async {
                        final box = context.findRenderObject() as RenderBox;
                        final localPosition = details.localPosition;
                        final width = box.size.width;
                        final percent = (localPosition.dx / width).clamp(0.0, 1.0);
                        final newPosition = Duration(
                          milliseconds: (duration.inMilliseconds * percent).toInt(),
                        );
                        await globalAudioPlayer.seek(newPosition);
                        if (!isPlaying) {
                          await globalAudioPlayer.resume();
                        }
                      },
                      child: CustomPaint(
                        size: const Size(double.infinity, 50),
                        painter: WaveformPainter(
                          progress: duration.inMilliseconds > 0
                              ? position.inMilliseconds / duration.inMilliseconds
                              : 0.0,
                        ),
                      ),
                    ),
                    isPlaying?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: ColorsContent.goalNotCompletedColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text(
                              _formatDuration(position),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: ColorsContent.goalNotCompletedColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text(
                              _formatDuration(duration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ):
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: ColorsContent.newThemeColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text(
                             "",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: ColorsContent.goalNotCompletedColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text(
                              _formatDuration(duration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
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

String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}

class WaveformPainter extends CustomPainter {
  final double progress;

  WaveformPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 40;
    final barWidth = size.width / barCount;
    final spacing = barWidth * 0.4;
    final actualBarWidth = barWidth - spacing;
    final centerY = size.height / 2;

    // WhatsApp-style random heights with variation
    final random = math.Random(42); // Fixed seed for consistent pattern
    final heights = List.generate(
      barCount,
          (i) {
        // Create varied heights between 0.2 and 1.0
        final baseHeight = 0.25 + random.nextDouble() * 0.75;
        return baseHeight;
      },
    );

    for (int i = 0; i < barCount; i++) {
      final x = i * barWidth;
      final barHeight = size.height * heights[i];
      final isPlayed = (i / barCount) <= progress;

      final paint = Paint()
        ..color = isPlayed
            ? Colors.white
            : Colors.white.withOpacity(0.4)
        ..strokeWidth = actualBarWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(x + barWidth / 2, centerY - barHeight / 2),
        Offset(x + barWidth / 2, centerY + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
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
        height: 350,
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


