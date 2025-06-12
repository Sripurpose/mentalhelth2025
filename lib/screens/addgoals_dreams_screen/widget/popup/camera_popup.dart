import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/mental_strength_add_edit_page.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/logic/logic.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/video_player.dart';
import 'package:provider/provider.dart';

import '../../../../utils/theme/colors.dart';
import '../../../../widgets/functions/popup.dart';
import '../../../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';

Future cameraBottomSheetAdGoals({
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
                        if (adDreamsGoalsProvider.mediaSelected == 2) {
                          adDreamsGoalsProvider.takeFileFunction( context);
                        }
                      },
                      child: buildAvatarImage(
                        widget:  Icon(
                          Icons.camera_alt,
                          color: ColorsContent.newThemeColor,
                        ),
                        imagePath: ImageConstant.imgCamera,
                        size: size,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (adDreamsGoalsProvider.mediaSelected == 2) {
                          adDreamsGoalsProvider.takeVideoFunction(context);
                        }
                      },
                      child: buildAvatarImage(
                        widget:  Icon(
                          Icons.video_collection_rounded,
                          color: ColorsContent.newThemeColor,
                        ),
                        imagePath: ImageConstant.imgCamera,
                        size: size,
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 10),
              Consumer2<MentalStrengthEditProvider,AdDreamsGoalsProvider>(
                builder: (context, mentalStrengthEditProvider,adDreamsGoalsProvider, _) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: size.height * 0.04,
                        ),
                        adDreamsGoalsProvider.mediaSelected == 2
                            ? SizedBox(
                          width: size.width * 0.85,
                                height:
                                    adDreamsGoalsProvider.takedImages.isEmpty
                                        ? 0
                                        : size.height * 0.3,
                                child: GridView.builder(
                                 // physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      adDreamsGoalsProvider.takedImages.length,
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
                                            adDreamsGoalsProvider
                                                .takedImages[index],
                                          )
                                              ? ClipRRect(
                                            borderRadius:
                                            BorderRadius.circular(4),
                                                child: VideoPlayerWidget(
                                                  videoUrl:
                                                      adDreamsGoalsProvider
                                                              .takedImages[
                                                          index],
                                                ),
                                              )
                                              : ClipRRect(
                                                borderRadius:
                                                BorderRadius.circular(4),
                                                child: Image.file(
                                                  File(adDreamsGoalsProvider
                                                      .takedImages[index]),
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
                                                      .takedImages[index],
                                                  type: "goal",
                                                );
                                                adDreamsGoalsProvider
                                                    .takedImagesRemove(index);

                                                Navigator.of(context).pop();

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
              Consumer<AdDreamsGoalsProvider>(
                  builder: (context, adDreamsGoalsProvider, _) {
                return adDreamsGoalsProvider.isVideoUploading
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
