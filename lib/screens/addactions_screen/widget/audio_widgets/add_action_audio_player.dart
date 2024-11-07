import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/app_decoration.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:provider/provider.dart';

import '../../provider/add_actions_provider.dart';

class AddActionAudioPlayer extends StatefulWidget {
  const AddActionAudioPlayer({
    super.key,
    required this.url,
    required this.index,
  });

  final File url;
  final int index;

  @override
  State<AddActionAudioPlayer> createState() => _AddActionAudioPlayerState();
}

class _AddActionAudioPlayerState extends State<AddActionAudioPlayer> {
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();

    audioPlayer.onPlayerStateChanged.listen((event) {
      if (mounted) {
        setState(() {
          isPlaying = event == PlayerState.playing;
        });
      }
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          duration = newDuration;
        });
      }
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          position = newPosition;
        });
      }
    });
  }

  @override
  void dispose() {
   // audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Consumer<AddActionsProvider>(
          builder: (context, addActionsProvider, _) {
        return Column(
          children: [
            // Align(
            //   alignment: Alignment.topLeft,
            //   child: CustomImageView(
            //     imagePath: ImageConstant.imgPolygon4,
            //     height: 27,
            //     width: 23,
            //     margin: const EdgeInsets.only(left: 5),
            //   ),
            // ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  top: 10,
                ),
                decoration: AppDecoration.fillBlue300.copyWith(
                  borderRadius: BorderRadiusStyle.roundedBorder10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (isPlaying) {
                          await audioPlayer.pause();
                        } else {
                          await audioPlayer.play(
                            UrlSource(
                              widget.url.path,
                            ),
                          );
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Center(
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      child: Slider(
                        inactiveColor: Colors.grey,
                        activeColor: Colors.red,
                        min: 0,
                        max: duration.inSeconds.toDouble(),
                        value: position.inSeconds.toDouble(),
                        onChanged: (value) async {
                          final position = Duration(
                            seconds: value.toInt(),
                          );
                          await audioPlayer.seek(position);
                          await audioPlayer.resume();
                        },
                      ),
                    ),

                    Consumer<AddActionsProvider>(
                        builder: (context, addActionsProvider, _) {
                      return GestureDetector(
                        onTap: () {
                          addActionsProvider.recorderValuesRemove(widget.index);
                        },
                        child: CustomImageView(
                          imagePath: ImageConstant.imgClosePrimary,
                          height: 30,
                          width: 30,
                        ),
                      );
                    }),
                    // }),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
