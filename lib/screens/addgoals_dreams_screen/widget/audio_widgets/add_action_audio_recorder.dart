import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/logic/logic.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:mentalhelth/widgets/custom_icon_button.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../provider/ad_goals_dreams_provider.dart';

class AudioRecorderAddGoals extends StatefulWidget {
  const AudioRecorderAddGoals({
    super.key,
  });

  @override
  State<AudioRecorderAddGoals> createState() => _AudioRecorderAddGoalsState();
}

class _AudioRecorderAddGoalsState extends State<AudioRecorderAddGoals> {
  AudioPlayer audioPlayer = AudioPlayer();

  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;

  Future record() async {
    if (!isRecorderReady) return;
    await recorder.startRecorder(toFile: "audio${flutterRandom()}");
  }

  Future stop() async {
    if (!isRecorderReady) return;
    AdDreamsGoalsProvider adDreamsGoalsProvider =
        Provider.of<AdDreamsGoalsProvider>(context, listen: false);
    final path = await recorder.stopRecorder();
    // final audioFile = File(
    //   path!,
    // );
    List<String> paths = [];
    paths.add(path!);
    adDreamsGoalsProvider.recorderValuesAddFunction(paths);
    await adDreamsGoalsProvider.saveMediaUploadMental(
      file: path,
      type: "goal",
      fileType: 'mp3',
      context: context,
    );
  }

  Future initRecorder() async {
    final microphonePermission = await Permission.microphone.request();
    final storagePermission = await Permission.storage.request();
    if (microphonePermission != PermissionStatus.granted &&
        storagePermission != PermissionStatus.granted) {
      return;
    }
    await recorder.openRecorder();
    isRecorderReady = true;
    recorder.setSubscriptionDuration(const Duration(
      milliseconds: 500,
    ));
  }

  //initstate

  @override
  void initState() {
    initRecorder();
    super.initState();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<AdDreamsGoalsProvider>(
        builder: (context, adDreamsGoalsProvider, _) {
      return GestureDetector(
        onTap: () async {
          adDreamsGoalsProvider.selectedMedia(0);
          if (adDreamsGoalsProvider.mediaSelected == 0) {
            if (recorder.isRecording) {
              await stop();
            } else {
              await record();
            }
            setState(() {});
          }
        },
        child: Container(
          height: size.height * 0.08,
          width: size.height * 0.08,
          decoration: BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(
              image: AssetImage(ImageConstant.imgMenu),
              fit: BoxFit.cover,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(
                50.0,
              ),
            ),
            border: Border.all(
              color: appTheme.blue300,
              width: 1.0,
            ),
          ),
          child: recorder.isRecording
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.stop,
                      color: Colors.blue,
                    ),
                    StreamBuilder<RecordingDisposition>(
                      stream: recorder.onProgress,
                      builder: (context, snapshot) {
                        final duration = snapshot.hasData
                            ? snapshot.data!.duration
                            : Duration.zero;
                        String twoDigits(int n) => n.toString().padLeft(0);
                        final twoDigitMinutes =
                            twoDigits(duration.inMinutes.remainder(60));
                        final twoDigitSeconds =
                            twoDigits(duration.inSeconds.remainder(60));
                        return Text('$twoDigitMinutes:$twoDigitSeconds');
                      },
                    )
                  ],
                )
              : CustomIconButton(
                  height: size.height * 0.08,
                  width: size.height * 0.08,
                  padding: const EdgeInsets.all(18),
                  child: CustomImageView(
                    imagePath: ImageConstant.imgMenu,
                  ),
                ),
        ),
      );
    });
  }
}
