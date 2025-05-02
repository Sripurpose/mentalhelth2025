import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/utils/logic/shared_prefrence.dart';
import 'package:mentalhelth/utils/theme/custom_button_style.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:mentalhelth/widgets/custom_elevated_button.dart';
import 'package:provider/provider.dart';

import '../../utils/core/image_constant.dart';
import '../../utils/theme/theme_helper.dart';
import '../../widgets/functions/popup.dart';
import 'provider/delete_provider.dart';

// ignore: must_be_immutable
class ConfirmDeleteScreen extends StatelessWidget {
  ConfirmDeleteScreen({Key? key})
      : super(
          key: key,
        );

  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
          image: DecorationImage(
            image: AssetImage(
              ImageConstant.imgGroup193,
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SizedBox(
          width: double.maxFinite,
          // padding: const EdgeInsets.symmetric(
          //   horizontal: 30,
          //   vertical: 32,
          // ),
          child: Column(
            children: [
              buildAppBar(context, size, heading: "Delete Account"),
              const Spacer(
                flex: 44,
              ),
              Container(
                width: 249,
                margin: const EdgeInsets.only(
                  left: 42,
                  right: 41,
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Are you sure you want to ",
                        style: CustomTextStyles.bodyMediumRobotoff333333,
                      ),
                      TextSpan(
                        text:
                            "delete your account and data forever, you cannot undo this action",
                        style:
                            CustomTextStyles.titleSmallRobotoff333333ExtraBold,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(
                flex: 55,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 32,
                ),
                child: _buildConfirmDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget

  /// Section Widget
  Widget _buildConfirmDelete(BuildContext context) {
    return Consumer2<DeleteProvider, DashBoardProvider>(
        builder: (context, deleteProvider, dashBoardProvider, _) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomElevatedButton(
            loading: deleteProvider.deleteAccountLoading,
            onPressed: () async {
              customPopupDelete(
                context: context,
                onPressedDelete: () async {
                  await deleteProvider.deleteAccount(context: context);
                  removeAllValuesLogout(context: context);
                  dashBoardProvider.changeCommentPage(
                    index: 0,
                  );
                },
                yes: "Delete Account",
                title: 'Delete your account',
                content: 'You will lose all of your data by deleting your account. This action cannot be undone',
              );

            },
            width: 104,
            text: "Delete",
            margin: const EdgeInsets.only(top: 1),
            buttonStyle: CustomButtonStyles.outlinePrimary,
          ),
          CustomElevatedButton(
            width: 104,
            text: "Cancel",
            buttonStyle: CustomButtonStyles.fillPrimary,
            onPressed: () {
              dashBoardProvider.changeCommentPage(
                index: 0,
              );
            },
          ),
        ],
      );
    });
  }
}
