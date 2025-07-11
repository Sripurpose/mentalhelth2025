import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/addactions_screen/provider/add_actions_provider.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/mental_strength_add_edit_page.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/logic/logic.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/video_player.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/functions/popup.dart';

Future galleryBottomSheetAction({
  required BuildContext context,
  required String title,
}) {
  return showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
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
                      imagePath: ImageConstant.imgClosePrimary,
                      height: 30,
                      width: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Consumer<AddActionsProvider>(
                  builder: (contexts, addActionsProvider, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (addActionsProvider.mediaSelected == 1) {
                          addActionsProvider.pickImageFunction(context);
                        }
                      },
                      child: buildAvatarImage(
                        widget: Icon(
                          Icons.photo_library,
                          color: ColorsContent.whiteText,
                        ),
                        imagePath: ImageConstant.imgThumbsUp,
                        size: size,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (addActionsProvider.mediaSelected == 1) {
                          addActionsProvider.pickVideoFunction(context);
                        }
                      },
                      child: buildAvatarImage(
                        widget: Icon(
                          Icons.video_collection_rounded,
                          color: ColorsContent.whiteText,
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
                child:
                    Consumer2<AddActionsProvider, MentalStrengthEditProvider>(
                  builder: (context, addActionsProvider,
                      mentalStrengthEditProvider, _) {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: size.height * 0.04,
                          ),
                          addActionsProvider.mediaSelected == 1
                              ? SizedBox(
                                  width: size.width * 0.85,
                                  height: addActionsProvider
                                          .alreadyPickedImages.isEmpty
                                      ? 0
                                      : ((addActionsProvider.alreadyPickedImages
                                                      .length /
                                                  2)
                                              .ceil() *
                                          size.height *
                                          0.217),
                                  child: GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: addActionsProvider
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
                                            child: isVideoPath(
                                              addActionsProvider
                                                  .alreadyPickedImages[index]
                                                  .value,
                                            )
                                                ? ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                                  child: SizedBox(
                                                    height: 200,
                                                    width: double.infinity,
                                                    child: VideoPlayerWidgetViewAndAlreadyAction(
                                                        videoUrl: addActionsProvider
                                                            .alreadyPickedImages[
                                                                index]
                                                            .value,
                                                      ),
                                                  ),
                                                )
                                                : addActionsProvider
                                                            .alreadyPickedImages[
                                                                index]
                                                            .value
                                                            .startsWith(
                                                                "http") ||
                                                        addActionsProvider
                                                            .alreadyPickedImages[
                                                                index]
                                                            .value
                                                            .startsWith("https")
                                                    ? ClipRRect(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(4),
                                                      child: CustomImageView(
                                                          fit: BoxFit.cover,
                                                          imagePath:
                                                              addActionsProvider
                                                                  .alreadyPickedImages[
                                                                      index]
                                                                  .value,
                                                          height:
                                                              size.height * 0.27,
                                                          width: size.width,
                                                          alignment:
                                                              Alignment.center,
                                                        ),
                                                    )
                                                    : ClipRRect(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(4),
                                                      child: Image.file(
                                                          File(
                                                            addActionsProvider
                                                                .alreadyPickedImages[
                                                                    index]
                                                                .value,
                                                          ),
                                                          height: 200,
                                                          fit: BoxFit.cover,
                                                          width: size.width,
                                                        ),
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
                                                    id: addActionsProvider
                                                        .alreadyPickedImages[
                                                            index]
                                                        .id
                                                        .toString(),
                                                    type: "action",
                                                  );
                                                  addActionsProvider
                                                      .alreadyPickedImagesRemove(
                                                          index);

                                                  Navigator.of(context).pop();

                                                  // Close the bottom sheet after deleting
                                                  Navigator.of(context)
                                                      .pop(); // This will close the galleryBottomSheet as well
                                                },
                                                yes: "Yes",
                                                title: 'Do you Need Delete',
                                                content:
                                                    'Are you sure do you need delete',
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
                          addActionsProvider.mediaSelected == 1
                              ? SizedBox(
                                  width: size.width * 0.85,
                                  height: addActionsProvider
                                          .pickedImages.isEmpty
                                      ? 0
                                      : addActionsProvider.pickedImages.length *
                                          size.height *
                                          0.2,
                                  child: GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        addActionsProvider.pickedImages.length,
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
                                              addActionsProvider
                                                  .pickedImages[index],
                                            )
                                                ? ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                                  child: SizedBox(
                                                    height: 200,
                                                    width: double.infinity,
                                                    child: VideoPlayerWidgetAction(
                                                        videoUrl: addActionsProvider
                                                            .pickedImages[index],
                                                      ),
                                                  ),
                                                )
                                                : addActionsProvider
                                                            .pickedImages[index]
                                                            .startsWith(
                                                                "http") ||
                                                        addActionsProvider
                                                            .pickedImages[index]
                                                            .startsWith("https")
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        child: CustomImageView(
                                                          fit: BoxFit.cover,
                                                          imagePath:
                                                              addActionsProvider
                                                                      .pickedImages[
                                                                  index],
                                                          height: size.height *
                                                              0.27,
                                                          width: size.width,
                                                          alignment:
                                                              Alignment.center,
                                                        ),
                                                      )
                                                    : ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        child: Image.file(
                                                          File(
                                                            addActionsProvider
                                                                    .pickedImages[
                                                                index],
                                                          ),
                                                          height: 200,
                                                          fit: BoxFit.cover,
                                                          width: size.width,
                                                        ),
                                                      ),
                                            // Image.file(
                                            //   File(
                                            //     addActionsProvider
                                            //         .pickedImages[index],
                                            //   ),
                                            //   fit: BoxFit.fill,
                                            // ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              customPopup(
                                                context: context,
                                                onPressedDelete: () async {
                                                  addActionsProvider
                                                      .removeMediaFunctionNotSave(
                                                    context: context,
                                                    file: addActionsProvider.addMediaUploadResponseList[index], // ✅ file name here
                                                    type: "action",
                                                  );
                                                  addActionsProvider
                                                      .pickedImagesRemove(
                                                          index);

                                                  Navigator.of(context).pop();

                                                  // Close the bottom sheet after deleting
                                                  Navigator.of(context)
                                                      .pop(); // This will close the galleryBottomSheet as well
                                                },
                                                yes: "Yes",
                                                title: 'Do you Need Delete',
                                                content:
                                                    'Are you sure do you need delete',
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
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Consumer<AddActionsProvider>(
                builder: (context, addActionsProvider, _) {
                  return addActionsProvider.isVideoUploading
                      ? LinearProgressIndicator(
                          backgroundColor: Colors.grey[300],
                          valueColor:
                               AlwaysStoppedAnimation<Color>(ColorsContent.newThemeColor),
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
