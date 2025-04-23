import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../screens/edit_add_profile_screen/provider/edit_provider.dart';
import '../utils/theme/colors.dart';

void showChangePasswordDialog(BuildContext context,EditProfileProvider editProfileProvider) {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      bool obscureCurrent = true;
      bool obscureNew = true;
      bool obscureConfirm = true;

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Center(
                        child: Text(
                          "Change Password",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ColorsContent.newThemeColor,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.deepPurple.shade100,
                            child: Icon(
                              Icons.close_sharp,
                              color: ColorsContent.newThemeColor,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  _buildPasswordField("Current Password", currentPasswordController, obscureCurrent, () {
                    setState(() => obscureCurrent = !obscureCurrent);
                  }),
                  const SizedBox(height: 10),
                  _buildPasswordField("New Password", newPasswordController, obscureNew, () {
                    setState(() => obscureNew = !obscureNew);
                  }),
                  const SizedBox(height: 10),
                  _buildPasswordField("Confirm Password", confirmPasswordController, obscureConfirm, () {
                    setState(() => obscureConfirm = !obscureConfirm);
                  }),
                  const SizedBox(height: 20),
                  Consumer<EditProfileProvider>(
                    builder: (context, editProfileProvider, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsContent.newThemeColor,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            final current = currentPasswordController.text.trim();
                            final newPass = newPasswordController.text.trim();
                            final confirm = confirmPasswordController.text.trim();

                            if (current.isEmpty) {
                              Fluttertoast.showToast(
                                  msg: "Please enter your current password",
                                  gravity: ToastGravity.CENTER);
                              return;
                            }
                            if (newPass.isEmpty) {
                              Fluttertoast.showToast(
                                  msg: "Please enter a new password",
                                  gravity: ToastGravity.CENTER);
                              return;
                            }
                            if (confirm.isEmpty) {
                              Fluttertoast.showToast(
                                  msg: "Please confirm your new password",
                                  gravity: ToastGravity.CENTER);
                              return;
                            }
                            if (newPass != confirm) {
                              Fluttertoast.showToast(
                                  msg: "New password and confirmation do not match",
                                  gravity: ToastGravity.CENTER);
                              return;
                            }
                            String deviceType = Platform.isAndroid ? 'android' : 'ios';
                            await editProfileProvider.changePassword(
                              context,
                              oldPassword: current,
                              newPassword: confirm,
                                deviceType:deviceType
                            );

                            if (editProfileProvider.changePasswordStatus == 200) {
                              Fluttertoast.showToast(
                                  msg: "Password updated successfully!",
                                  gravity: ToastGravity.CENTER);

                              Navigator.of(context).pop();
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Please try again later!",
                                  gravity: ToastGravity.CENTER);

                              currentPasswordController.clear();
                              newPasswordController.clear();
                              confirmPasswordController.clear();
                            }
                          },
                          child: editProfileProvider.changePasswordLoading
                              ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: SpinKitWave(
                              color: Colors.white, // or whatever suits your theme
                              size: 25,
                            ),
                          )
                              : Text(
                            "Update Password",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Open Sans',
                              color: ColorsContent.whiteText,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                ],
              ),
            ),
          );
        },
      );
    },
  );

}

Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscureText,
    VoidCallback onToggle,
    ) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          fontFamily: 'Open Sans',
          color: ColorsContent.goalCompletedTextColor,
        ),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 0.6, color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 0.6, color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 0.8, color: Colors.deepPurple),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    ],
  );
}

