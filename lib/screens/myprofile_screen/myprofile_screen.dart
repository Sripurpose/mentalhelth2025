import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/myprofile_screen/verifyEmail/send_otp_mail_screen.dart';
import 'package:mentalhelth/screens/myprofile_screen/verifyEmail/verifyOtpScreen.dart';
import 'package:mentalhelth/screens/myprofile_screen/verifyPhone/send_otp_phone_screen.dart';
import 'package:mentalhelth/screens/myprofile_screen/verifyPhone/verifyOtpScreenPhone.dart';
import 'package:mentalhelth/screens/phone_singin_screen/phone_sign_in_screen.dart';
import 'package:mentalhelth/screens/phone_singin_screen/provider/phone_sign_in_provider.dart';
import 'package:mentalhelth/utils/logic/date_format.dart';
import 'package:mentalhelth/utils/logic/logic.dart';
import 'package:mentalhelth/utils/theme/app_decoration.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:mentalhelth/widgets/background_image/background_imager.dart';
import 'package:provider/provider.dart';

import '../../utils/theme/custom_text_style.dart';
import '../../widgets/functions/snack_bar.dart';
import '../home_screen/provider/home_provider.dart';
import '../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import '../token_expiry/tocken_expiry_warning_screen.dart';
import '../token_expiry/token_expiry.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key})
      : super(
    key: key,
  );

  @override
  State<MyProfileScreen> createState() =>
      _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late HomeProvider homeProvider;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  late EditProfileProvider editProfileProvider;
  late DashBoardProvider dashBoardProvider;
  bool tokenStatus = false;
  var logger = Logger();


  Future<void> _isTokenExpired() async {
    await homeProvider.fetchChartView(context);
    await homeProvider.fetchJournals(initial: true);
    await editProfileProvider.fetchUserProfile();
    tokenStatus = TokenManager.checkTokenExpiry();
    if (tokenStatus) {
      setState(() {
        logger.e("Token status changed: $tokenStatus");
      });
      logger.e("Token status changed: $tokenStatus");
    }else{
      logger.e("Token status changedElse: $tokenStatus");
    }

  }

  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    mentalStrengthEditProvider = Provider.of<MentalStrengthEditProvider>(context, listen: false);
    dashBoardProvider = Provider.of<DashBoardProvider>(context, listen: false);
    editProfileProvider = Provider.of<EditProfileProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      editProfileProvider.getProfileModel?.profileurl = "";
      _isTokenExpired();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return  tokenStatus == false ?
      SafeArea(
      child: backGroundImager(
        size: size,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            buildAppBar(
              context,
              size,
            ),
            Container(
              height: size.height * 0.75,
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 21,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            top: size.height * 0.055,
                          ),
                          child: Opacity(
                            opacity: 0.9,
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                height: size.height * 0.64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade300, // Set your desired border color here
                                    width: 1.0, // Optional: set the width of the border
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    30,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Consumer<EditProfileProvider>(
                            builder: (context, editProfileProvider, _) {
                          return Container(
                            margin: const EdgeInsets.only(
                                // top: size.height * 0.004,
                                ),
                            height: size.height * 0.11,
                            width: size.height * 0.11,
                            decoration: AppDecoration.fillBlueGray.copyWith(
                              borderRadius: BorderRadiusStyle.circleBorder54,
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: NetworkImage(
                                editProfileProvider.getProfileModel?.profileurl
                                        .toString() ??
                                    "",
                              ),
                              radius: size.width * 0.1,
                            ),
                          );
                        }),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                            ),
                            child: Consumer2<EditProfileProvider,
                                    PhoneSignInProvider>(
                                builder: (context, editProfileProvider,
                                    phoneSignInProvider, _) {
                              return editProfileProvider.getProfileLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : editProfileProvider.getProfileModel == null
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              height: size.height * 0.13,
                                            ),
                                            SizedBox(
                                              width: size.width * 0.55,
                                              child: Align(
                                                alignment: Alignment.center, // Center-align horizontally
                                                child: SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                                                  child: Text(
                                                    capitalText(
                                                      editProfileProvider.getProfileModel == null
                                                          ? ""
                                                          : editProfileProvider.getProfileModel!.firstname.toString(),
                                                    ),
                                                    style: CustomTextStyles.bodyLarge18,
                                                    textAlign: TextAlign.center,
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 53),
                                                child: Text(
                                                  "Member since ${editProfileProvider.getProfileModel?.createdAt == null || editProfileProvider.getProfileModel?.createdAt == null ? "" : formatTimestampToDate(editProfileProvider.getProfileModel!.createdAt.toString())}",
                                                  style: CustomTextStyles
                                                      .bodyMediumGray700,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 27),
                                            Container(
                                              width: 238,
                                              margin: const EdgeInsets.only(
                                                left: 25,
                                                right: 27,
                                              ),
                                              child: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    editProfileProvider.getProfileModel!.phone!.isNotEmpty ?
                                                    TextSpan(
                                                      text:
                                                          "+${editProfileProvider.getProfileModel!.countryCode} ${editProfileProvider.getProfileModel!.phone}\n",
                                                      style: CustomTextStyles
                                                          .bodyLargeff000000,
                                                    ):
                                                    TextSpan(
                                                      text:
                                                      "",
                                                      style: CustomTextStyles
                                                          .bodyLargeff000000,
                                                    ),
                                                    editProfileProvider
                                                                    .getProfileModel!
                                                                    .phone ==
                                                                null ||
                                                            editProfileProvider
                                                                    .getProfileModel!
                                                                    .phone ==
                                                                ""
                                                        ? const TextSpan(
                                                            text: "\n",
                                                          )
                                                        : editProfileProvider
                                                                    .getProfileModel!
                                                                    .phoneVerify ==
                                                                "1"
                                                            ? const TextSpan(
                                                                text: "\n",
                                                              )
                                                            : TextSpan(
                                                                text:
                                                                    "Verify Phone\n\n",
                                                                style: CustomTextStyles
                                                                    .labelLargeff59a9f2
                                                                    .copyWith(
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                ),
                                                                recognizer:
                                                                    TapGestureRecognizer()
                                                                      ..onTap =
                                                                          () async {
                                                                        if (editProfileProvider.getProfileModel!.phone !=
                                                                            null) {
                                                                          await editProfileProvider.sendOtpPhoneFunction(context);
                                                                          if(editProfileProvider.sendOtpPhoneStatus == 200){

                                                                            Future.delayed(Duration.zero, () {
                                                                              Navigator.of(context).push(
                                                                                MaterialPageRoute(
                                                                                  builder: (context) => const VerifyOtpPhoneScreen(),
                                                                                ),
                                                                              );
                                                                            });

                                                                          }else{
                                                                            showToast(
                                                                              context: context,
                                                                              message: editProfileProvider.sendOtpPhoneMessage ?? "",
                                                                            );
                                                                          }
                                                                          // Navigator.of(context)
                                                                          //     .push(
                                                                          //   MaterialPageRoute(
                                                                          //     builder: (context) =>  SendOtpPhoneScreen(),
                                                                          //   ),
                                                                          // );
                                                                        } else {
                                                                          // phoneSignInProvider.addPhoneNumber(editProfileProvider
                                                                          //     .getProfileModel!
                                                                          //     .phone
                                                                          //     .toString());
                                                                          // await phoneSignInProvider
                                                                          //     .phoneLoginUser(
                                                                          //   context,
                                                                          //   phone:
                                                                          //       editProfileProvider.getProfileModel!.phone ?? '',
                                                                          // );
                                                                        }
                                                                      },
                                                              ),

                                                    TextSpan(
                                                      text:
                                                          "${editProfileProvider.getProfileModel!.email}\n",
                                                      style: CustomTextStyles
                                                          .bodyLargeff000000,
                                                    ),
                                                    if(editProfileProvider.getProfileModel!.emailVerify != "1" && editProfileProvider.getProfileModel!.email!.isNotEmpty)
                                                    TextSpan(
                                                      text: "Verify Email\n\n",
                                                      style: CustomTextStyles
                                                          .labelLargeff59a9f2
                                                          .copyWith(
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                        recognizer:TapGestureRecognizer()
                                                          ..onTap =
                                                              () async {
                                                            if (editProfileProvider.getProfileModel!.email !=
                                                                null) {
                                                              await editProfileProvider.sendOtpFunction(context);
                                                              if (editProfileProvider.sendOtpStatus == 200) {
                                                                // Schedule the navigation to happen after the current frame
                                                                Future.delayed(Duration.zero, () {
                                                                  Navigator.of(context).push(
                                                                    MaterialPageRoute(
                                                                      builder: (context) => const VerifyOtpScreen(),
                                                                    ),
                                                                  );
                                                                });

                                                              } else {
                                                                showToast(
                                                                  context: context,
                                                                  message: editProfileProvider.sendOtpMailMessage ?? "",
                                                                );
                                                              }

                                                              // Navigator.of(context).push(
                                                              //   MaterialPageRoute(
                                                              //     builder: (context) => const SendOtpMailScreen(),
                                                              //   ),
                                                              // );
                                                            } else {
                                                              // Navigator.of(context)
                                                              //     .push(
                                                              //   MaterialPageRoute(
                                                              //     builder: (context) => const SendOtpMailScreen(),
                                                              //   ),
                                                              // );
                                                            }
                                                          },
                                                    ),
                                                    TextSpan(
                                                      text: "Date Of Birth\n",
                                                      style: CustomTextStyles
                                                          .titleMediumff000000,
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          "${editProfileProvider.getProfileModel!.dob == null || editProfileProvider.getProfileModel!.dob == null ? "" : dateFormatter(date: editProfileProvider.getProfileModel!.dob.toString())}\n\n",
                                                      style: CustomTextStyles
                                                          .bodyLargeff000000,
                                                    ),
                                                    TextSpan(
                                                      text: "Interests\n",
                                                      style: CustomTextStyles
                                                          .titleMediumff000000,
                                                    ),
                                                    TextSpan(
                                                      text: editProfileProvider.getProfileModel!.interests
                                                          ?.split(',') // Split the interests string by commas into a list
                                                          .map((e) => e.trim()) // Trim spaces around each interest
                                                          .toSet() // Convert to a Set to remove duplicates
                                                          .join(', '), // Join them back into a single string with commas
                                                      style: CustomTextStyles.bodyLargeff000000,
                                                    )

                                                  ],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text("About You",
                                              style: CustomTextStyles
                                                  .titleMediumff000000,
                                            ),
                                            const SizedBox(
                                              height: 0,
                                            ),
                                            SizedBox(
                                              height: 80,
                                              width: 291,
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.vertical, // Enable horizontal scrolling
                                                child: Text(
                                                  "${editProfileProvider.getProfileModel!.note}",
                                                  maxLines: 20,
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: CustomTextStyles
                                                      .bodyMediumGray700_1,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: size.height * 0.065,
                                            ),
                                            Consumer<DashBoardProvider>(builder: //Edit profile button
                                                (context, dashBoardProvider,
                                                    _) {
                                              return GestureDetector(
                                                onTap: () {
                                                  dashBoardProvider
                                                      .changeCommentPage(
                                                    index: 9,
                                                  );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: ColorsContent.primaryColor,
                                                    borderRadius: const BorderRadius.only(
                                                        topLeft: Radius.circular(12),
                                                      topRight: Radius.circular(12)
                                                    )
                                                  ),
                                                  child: const Padding(
                                                    padding: EdgeInsets.only(
                                                      left: 18,
                                                      right: 18,
                                                      top: 8,
                                                      bottom: 8
                                                    ),
                                                    child: Text(
                                                      "Edit Profile",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ],
                                        );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ):
    const TokenExpireScreen();
  }

  /// Section Widget
}
