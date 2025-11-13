import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/widgets/audio_widgets/flutter_audio_recorder.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/widgets/audio_widgets/mental_strength_audio_player.dart';
import 'package:provider/provider.dart';

import '../../../../utils/core/image_constant.dart';
import '../../../../widgets/custom_image_view.dart';

//
// Future audioPopup({
//   required BuildContext context,
//   required String title,
// }) {
//   return showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       Size size = MediaQuery.of(context).size;
//       return Center(
//         child: AlertDialog(
//           title: Center(
//             child: Text(
//               title,
//             ),
//           ),
//           content: Consumer<MentalStrengthEditProvider>(
//               builder: (context, mentalStrengthEditProvider, _) {
//             return Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const AudioRecorderMentalStrengthBuild(),
//                 SizedBox(
//                   height: size.height * 0.04,
//                 ),
//                 mentalStrengthEditProvider.mediaSelected == 0
//                     ? SizedBox(
//                         height:
//                             mentalStrengthEditProvider.recordedFilePath.length *
//                                 size.height *
//                                 0.1,
//                         width: size.width * 0.7,
//                         child: ListView.builder(
//                           itemCount: mentalStrengthEditProvider
//                               .recordedFilePath.length,
//                           itemBuilder: (context, index) {
//                             return MentalStrengthAudioPlayer(
//                               url: mentalStrengthEditProvider
//                                   .recordedFilePath[index],
//                               index: index,
//                             );
//                           },
//                         ),
//                       )
//                     : const SizedBox()
//               ],
//             );
//           }),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the popup
//               },
//               child: const Text('Close'),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }
Future audioBottomSheet({
  required BuildContext context,
  required String title,
}) {
  return showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      Size size = MediaQuery.of(context).size;
      return Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const SizedBox(width: 40), // Placeholder for left side
                  Expanded(
                    child: Center(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(); // Close the bottom sheet
                    },
                    child: CustomImageView(
                      imagePath: ImageConstant.imgClosePrimaryNew,
                      height: 40,
                      width: 40,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Consumer<MentalStrengthEditProvider>(
                  builder: (context, mentalStrengthEditProvider, _) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AudioRecorderMentalStrengthBuild(),
                        SizedBox(height: size.height * 0.03),
                        if (mentalStrengthEditProvider.mediaSelected == 0)
                          Flexible( // Wrap the ListView in Flexible
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: mentalStrengthEditProvider
                                  .alreadyRecordedFilePath.length,
                              itemBuilder: (context, index) {
                                return MentalStrengthAudioPlayer(
                                  url: mentalStrengthEditProvider
                                      .alreadyRecordedFilePath[index].value,
                                  index: index,
                                  already: true,
                                  id: mentalStrengthEditProvider
                                      .alreadyRecordedFilePath[index].id,
                                  type: "journal",
                                );
                              },
                            ),
                          ),
                        if (mentalStrengthEditProvider.mediaSelected == 0)
                          Flexible( // Wrap the ListView in Flexible
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: mentalStrengthEditProvider
                                  .recordedFilePath.length,
                              itemBuilder: (context, index) {
                                return MentalStrengthAudioPlayer(
                                  url: mentalStrengthEditProvider.recordedFilePath[index],
                                  index: index,
                                  type: "journal",
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

            ],
          ),
        )

      );
    },
  );
}
