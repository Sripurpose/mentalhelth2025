import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/mental_strength_add_edit_page.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/logic/logic.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/video_player.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/functions/popup.dart';

Future galleryBottomSheetAddGoals({
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
                      imagePath: ImageConstant.imgClosePrimaryNew,
                      height: 40,
                      width: 40,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Consumer<AdDreamsGoalsProvider>(
                  builder: (contexts, adDreamsGoalsProvider, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (adDreamsGoalsProvider.mediaSelected == 1) {
                          adDreamsGoalsProvider.pickImageFunction(context);
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
                        if (adDreamsGoalsProvider.mediaSelected == 1) {
                          adDreamsGoalsProvider.pickVideoFunction(context);
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
                child: Consumer2<AdDreamsGoalsProvider,
                    MentalStrengthEditProvider>(
                  builder: (context, adDreamsGoalsProvider,
                      mentalStrengthEditProvider, _) {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: size.height * 0.045,
                          ),
                          adDreamsGoalsProvider.mediaSelected == 1
                              ? Container(
                                  width: size.width * 0.85,
                                  height: adDreamsGoalsProvider
                                          .alreadyPickedImages.isEmpty
                                      ? 0
                                      : ((adDreamsGoalsProvider
                                                      .alreadyPickedImages
                                                      .length /
                                                  2)
                                              .ceil() *
                                          size.height *
                                          0.217),
                                  child: GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: adDreamsGoalsProvider
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
                                              adDreamsGoalsProvider
                                                  .alreadyPickedImages[index]
                                                  .value,
                                            )
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    child: SizedBox(
                                                      height: 200,
                                                      width: double.infinity,
                                                      child: VideoPlayerWidgetViewAndAlreadyGoal(
                                                        videoUrl:
                                                            adDreamsGoalsProvider
                                                                .alreadyPickedImages[
                                                                    index]
                                                                .value,
                                                      ),
                                                    ),
                                                  )
                                                : adDreamsGoalsProvider
                                                            .alreadyPickedImages[
                                                                index]
                                                            .value
                                                            .startsWith(
                                                                "http") ||
                                                        adDreamsGoalsProvider
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
                                                              adDreamsGoalsProvider
                                                                  .alreadyPickedImages[
                                                                      index]
                                                                  .value,
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
                                                            adDreamsGoalsProvider
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
                                                    id: adDreamsGoalsProvider
                                                        .alreadyPickedImages[
                                                            index]
                                                        .id
                                                        .toString(),
                                                    type: "goal",
                                                  );
                                                  adDreamsGoalsProvider
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
                          adDreamsGoalsProvider.mediaSelected == 1
                              ? SizedBox(
                                  width: size.width * 0.85,
                                  height:
                                      adDreamsGoalsProvider.pickedImages.isEmpty
                                          ? 0
                                          : adDreamsGoalsProvider
                                                  .pickedImages.length *
                                              size.height *
                                              0.2,
                                  child: GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: adDreamsGoalsProvider
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
                                              adDreamsGoalsProvider
                                                  .pickedImages[index],
                                            )
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    child: SizedBox(
                                                      height: 200,
                                                      width: double.infinity,
                                                      child: VideoPlayerWidgetGoal(
                                                        videoUrl:
                                                            adDreamsGoalsProvider
                                                                    .pickedImages[
                                                                index],
                                                      ),
                                                    ),
                                                  )
                                                : adDreamsGoalsProvider
                                                            .pickedImages[index]
                                                            .startsWith(
                                                                "http") ||
                                                        adDreamsGoalsProvider
                                                            .pickedImages[index]
                                                            .startsWith("https")
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        child: CustomImageView(
                                                          fit: BoxFit.cover,
                                                          imagePath:
                                                              adDreamsGoalsProvider
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
                                                            adDreamsGoalsProvider
                                                                    .pickedImages[
                                                                index],
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
                                                  adDreamsGoalsProvider
                                                      .removeMediaFunctionNotSave(
                                                    context: context,
                                                    file: adDreamsGoalsProvider.addMediaUploadResponseList[index], // ✅ file name here
                                                    type: "goal",
                                                  );
                                                  adDreamsGoalsProvider
                                                      .pickedImagesRemove(
                                                          index);
                                                  Navigator.of(context).pop();
                                                  adDreamsGoalsProvider
                                                      .removeMediaUploadResponseListFunction(
                                                          index);
                                                  Navigator.of(context).pop();
                                                },
                                                yes: "Yes",
                                                title: 'Do you Need Delete',
                                                content:
                                                    'Are you sure do you need delete?',
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
              Consumer<AdDreamsGoalsProvider>(
                builder: (context, adDreamsGoalsProvider, _) {
                  return adDreamsGoalsProvider.isVideoUploading
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
