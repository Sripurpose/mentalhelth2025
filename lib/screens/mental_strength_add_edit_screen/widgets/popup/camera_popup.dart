// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:mentalhelth/screens/mental_strength_add_edit_screen/mental_strength_add_edit_page.dart';
// import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
// import 'package:mentalhelth/utils/core/image_constant.dart';
// import 'package:mentalhelth/utils/logic/logic.dart';
// import 'package:mentalhelth/widgets/custom_image_view.dart';
// import 'package:mentalhelth/widgets/video_player.dart';
// import 'package:provider/provider.dart';
//
// Future cameraPopUp({
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
//             return SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           if (mentalStrengthEditProvider.mediaSelected == 2) {
//                             mentalStrengthEditProvider.takeFileFunction();
//                           }
//                         },
//                         child: buildAvatarImage(
//                           imagePath: ImageConstant.imgCamera,
//                           size: size,
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           if (mentalStrengthEditProvider.mediaSelected == 2) {
//                             mentalStrengthEditProvider.takeVideoFunction();
//                           }
//                         },
//                         child: buildAvatarImage(
//                           widget: const Icon(
//                             Icons.video_collection_rounded,
//                             color: Colors.blue,
//                           ),
//                           imagePath: ImageConstant.imgCamera,
//                           size: size,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: size.height * 0.04,
//                   ),
//                   mentalStrengthEditProvider.mediaSelected == 2
//                       ? SizedBox(
//                           width: size.width * 0.7,
//                           height: mentalStrengthEditProvider.takedImages.isEmpty
//                               ? 0
//                               : mentalStrengthEditProvider.takedImages.length *
//                                   size.height *
//                                   0.1,
//                           child: GridView.builder(
//                             physics: const NeverScrollableScrollPhysics(),
//                             itemCount:
//                                 mentalStrengthEditProvider.takedImages.length,
//                             gridDelegate:
//                                 const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               crossAxisSpacing: 10.0,
//                               mainAxisSpacing: 10.0,
//                             ),
//                             itemBuilder: (BuildContext context, int index) {
//                               return Stack(
//                                 children: [
//                                   SizedBox(
//                                     height: size.height * 0.2,
//                                     child: isVideoPath(
//                                       mentalStrengthEditProvider
//                                           .takedImages[index],
//                                     )
//                                         ? VideoPlayerWidget(
//                                             videoUrl: mentalStrengthEditProvider
//                                                 .takedImages[index],
//                                           )
//                                         : Image.file(
//                                             File(mentalStrengthEditProvider
//                                                 .takedImages[index]),
//                                             fit: BoxFit.fill,
//                                           ),
//                                   ),
//                                   GestureDetector(
//                                     onTap: () {
//                                       mentalStrengthEditProvider
//                                           .takedImagesRemove(index);
//                                     },
//                                     child: CustomImageView(
//                                       imagePath: ImageConstant.imgClosePrimary,
//                                       height: 30,
//                                       width: 30,
//                                       alignment: Alignment.topRight,
//                                       margin: const EdgeInsets.only(
//                                         top: 10,
//                                         right: 10,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             },
//                           ),
//                         )
//                       : const SizedBox()
//                 ],
//               ),
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
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/mental_strength_add_edit_page.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/logic/logic.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/video_player.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/functions/popup.dart';

Future cameraBottomSheet({
  required BuildContext context,
  required String title,
}) {
  return showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      var  logger = Logger();
      Size size = MediaQuery.of(context).size;
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
              const SizedBox(height: 10),
              Consumer<MentalStrengthEditProvider>(
                  builder: (contexts, mentalStrengthEditProvider, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (mentalStrengthEditProvider.mediaSelected == 2) {
                          mentalStrengthEditProvider.takeFileFunction(context);
                        }
                      },
                      child: buildAvatarImage(
                        imagePath: ImageConstant.imgCamera,
                        size: size,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (mentalStrengthEditProvider.mediaSelected == 2) {
                          mentalStrengthEditProvider.takeVideoFunction(context);
                        }
                      },
                      child: buildAvatarImage(
                        widget: const Icon(
                          Icons.video_collection_rounded,
                          color: Colors.blue,
                        ),
                        imagePath: ImageConstant.imgCamera,
                        size: size,
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 10),
              Consumer<MentalStrengthEditProvider>(
                builder: (context, mentalStrengthEditProvider, _) {
                  print(mentalStrengthEditProvider
                      .takedImages);
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: size.height * 0.04,
                        ),
                        mentalStrengthEditProvider.mediaSelected == 2
                            ? SizedBox(
                          width: size.width * 0.85,
                                height: mentalStrengthEditProvider
                                        .takedImages.isEmpty
                                    ? 0
                                    : size.height * 0.3,
                                child: GridView.builder(
                                  // physics: const NeverScrollableScrollPhysics(),
                                  itemCount: mentalStrengthEditProvider
                                      .takedImages.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 25.0,
                                    mainAxisSpacing: 25.0,
                                  ),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Stack(
                                      children: [
                                        SizedBox(
                                          height: size.height * 0.2,
                                          width: double.infinity,
                                          child: isVideoPath(
                                            mentalStrengthEditProvider
                                                .takedImages[index],
                                          )
                                              ? VideoPlayerWidget(
                                                  videoUrl:
                                                      mentalStrengthEditProvider
                                                          .takedImages[index],
                                                )
                                              : Image.file(
                                                  File(
                                                      mentalStrengthEditProvider
                                                          .takedImages[index]),
                                                  fit: BoxFit.cover,
                                            width: size.width,
                                                ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            customPopup(
                                              context: context,
                                              onPressedDelete: () async {
                                                // mentalStrengthEditProvider
                                                //     .removeMediaFunction(
                                                //   context: context,
                                                //   id: mentalStrengthEditProvider
                                                //       .takedImages[index],
                                                //   type: "journal",
                                                // );
                                                mentalStrengthEditProvider.takedImagesRemove(index);

                                                mentalStrengthEditProvider.removeMediaUploadResponseListFunction(index);
                                             //  Navigator.of(context).pop();

                                                // Close the bottom sheet after deleting
                                                Navigator.of(context).pop();  // This will close the galleryBottomSheet as well
                                              },
                                              yes: "Yes",
                                              title: 'Do you Need Delete',
                                              content: 'Are you sure do you need delete',
                                            );

                                          },
                                          child: Align(
                                            alignment: Alignment.topRight,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(
                                                  height: size.height * 0.01,
                                                ),
                                                CustomImageView(
                                                  imagePath:
                                                  ImageConstant.imgClosePrimary,
                                                  height: 30,
                                                  width: 30,
                                                  alignment: Alignment.topRight,
                                                  margin: const EdgeInsets.only(
                                                    top: 10,
                                                    right: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Consumer<MentalStrengthEditProvider>(
                  builder: (context, mentalStrengthEditProvider, _) {
                return mentalStrengthEditProvider.isVideoUploading
                    ? LinearProgressIndicator(
                        backgroundColor: Colors.grey[300],
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.blue),
                      )
                    : const SizedBox();
              }),
            ],
          ),
        ),
      );
    },
  );
}
