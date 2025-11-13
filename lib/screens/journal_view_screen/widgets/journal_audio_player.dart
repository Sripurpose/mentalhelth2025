import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mentalhelth/screens/journal_list_screen/provider/journal_list_provider.dart';
import 'package:mentalhelth/utils/theme/app_decoration.dart';
import 'package:provider/provider.dart';

import '../../../utils/core/image_constant.dart';
import '../../../utils/theme/colors.dart';

// Define a global AudioPlayer instance
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

    // Listen for player state changes
    globalAudioPlayer.onPlayerStateChanged.listen((event) {
      if (mounted) {
        setState(() {
          isPlaying = event == PlayerState.playing && currentPlayingUrl == widget.url;
        });
      }
    });

    // Listen for duration changes
    globalAudioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted && currentPlayingUrl == widget.url) {
        setState(() {
          duration = newDuration;
        });
      }
    });

    // Listen for position changes
    globalAudioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted && currentPlayingUrl == widget.url) {
        setState(() {
          position = newPosition;
        });
      }
    });
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
      child: Consumer<JournalListProvider>(builder: (context, journalListProvider, _) {
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
                      color: Colors.white,
                      isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                children: [
                  Slider(
                    min: 0,
                    max: duration.inSeconds.toDouble().clamp(0.0, double.infinity),
                    value: position.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()),
                    onChanged: (value) async {
                      final newPosition = Duration(seconds: value.toInt());
                      await globalAudioPlayer.seek(newPosition);
                      await globalAudioPlayer.resume();
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style: const TextStyle(color: Colors.white, fontSize: 12,fontFamily: 'Poppins',),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Poppins',),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Expanded(
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       GestureDetector(
            //         onHorizontalDragUpdate: (details) async {
            //           final box = context.findRenderObject() as RenderBox;
            //           final localPosition = box.globalToLocal(details.globalPosition);
            //           final newPercent = localPosition.dx / box.size.width;
            //           final newDuration = duration * newPercent.clamp(0.0, 1.0);
            //           await globalAudioPlayer.seek(newDuration);
            //           await globalAudioPlayer.resume();
            //         },
            //         child: Container(
            //           height: 40,
            //           padding: const EdgeInsets.symmetric(vertical: 6),
            //           child: Row(
            //             crossAxisAlignment: CrossAxisAlignment.end,
            //             children: List.generate(50, (index) {
            //               final progress = position.inMilliseconds / (duration.inMilliseconds == 0 ? 1 : duration.inMilliseconds);
            //               final isFilled = index / 50 <= progress;
            //
            //               final barHeight = [
            //                 10.0, 14.0, 12.0, 18.0, 16.0, 20.0, 16.0, 14.0, 18.0, 12.0
            //               ][index % 10]; // repeating height pattern
            //
            //               return Padding(
            //                 padding: const EdgeInsets.symmetric(horizontal: 1.2),
            //                 child: AnimatedContainer(
            //                   duration: const Duration(milliseconds: 300),
            //                   height: barHeight,
            //                   width: 3,
            //                   decoration: BoxDecoration(
            //                     color: isFilled ? Colors.white : Colors.white.withOpacity(0.3),
            //                     borderRadius: BorderRadius.circular(4),
            //                   ),
            //                 ),
            //               );
            //             }),
            //           ),
            //         ),
            //       ),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Text(
            //             _formatDuration(position),
            //             style: const TextStyle(color: Colors.white, fontSize: 12),
            //           ),
            //           Text(
            //             _formatDuration(duration),
            //             style: const TextStyle(color: Colors.white, fontSize: 12),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
          ],
        );
      }),
    );
  }

}

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


