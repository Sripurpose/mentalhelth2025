//
// Future galleryPopup({
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
//                           if (mentalStrengthEditProvider.mediaSelected == 1) {
//                             mentalStrengthEditProvider.pickImageFunction();
//                           }
//                         },
//                         child: buildAvatarImage(
//                           widget: const Icon(
//                             Icons.image,
//                             color: Colors.blue,
//                           ),
//                           imagePath: ImageConstant.imgThumbsUp,
//                           size: size,
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           if (mentalStrengthEditProvider.mediaSelected == 1) {
//                             mentalStrengthEditProvider.pickVideoFunction();
//                           }
//                         },
//                         child: buildAvatarImage(
//                           widget: const Icon(
//                             Icons.video_collection_rounded,
//                             color: Colors.blue,
//                           ),
//                           imagePath: ImageConstant.imgThumbsUp,
//                           size: size,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: size.height * 0.04,
//                   ),
//                   mentalStrengthEditProvider.mediaSelected == 1
//                       ? SizedBox(
//                           width: size.width * 0.7,
//                           height: mentalStrengthEditProvider
//                                   .pickedImages.isEmpty
//                               ? 0
//                               : mentalStrengthEditProvider.pickedImages.length *
//                                   size.height *
//                                   0.2,
//                           child: GridView.builder(
//                             physics: const NeverScrollableScrollPhysics(),
//                             itemCount:
//                                 mentalStrengthEditProvider.pickedImages.length,
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
//                                             mentalStrengthEditProvider
//                                                 .pickedImages[index])
//                                         ? VideoPlayerWidget(
//                                             videoUrl: mentalStrengthEditProvider
//                                                 .pickedImages[index],
//                                           )
//                                         : Image.file(
//                                             File(
//                                               mentalStrengthEditProvider
//                                                   .pickedImages[index],
//                                             ),
//                                             fit: BoxFit.fill,
//                                           ),
//                                   ),
//                                   GestureDetector(
//                                     onTap: () {
//                                       mentalStrengthEditProvider
//                                           .pickedImagesRemove(index);
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

Future galleryBottomSheet({
  required BuildContext context,
  required String title,
}) {
  return showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      var logger = Logger();
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
                        if (mentalStrengthEditProvider.mediaSelected == 1) {
                          mentalStrengthEditProvider.pickImageFunction();
                        }
                      },
                      child: buildAvatarImage(
                        widget: const Icon(
                          Icons.image,
                          color: Colors.blue,
                        ),
                        imagePath: ImageConstant.imgThumbsUp,
                        size: size,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (mentalStrengthEditProvider.mediaSelected == 1) {
                          mentalStrengthEditProvider.pickVideoFunction(context);
                        }
                      },
                      child: buildAvatarImage(
                        widget: const Icon(
                          Icons.video_collection_rounded,
                          color: Colors.blue,
                        ),
                        imagePath: ImageConstant.imgThumbsUp,
                        size: size,
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 10),
              Expanded(
                child: Consumer<MentalStrengthEditProvider>(
                  builder: (context, mentalStrengthEditProvider, _) {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: size.height * 0.045,
                          ),
                          mentalStrengthEditProvider.mediaSelected == 1
                              ? Container(
                                  // color: Colors.red,
                                  width: size.width * 0.85,
                            height: mentalStrengthEditProvider.alreadyPickedImages.isEmpty
                                ? 0
                                : ((mentalStrengthEditProvider.alreadyPickedImages.length / 2).ceil() *
                                size.height *
                                0.217), // Calculate height based on number of rows needed
                                  child: GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: mentalStrengthEditProvider
                                        .alreadyPickedImages.length,
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
                                            // width: double.infinity,
                                            child: isVideoPath(
                                              mentalStrengthEditProvider
                                                  .alreadyPickedImages[index]
                                                  .value,
                                            )
                                                ? VideoPlayerWidget(
                                                    videoUrl:
                                                        mentalStrengthEditProvider
                                                            .alreadyPickedImages[
                                                                index]
                                                            .value,
                                                  )
                                                : mentalStrengthEditProvider
                                                            .alreadyPickedImages[
                                                                index]
                                                            .value
                                                            .startsWith(
                                                                "http") ||
                                                        mentalStrengthEditProvider
                                                            .alreadyPickedImages[
                                                                index]
                                                            .value
                                                            .startsWith("https")
                                                    ? CustomImageView(
                                                        fit: BoxFit.fill,
                                                        imagePath:
                                                            mentalStrengthEditProvider
                                                                .alreadyPickedImages[
                                                                    index]
                                                                .value,
                                                        height:
                                                            size.height * 0.27,
                                                        width: size.width,
                                                        alignment:
                                                            Alignment.center,
                                                      )
                                                    : Image.file(
                                                        File(
                                                          mentalStrengthEditProvider
                                                              .alreadyPickedImages[
                                                                  index]
                                                              .value,
                                                        ),
                                                        fit: BoxFit.fill,
                                                        width: size.width,
                                                      ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              customPopup(
                                                context: context,
                                                onPressedDelete: () async {
                                                  mentalStrengthEditProvider
                                                      .removeMediaFunction(
                                                    context: context,
                                                    id: mentalStrengthEditProvider
                                                        .alreadyPickedImages[index]
                                                        .id,
                                                    type: "journal",
                                                  );
                                                  mentalStrengthEditProvider
                                                      .alreadyPickedImagesRemove(
                                                          index);

                                                  Navigator.of(context).pop();

                                                  // Close the bottom sheet after deleting
                                                 // Navigator.of(context).pop();  // This will close the galleryBottomSheet as well
                                                },
                                                yes: "Yes",
                                                title: 'Do you Need Delete',
                                                content: 'Are you sure do you need delete',
                                              );

                                            },
                                            child: CustomImageView(
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
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                )
                              : const SizedBox(),
                          mentalStrengthEditProvider.mediaSelected == 1
                              ? Container(
                                 // color: Colors.blueGrey,
                                  width: size.width * 0.85,
                                  height: mentalStrengthEditProvider
                                          .pickedImages.isEmpty
                                      ? 0
                                      : mentalStrengthEditProvider
                                              .pickedImages.length *
                                          size.height *
                                          0.2,
                                  child: GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: mentalStrengthEditProvider
                                        .pickedImages.length,
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
                                            child: isVideoPath(
                                              mentalStrengthEditProvider
                                                  .pickedImages[index],
                                            )
                                                ? VideoPlayerWidget(
                                                    videoUrl:
                                                        mentalStrengthEditProvider
                                                                .pickedImages[
                                                            index],
                                                  )
                                                : mentalStrengthEditProvider
                                                            .pickedImages[index]
                                                            .startsWith(
                                                                "http") ||
                                                        mentalStrengthEditProvider
                                                            .pickedImages[index]
                                                            .startsWith("https")
                                                    ? CustomImageView(
                                                        fit: BoxFit.cover,
                                                        imagePath:
                                                            mentalStrengthEditProvider
                                                                    .pickedImages[
                                                                index],
                                                        height:
                                                            size.height * 0.27,
                                                        width: size.width,
                                                        alignment:
                                                            Alignment.center,
                                                      )
                                                    : Image.file(
                                                      width: size.width,
                                                        File(
                                                          mentalStrengthEditProvider
                                                                  .pickedImages[
                                                              index],
                                                        ),
                                                        fit: BoxFit.fill,
                                                      ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              customPopup(
                                                context: context,
                                                onPressedDelete: () async {
                                                  mentalStrengthEditProvider.pickedImagesRemove(index);
                                                  Navigator.of(context).pop();
                                                  mentalStrengthEditProvider.removeMediaUploadResponseListFunction(index);
                                                  Navigator.of(context).pop();

                                                },
                                                yes: "Yes",
                                                title: 'Do you Need Delete',
                                                content: 'Are you sure do you need delete',
                                              );
                                              // mentalStrengthEditProvider
                                              //     .removeMediaFunction(
                                              //   context: context,
                                              //   id: mentalStrengthEditProvider
                                              //       .pickedImages[index],
                                              //   type: "journal",
                                              // );
                                              // mentalStrengthEditProvider
                                              //     .pickedImagesRemove(index);
                                            },
                                            child: CustomImageView(
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
              ),
              const SizedBox(height: 10),
              Consumer<MentalStrengthEditProvider>(
                builder: (context, mentalStrengthEditProvider, _) {
                  return mentalStrengthEditProvider.isVideoUploading
                      ? LinearProgressIndicator(
                          backgroundColor: Colors.grey[300],
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.blue),
                          // value: 0.8,
                        )
                      : const SizedBox();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
