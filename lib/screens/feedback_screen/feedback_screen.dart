import 'package:flutter/material.dart';
import 'package:mentalhelth/utils/theme/custom_button_style.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:mentalhelth/widgets/background_image/background_imager.dart';
import 'package:mentalhelth/widgets/custom_elevated_button.dart';
import 'package:mentalhelth/widgets/custom_text_form_field.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:provider/provider.dart';

import '../../utils/theme/custom_text_style.dart';
import '../dash_borad_screen/dash_board_screen.dart';
import '../no_internet/duplicate_screen.dart';
import 'provider/feed_back_provider.dart';

// ignore: must_be_immutable
class FeedbackScreen extends StatelessWidget {
  FeedbackScreen({Key? key})
      : super(
          key: key,
        );

  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ConnectivityWidget(
      child: SafeArea(
        child: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          appBar: buildAppBar(
            context,
            size,
            heading: "Feedback",
          ),
          body: backGroundImager(
            size: size,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Form(
                key: _formKey,
                child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.only(
                    left: 28,
                    top: 103,
                    right: 28,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 80),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 2),
                          child: Text(
                            "Name *",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Open Sans',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      _buildNameEditText(context),
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 2),
                          child: Text(
                            "Email *",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Open Sans',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      _buildEmailEditText(context),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Text(
                            "Your Message",
                            style: CustomTextStyles.bodyMedium14,
                          ),
                        ),
                      ),
                      _buildMessageEditText(context),
                      const SizedBox(height: 28),
                      _buildSubmitButton(context),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildNameEditText(BuildContext context) {
    return Consumer<FeedBackProvider>(builder: (context, feedBackProvider, _) {
      return CustomTextFormFieldPhoneNumberFeedbackNumu(
        controller: feedBackProvider.nameEditTextController,
        hintText: "Enter your name",
      );
    });
  }

  /// Section Widget
  Widget _buildEmailEditText(BuildContext context) {
    return Consumer<FeedBackProvider>(builder: (context, feedBackProvider, _) {
      return CustomTextFormFieldPhoneNumberFeedbackNumu(
        controller: feedBackProvider.emailEditTextController,
        hintText: "Enter your email",
        textInputType: TextInputType.emailAddress,
      );
    });
  }

  /// Section Widget
  Widget _buildMessageEditText(BuildContext context) {
    return Consumer<FeedBackProvider>(builder: (context, feedBackProvider, _) {
      return CustomTextFormFieldPhoneNumberFeedbackNumu(
        maxLines: 8,
        controller: feedBackProvider.messageEditTextController,
        textInputAction: TextInputAction.done,
      );
    });
  }

  /// Section Widget
  Widget _buildSubmitButton(BuildContext context) {
    return Consumer<FeedBackProvider>(
      builder: (context, feedBackProvider, _) {
        return CustomElevatedButton(
          loading: feedBackProvider.saveFeedBackLoading,
          onPressed: () {
            if (feedBackProvider.nameEditTextController.text.isNotEmpty &&
                feedBackProvider.emailEditTextController.text.isNotEmpty) {
              feedBackProvider.saveFeedBack(
                context,
                name: feedBackProvider.nameEditTextController.text,
                email: feedBackProvider.emailEditTextController.text,
                message: feedBackProvider.messageEditTextController.text,
              );
            } else if (!isEmailValid(
                feedBackProvider.emailEditTextController.text)) {
              showToastTop(context: context, message: 'Enter a valid email address');
            } else {
              showToastTop(context: context, message: 'Enter your name and email');
            }
          },
          width: 104,
          text: "Submit",
          buttonStyle: CustomButtonStyles.outlineNewTheme,
        );
      },
    );
  }

  bool isEmailValid(String email) {
    // Basic email validation using regex
    // You can implement more complex validation if needed
    return RegExp(r'^[\w-\.]+@[a-zA-Z]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }
}
