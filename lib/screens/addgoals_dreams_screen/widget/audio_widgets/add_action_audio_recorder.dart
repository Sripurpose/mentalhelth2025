import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/logic/logic.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:mentalhelth/widgets/custom_icon_button.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../provider/ad_goals_dreams_provider.dart';
import 'package:audio_session/audio_session.dart' as audioSession;
import 'package:audioplayers/audioplayers.dart' as audioplayers;

const theSource = AudioSource.microphone;

class AudioRecorderAddGoals extends StatefulWidget {
  const AudioRecorderAddGoals({
    super.key,
  });

  @override
  State<AudioRecorderAddGoals> createState() => _AudioRecorderAddGoalsState();
}

class _AudioRecorderAddGoalsState extends State<AudioRecorderAddGoals> {
  AudioPlayer audioPlayer = AudioPlayer();
  var logger = Logger();
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;
  Codec _codec = Codec.aacMP4;
  String _mPath = 'tau_file.mp4';
  bool _mplaybackReady = false;
  
  

  Future recordAndroid() async {
    if (!isRecorderReady) return;
    await recorder.startRecorder(toFile: "audio${flutterRandom()}");
  }

  Future<void> recordIos() async {
    if (!isRecorderReady) {
      logger.w("Recorder is not ready, initializing...");

      // Initialize the recorder if it's not ready
      await initRecorderIOs();

      // If the recorder still isn't ready after initialization, return early
      if (!isRecorderReady) {
        logger.e("Recorder initialization failed.");
        return Future.error("Recorder initialization failed.");
      }
    }

    try {
      // Add a small delay to ensure the recorder is fully ready
      await Future.delayed(const Duration(milliseconds: 500));

      // Start the recorder after ensuring it's open and ready
      await recorder.startRecorder(
        toFile: _mPath,
        codec: _codec,
        audioSource: theSource,
      );
      setState(() {});
      logger.i("Recording started successfully.");
    } catch (e) {
      logger.e("Error starting the recorder: $e");
      return Future.error("Failed to start recorder: $e");
    }
  }

  Future stopAndroid() async {
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

  Future stopIos() async {
    if (!isRecorderReady) return;

    AdDreamsGoalsProvider adDreamsGoalsProvider =
    Provider.of<AdDreamsGoalsProvider>(context, listen: false);

    recorder.stopRecorder().then((path) {
      setState(() {
        _mplaybackReady = true;
      });

      List<String> paths = [];
      paths.add(path!);

      // Add the recorder values and save media upload after stopping
      adDreamsGoalsProvider.recorderValuesAddFunction(paths);
       adDreamsGoalsProvider.saveMediaUploadMental(
        file: path,
        type: "goal",
        fileType: 'mp3',
        context: context,
      );
    });
  }

  Future initRecorderAndroid() async {
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

  Future<void> initRecorderIOs() async {
    try {

      // Check if the platform is not web
      if (!kIsWeb) {
        await Permission.microphone.request();
        var microphoneStatus = await Permission.microphone.status;

        // If the permission is denied, request it
        if (microphoneStatus != PermissionStatus.granted) {
          if (microphoneStatus == PermissionStatus.permanentlyDenied) {
            return; // Exit the method
          } else {
            // Request microphone permission
            microphoneStatus = await Permission.microphone.request();
          }
        }
      }
      var storageStatus = await Permission.storage.status;
      if (storageStatus != PermissionStatus.granted) {
        if (storageStatus == PermissionStatus.permanentlyDenied) {
          await _showPermissionDialog(
            "Storage Permission Denied",
            "Unable to save recordings. Please enable storage permission in settings.",
            onSettingsPressed: () async {
              await openAppSettings(); // Direct user to app settings
            },
          );
          return; // Exit the method
        } else {
          storageStatus = await Permission.storage.request();
        }

        if (storageStatus != PermissionStatus.granted) {
          await _showPermissionDialog(
            "Storage Permission Denied",
            "Unable to save recordings. Please enable storage permission in settings.",
          );
          return; // Exit the method
        }
      }

      // Open the recorder
      await recorder.openRecorder();

      // Check for codec support and set the path for web
      if (!await recorder.isEncoderSupported(_codec) && kIsWeb) {
        _codec = Codec.opusWebM;
        _mPath = 'tau_file.webm';

        // Check again for encoder support
        if (!await recorder.isEncoderSupported(_codec) && kIsWeb) {
          isRecorderReady = true;
          return;
        }
      }

      // Configure audio session
      final session = await audioSession.AudioSession.instance;
      await session.configure(audioSession.AudioSessionConfiguration(
        avAudioSessionCategory: audioSession.AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions: audioSession.AVAudioSessionCategoryOptions.allowBluetooth |
        audioSession.AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionMode: audioSession.AVAudioSessionMode.spokenAudio,
        avAudioSessionRouteSharingPolicy: audioSession.AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: audioSession.AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: const audioSession.AndroidAudioAttributes(
          contentType: audioSession.AndroidAudioContentType.speech,
          flags: audioSession.AndroidAudioFlags.none,
          usage: audioSession.AndroidAudioUsage.voiceCommunication,
        ),
        androidAudioFocusGainType: audioSession.AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));

      // Set recorder subscription duration
      recorder.setSubscriptionDuration(const Duration(milliseconds: 500));

      // Mark recorder initialization as ready
      isRecorderReady = true;

    } catch (e) {
      logger.e("Error initializing recorder: $e");
      // Handle exceptions gracefully, potentially notifying the user
    }
  }

  Future<void> _showPermissionDialog(String title, String message, {VoidCallback? onSettingsPressed}) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (onSettingsPressed != null)
            TextButton(
              onPressed: onSettingsPressed,
              child: Text("Settings"),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  //initstate

  @override
  void initState() {
    if(Platform.isAndroid){
      initRecorderAndroid();
    }else{
      initRecorderIOs();
    }

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
              if(Platform.isAndroid){
                await stopAndroid();
              }else{
                await stopIos();
              }

            } else {
              if(Platform.isAndroid){
                await recordAndroid();
              }else{
                await recordIos();
              }

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
