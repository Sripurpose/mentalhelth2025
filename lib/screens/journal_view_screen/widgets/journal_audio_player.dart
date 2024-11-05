import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/journal_list_screen/provider/journal_list_provider.dart';
import 'package:mentalhelth/utils/theme/app_decoration.dart';
import 'package:provider/provider.dart';

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
      margin: const EdgeInsets.only(
        bottom: 5,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 19,
        vertical: 12,
      ),
      decoration: AppDecoration.fillBlue300.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder10,
      ),
      child: Consumer<JournalListProvider>(
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
                      // Stop any other audio playing
                      if (currentPlayingUrl != null && currentPlayingUrl != widget.url) {
                        await globalAudioPlayer.stop();
                      }
                      currentPlayingUrl = widget.url;
                      await globalAudioPlayer.play(UrlSource(widget.url));
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                  ),
                ),
                SizedBox(
                  width: size.width * 0.65,
                  child: Slider(
                    min: 0,
                    max: duration.inSeconds.toDouble(),
                    value: position.inSeconds.toDouble(),
                    onChanged: (value) async {
                      final newPosition = Duration(seconds: value.toInt());
                      await globalAudioPlayer.seek(newPosition);
                      await globalAudioPlayer.resume();
                    },
                  ),
                )
              ],
            );
          }),
    );
  }
}
