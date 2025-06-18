import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mentalhelth/screens/auth/subscribe_plan_page/subscribe_plan_page.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/utils/theme/custom_button_style.dart';
import 'package:mentalhelth/widgets/custom_elevated_button.dart';
import 'package:mentalhelth/widgets/custom_text_form_field.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:provider/provider.dart';

import '../../utils/theme/custom_text_style.dart';
import '../../widgets/app_bar/appbar_leading_image.dart';
import '../edit_add_profile_screen/provider/edit_provider.dart';
import 'provider/my_plan_provider.dart';

// ignore: must_be_immutable
class ConfirmPlanScreen extends StatelessWidget {
  ConfirmPlanScreen({Key? key, required this.planId})
      : super(
          key: key,
        );
  final String planId;
  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: buildAppBar(context, size, heading: "My plan", isSigned: false,
            onTap: () {
          Navigator.of(context).pop();
        }),
        body: SizedBox(
          width: size.width,
          child: Form(
            key: _formKey,
            child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  _buildNameEditText(context),
                  const SizedBox(height: 10),
                  _buildPhoneEditText(context),
                  const SizedBox(height: 11),
                  _buildEmailEditText(context),
                  const SizedBox(height: 26),
                  _buildPriceEditText(context, size),
                  const SizedBox(height: 16),
                  SizedBox(
                      child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: "Hi, a ",
                                style:
                                    CustomTextStyles.bodyMediumRobotoff333333),
                            TextSpan(
                                text: "Total payment of 1",
                                style:
                                    CustomTextStyles.titleSmallRobotoff333333),
                            TextSpan(
                                text:
                                    " will be charged from your select payment method for a monthly plan. please proceed to enjoy the premium service.",
                                style:
                                    CustomTextStyles.bodyMediumRobotoff333333)
                          ]),
                          textAlign: TextAlign.justify)),
                  const Spacer(),
                  _buildFortyNine(
                    context,
                    size,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildNameEditText(BuildContext context) {
    return Consumer<ConfirmPlanProvider>(
        builder: (context, confirmPlanProvider, _) {
          return PopScope(
            canPop: true,
            onPopInvoked: (value) {
              confirmPlanProvider.clearSignupControllers();
            },
            child: CustomTextFormField(
                controller: confirmPlanProvider.nameEditTextController,
                hintText: "Your Name",
                hintStyle: CustomTextStyles.bodySmallGray700),
          );
        });
  }


  /// Section Widget
  Widget _buildPhoneEditText(BuildContext context) {
    return Consumer<ConfirmPlanProvider>(
        builder: (context, confirmPlanProvider, _) {
          return CustomTextFormField(
              textInputType: TextInputType.number,
              controller: confirmPlanProvider.phoneEditTextController,
              hintText: "+1 00 000000",
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Only allow digits
                LengthLimitingTextInputFormatter(10),   // Limit to 10 digits
              ],
              validator: (value) {
                // Check if the field is empty or does not have exactly 10 digits
                if (value == null || value.isEmpty) {
                  return 'Please enter a phone number';
                } else if (value.length != 10) {
                  return 'Phone number must be 10 digits';
                }
                return null; // Valid input
              },
              hintStyle: CustomTextStyles.bodySmallGray500);
        });
  }


  /// Section Widget
  Widget _buildEmailEditText(BuildContext context) {
    return Consumer<ConfirmPlanProvider>(
        builder: (context, confirmPlanProvider, _) {
          return CustomTextFormField(
              controller: confirmPlanProvider.emailEditTextController,
              hintText: "Email ID",
              hintStyle: CustomTextStyles.bodySmallGray700,
              textInputType: TextInputType.emailAddress);
        });
  }


  /// Section Widget
  Widget _buildPriceEditText(BuildContext context, Size size) {
    return Consumer<ConfirmPlanProvider>(
        builder: (context, confirmPlanProvider, _) {
      return CustomElevatedButton(
        buttonStyle: ElevatedButton.styleFrom(
          backgroundColor: ColorsContent.newThemeColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                2,
              ),
            ),
          ),
        ),
        // width: size.width * 0.3,
        text:
            "Current plan - Monthly (\$${planId == "1" ? "1" : planId == "2" ? "5" : "9"}) ",
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SubscribePlanPage(),
          ));
        },
        underline: true,
        underLineText: " Change plan",
        buttonTextStyle: CustomTextStyles.bodyMediumWhite,
      );
    });
  }

  /// Section Widget
  Widget _buildPayNowButton(
    BuildContext context,
    Size size,
  ) {
    return Consumer2<EditProfileProvider,ConfirmPlanProvider>(
        builder: (contexts, editProfileProvider,confirmPlanProvider, _) {
      return CustomElevatedButton(
          loading: confirmPlanProvider.subScribePlanModelLoading,
          buttonStyle: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Small curve
            ),
            backgroundColor: ColorsContent.newThemeColor,
          ),
          width: size.width * 0.3,
          text: "Pay Now",
          onPressed: () {
            if (!isEmailValid(
                confirmPlanProvider.emailEditTextController.text)) {
              showToast(
                context: context,
                message: 'Enter a valid email address',
              );
            } else if (confirmPlanProvider
                    .nameEditTextController.text.isNotEmpty &&
                confirmPlanProvider.phoneEditTextController.text.isNotEmpty &&
                confirmPlanProvider.emailEditTextController.text.isNotEmpty) {
              confirmPlanProvider.subScribePlanFunction(
                context,
                planId: planId,
                firstname: confirmPlanProvider.nameEditTextController.text,
                email: confirmPlanProvider.emailEditTextController.text,
                phone: confirmPlanProvider.phoneEditTextController.text,
                isSubscription: editProfileProvider.getProfileModel?.isSubscribed ?? ""
              );
            } else {
              showToast(
                  context: context, message: 'Enter your name and number');
            }
          });
    });
  }

  /// Section Widget
  Widget _buildCancelButton(BuildContext context, Size size) {
    return CustomElevatedButton(
      width: size.width * 0.3,
      text: "Cancel",
      buttonStyle: CustomButtonStyles.fillPrimary,
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  /// Section Widget
  Widget _buildFortyNine(BuildContext context, Size size) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      _buildPayNowButton(
        context,
        size,
      ),
      _buildCancelButton(
        context,
        size,
      )
    ]);
  }

  bool isEmailValid(String email) {
    // Basic email validation using regex
    // You can implement more complex validation if needed
    return RegExp(r'^[\w-\.]+@[a-zA-Z]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }
}
