import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/mental_strength_add_edit_page.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/logic/logic.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/video_player.dart';
import 'package:provider/provider.dart';

import '../../../../utils/theme/colors.dart';
import '../../../../widgets/functions/popup.dart';
import '../../../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import '../../provider/add_actions_provider.dart';

Future cameraBottomSheetAction({
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
                        if (addActionsProvider.mediaSelected == 2) {
                          addActionsProvider.takeFileFunction(context);
                        }
                      },
                      child: buildAvatarImage(
                        widget:  Icon(
                          Icons.camera_alt,
                          color: ColorsContent.whiteText,
                        ),
                        imagePath: ImageConstant.imgCamera,
                        size: size,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (addActionsProvider.mediaSelected == 2) {
                          addActionsProvider.takeVideoFunction(context);
                        }
                      },
                      child: buildAvatarImage(
                        widget:  Icon(
                          Icons.video_collection_rounded,
                          color: ColorsContent.whiteText,
                        ),
                        imagePath: ImageConstant.imgCamera,
                        size: size,
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 10),
              Consumer2<AddActionsProvider,MentalStrengthEditProvider>(
                builder: (context, addActionsProvider,mentalStrengthEditProvider, _) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: size.height * 0.04,
                        ),
                        addActionsProvider.mediaSelected == 2
                            ? SizedBox(
                                width: size.width * 0.85,
                                height: addActionsProvider.takedImages.isEmpty
                                    ? 0
                                    : size.height * 0.3,
                                child: GridView.builder(
                                 // physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      addActionsProvider.takedImages.length,
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
                                            addActionsProvider
                                                .takedImages[index],
                                          )
                                              ? ClipRRect(
                                            borderRadius:
                                            BorderRadius.circular(4),
                                                child: VideoPlayerWidgetAction(
                                                    videoUrl: addActionsProvider
                                                        .takedImages[index],
                                                  ),
                                              )
                                              : ClipRRect(
                                            borderRadius:
                                            BorderRadius.circular(4),
                                                child: Image.file(
                                                    File(addActionsProvider
                                                        .takedImages[index]),
                                                    fit: BoxFit.cover,
                                                  ),
                                              ),
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
                                                addActionsProvider.takedImagesRemove(index);
                                                Navigator.of(context).pop();

                                                // Close the bottom sheet after deleting
                                                Navigator.of(context).pop();  // This will close the galleryBottomSheet as well
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
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Consumer<AddActionsProvider>(
                  builder: (context, addActionsProvider, _) {
                return addActionsProvider.isVideoUploading
                    ? LinearProgressIndicator(
                        backgroundColor: Colors.grey[300],
                        valueColor:
                             AlwaysStoppedAnimation<Color>(ColorsContent.newThemeColor),
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
