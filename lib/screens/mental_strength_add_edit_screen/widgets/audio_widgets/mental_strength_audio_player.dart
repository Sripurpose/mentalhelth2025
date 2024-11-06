import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/addactions_screen/provider/add_actions_provider.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/app_decoration.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/functions/popup.dart';
import '../../../../widgets/functions/snack_bar.dart';

class MentalStrengthAudioPlayer extends StatefulWidget {
  const MentalStrengthAudioPlayer({
    super.key,
    required this.url,
    required this.index,
    this.already = false,
    this.id,
    this.type,
  });

  final String url;
  final int index;
  final bool already;
  final String? id;
  final String? type;

  @override
  State<MentalStrengthAudioPlayer> createState() =>
      _MentalStrengthAudioPlayerState();
}

class _MentalStrengthAudioPlayerState extends State<MentalStrengthAudioPlayer> {
  final audioPlayer = AudioPlayer();
  static AudioPlayer? currentAudioPlayer; // Static variable to hold the currently playing audio player
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
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Consumer<MentalStrengthEditProvider>(
          builder: (context, mentalStrengthEditProvider, _) {
            return Column(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: AppDecoration.fillBlue300.copyWith(
                      borderRadius: BorderRadiusStyle.roundedBorder10,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              try {
                                if (isPlaying) {
                                  await audioPlayer.pause();
                                } else {
                                  // Stop the currently playing audio if it exists
                                  if (currentAudioPlayer != null && currentAudioPlayer != audioPlayer) {
                                    await currentAudioPlayer!.stop();
                                  }

                                  currentAudioPlayer = audioPlayer; // Set the current player

                                  // Determine if the URL is a local path or a network URL
                                  if (widget.url.startsWith("http") || widget.url.startsWith("https")) {
                                    await audioPlayer.setSourceUrl(widget.url);
                                    await audioPlayer.play(UrlSource(widget.url));
                                  } else {
                                    final file = File(widget.url);
                                    if (await file.exists()) {
                                      await audioPlayer.setSourceDeviceFile(widget.url);
                                      await audioPlayer.play(DeviceFileSource(widget.url));
                                    } else {
                                      showCustomSnackBar(
                                        context: context,
                                        message: "Audio file not found at the given path.",
                                      );
                                    }
                                  }
                                }
                              } catch (e) {
                                showCustomSnackBar(
                                  context: context,
                                  message: "Failed to play audio: $e",
                                );
                              }
                            },
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: Center(
                                  child: Icon(
                                    color: Colors.white,
                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.5,
                            child: Slider(
                              inactiveColor: Colors.grey,
                              activeColor: Colors.white,
                              min: 0,
                              max: duration.inSeconds.toDouble(),
                              value: position.inSeconds.toDouble(),
                              onChanged: (value) async {
                                final position = Duration(seconds: value.toInt());
                                await audioPlayer.seek(position);
                                await audioPlayer.resume();
                              },
                            ),
                          ),
                          Consumer3<MentalStrengthEditProvider, AdDreamsGoalsProvider, AddActionsProvider>(
                              builder: (context, mentalStrengthEditProvider, adDreamsGoalsProvider, addActionsProvider, _) {
                                return GestureDetector(
                                  onTap: () {
                                    if (widget.type == "journal") {
                                      if (widget.already) {
                                        customPopup(
                                          context: context,
                                          onPressedDelete: () async {
                                            mentalStrengthEditProvider.alreadyRecorderValuesRemove(widget.index);
                                            mentalStrengthEditProvider.removeMediaFunction(context: context, id: widget.id.toString(), type: widget.type.toString());
                                            Navigator.of(context).pop();
                                          },
                                          yes: "Yes",
                                          title: 'Do you Need Delete',
                                          content: 'Are you sure do you need delete',
                                        );
                                      } else {
                                        customPopup(
                                          context: context,
                                          onPressedDelete: () async {
                                            mentalStrengthEditProvider.recorderValuesRemove(widget.index);
                                            Navigator.of(context).pop();
                                            mentalStrengthEditProvider.removeMediaUploadResponseListFunction(widget.index);
                                            Navigator.of(context).pop();
                                          },
                                          yes: "Yes",
                                          title: 'Do you Need Delete',
                                          content: 'Are you sure do you need delete',
                                        );
                                      }
                                    } else if (widget.type == "goal") {
                                      if (widget.already) {
                                        customPopup(
                                          context: context,
                                          onPressedDelete: () async {
                                            adDreamsGoalsProvider.alreadyRecorderValuesRemove(widget.index);
                                            mentalStrengthEditProvider.removeMediaFunction(context: context, id: widget.id.toString(), type: widget.type.toString());
                                            Navigator.of(context).pop();
                                          },
                                          yes: "Yes",
                                          title: 'Do you Need Delete',
                                          content: 'Are you sure do you need delete',
                                        );
                                      } else {
                                        customPopup(
                                          context: context,
                                          onPressedDelete: () async {
                                            adDreamsGoalsProvider.recorderValuesRemove(widget.index);
                                            Navigator.of(context).pop();
                                            adDreamsGoalsProvider.removeMediaUploadResponseListFunction(widget.index);
                                            Navigator.of(context).pop();
                                          },
                                          yes: "Yes",
                                          title: 'Do you Need Delete',
                                          content: 'Are you sure do you need delete',
                                        );
                                      }
                                    } else if (widget.type == "action") {
                                      if (widget.already) {
                                        customPopup(
                                          context: context,
                                          onPressedDelete: () async {
                                            addActionsProvider.alreadyRecorderValuesRemove(widget.index);
                                            mentalStrengthEditProvider.removeMediaFunction(context: context, id: widget.id.toString(), type: widget.type.toString());
                                            Navigator.of(context).pop();
                                          },
                                          yes: "Yes",
                                          title: 'Do you Need Delete',
                                          content: 'Are you sure do you need delete',
                                        );
                                      } else {
                                        customPopup(
                                          context: context,
                                          onPressedDelete: () async {
                                            addActionsProvider.recorderValuesRemove(widget.index);
                                            Navigator.of(context).pop();
                                            addActionsProvider.removeMediaUploadResponseListFunction(widget.index);
                                            Navigator.of(context).pop();
                                          },
                                          yes: "Yes",
                                          title: 'Do you Need Delete',
                                          content:' Are you sure do you need delete',
                                        );
                                      }
                                    }
                                  },
                                  child:
                                  CustomImageView(imagePath:
                                  ImageConstant.imgClosePrimary,height:
                                  35,width:
                                  35,),
                                );
                              }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }
}