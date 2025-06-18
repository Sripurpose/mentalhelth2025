import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mentalhelth/utils/theme/colors.dart';

import '../../utils/core/image_constant.dart';

void customPopup({
  required BuildContext context,
  required void Function()? onPressedDelete,
  required String title,
  required String content,
  String? cancel,
  String? yes,
}) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text(
          title,
          style:  TextStyle(
            fontWeight: FontWeight.bold, // Bold text
            fontSize: 18, // Adjust font size
            color: ColorsContent.newThemeColor,
          ),
        ),
        content: Text(
          content,
          style:  TextStyle(
            fontWeight: FontWeight.normal, // Bold text
            fontSize: 14, // Adjust font size
            color: ColorsContent.blackText,
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () {
              // Close the dialog without deleting anything
              Navigator.of(context).pop();
            },
            child: Text(
              cancel ?? 'Cancel',
              style:  TextStyle(
                color: ColorsContent.newThemeColor,
              ),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true, // Indicates destructive action (delete)
            onPressed: onPressedDelete,
            child: Text(
              yes ?? 'Delete',
              style:  TextStyle(
                color: ColorsContent.newThemeColor,
              ),
            ),
          ),
        ],
      );
    },
  );
  // showDialog(
  //   context: context,
  //   builder: (BuildContext context) {
  //     return AlertDialog(
  //       title: const Text('Confirm Delete'),
  //       content: const Text('Are you sure you want to delete?'),
  //       actions: <Widget>[
  //         TextButton(
  //           onPressed: () {
  //             // Close the dialog without deleting anything
  //             Navigator.of(context).pop();
  //           },
  //           child: const Text('Cancel'),
  //         ),
  //         const Spacer(),
  //         ElevatedButton(
  //           onPressed: onPressedDelete,
  //           child: const Text('Delete'),
  //         ),
  //       ],
  //     );
  //   },
  // );
}

void customPopupDelete({
  required BuildContext context,
  required void Function()? onPressedDelete,
  required String title,
  required String content,
  String? cancel,
  String? yes,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // const Icon(
              //   Icons.error,
              //   color: Colors.red,
              //   size: 60,
              // ),

              Image.asset(
                ImageConstant.delete_account_icon_png, // This should be the path to your PNG image
                // color: theme.colorScheme.primary.withOpacity(1),
                height: 60,
                width: 60,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                content,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsContent.newThemeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog first
                    if (onPressedDelete != null) onPressedDelete();
                  },
                  child: Text(
                    yes ?? 'Delete Account',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    cancel ?? 'Cancel',
                    style: const TextStyle(color: Colors.grey,fontSize: 17,fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void customPopupNew({
  required BuildContext context,
  required Future<void> Function()? onPressedDelete,
  required String title,
  required String content,
  String? cancel,
  String? yes,
}) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      bool isLoading = false; // State variable to track loading

      return StatefulBuilder(
        builder: (context, setState) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(content),
                if (isLoading) // Show loading indicator if loading
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Center(child: CupertinoActivityIndicator()),
                  ),
              ],
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  // Close the dialog without deleting anything
                  Navigator.of(context).pop();
                },
                child: Text(
                  cancel ?? 'Cancel',
                  style:  TextStyle(color: ColorsContent.newThemeColor),
                ),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true, // Indicates destructive action (delete)
                onPressed: () async {
                  setState(() {
                    isLoading = true; // Set loading to true
                  });
                  try {
                    await onPressedDelete?.call(); // Call the delete function
                  } catch (e) {
                    // Handle any errors that occur during the delete action
                    print("Error during delete action: $e");
                    // Optionally show an error message to the user here
                  } finally {
                  //  Navigator.of(context).pop(); // Close the dialog after action
                  }
                },
                child: Text(
                  yes ?? 'Delete',
                  style: TextStyle(color:  ColorsContent.newThemeColor),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

void customPopupLogout({
  required BuildContext context,
  required void Function()? onPressedDelete,
  required String title,
  required String content,
  String? cancel,
  String? yes,
}) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text(
          title,
        ),
        content: Text(
          content,
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () {
              // Close the dialog without deleting anything
              Navigator.of(context).pop();
            },
            child: Text(
              cancel ?? 'Cancel',
              style:  TextStyle(
                color: ColorsContent.newThemeColor,
              ),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true, // Indicates destructive action (delete)
            onPressed: onPressedDelete,
            child: Text(
              yes ?? 'Delete',
              style:  TextStyle(
                color: ColorsContent.newThemeColor,
              ),
            ),
          ),
        ],
      );
    },
  );
  // showDialog(
  //   context: context,
  //   builder: (BuildContext context) {
  //     return AlertDialog(
  //       title: const Text('Confirm Delete'),
  //       content: const Text('Are you sure you want to delete?'),
  //       actions: <Widget>[
  //         TextButton(
  //           onPressed: () {
  //             // Close the dialog without deleting anything
  //             Navigator.of(context).pop();
  //           },
  //           child: const Text('Cancel'),
  //         ),
  //         const Spacer(),
  //         ElevatedButton(
  //           onPressed: onPressedDelete,
  //           child: const Text('Delete'),
  //         ),
  //       ],
  //     );
  //   },
  // );
}



void settingsPopup({
  required BuildContext context,
  required Future<void> Function()? onPressedYes,
  required Future<void> Function()? onCancelYes,
  required String title,
  required String content,
  String? cancel,
  String? yes,
}) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false, // Disable back press
        child: GestureDetector(
          onTap: () {}, // Prevent taps outside the dialog to close it
          child: Stack(
            children: [
              // Background blur effect
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0), // Transparent container for the blur
                ),
              ),
              CupertinoAlertDialog(
                title: Text(title),
                content: Text(content),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () async {
                      if (onCancelYes != null) {
                        await onCancelYes(); // Wait for async operation
                      }
                    },
                    child: Text(
                      cancel ?? 'Cancel',
                      style:  TextStyle(
                        color: ColorsContent.newThemeColor,
                      ),
                    ),
                  ),
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    onPressed: () async {
                      if (onPressedYes != null) {
                        await onPressedYes(); // Wait for async operation
                      }
                    },
                    child: Text(
                      yes ?? 'Delete',
                      style:  TextStyle(
                        color: ColorsContent.newThemeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}


