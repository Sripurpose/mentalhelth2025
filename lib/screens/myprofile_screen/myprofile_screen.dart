import 'dart:io';

import 'package:flutter/cupertino.dart';
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
import '../../widgets/showChangePasswordDialog.dart';
import '../home_screen/provider/home_provider.dart';
import '../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import '../no_internet/duplicate_screen.dart';
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
    //await homeProvider.fetchChartView(context);
    await homeProvider.fetchJournals(initial: true,context: context);
    // await editProfileProvider.fetchUserProfile();
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
       editProfileProvider.fetchUserProfile(context);
      editProfileProvider.getProfileModel?.profileurl = "";
      logger.i("editProfileProvider.getProfileModel?.profileurl.toString()${editProfileProvider.getProfileModel?.profileurl.toString()}");
      _isTokenExpired();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return tokenStatus == false
        ? SafeArea(
      child: backGroundImager(
        size: size,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            buildAppBar(context, size),
            Container(
              height: size.height * 0.80,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: size.height * 0.035),
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: size.height * 0.60,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Consumer2<EditProfileProvider, PhoneSignInProvider>(
                                      builder: (context, editProfileProvider, phoneSignInProvider, _) {
                                        return editProfileProvider.getProfileLoading
                                            ? Center(child: CupertinoActivityIndicator(
                                          color: ColorsContent.newThemeColor,
                                          radius: 15,
                                        ))
                                            : editProfileProvider.getProfileModel == null
                                            ? Center(child: CupertinoActivityIndicator(
                                          color: ColorsContent.newThemeColor,
                                          radius: 15,
                                        ))
                                            : SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              SizedBox(height: size.height * 0.1),
                                              SizedBox(
                                                width: size.width * 0.55,
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: SingleChildScrollView(
                                                    scrollDirection: Axis.horizontal,
                                                    child: Text(
                                                      capitalText(
                                                        editProfileProvider.getProfileModel?.firstname.toString() ?? "",
                                                      ),
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.w700,
                                                        fontFamily: 'Open Sans',
                                                        color: Colors.black,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: size.height * 0.002),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 53),
                                                  child: Text(
                                                    "Member since ${editProfileProvider.getProfileModel?.createdAt == null ? "" : formatTimestampToDate(editProfileProvider.getProfileModel!.createdAt.toString())}",
                                                    style: CustomTextStyles.bodyMediumGray700,
                                                //    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 27),
                                              Container(
                                                width: 238,
                                                margin: const EdgeInsets.symmetric(horizontal: 25),
                                                child: RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      editProfileProvider.getProfileModel!.phone!.isNotEmpty
                                                          ? TextSpan(
                                                        text:
                                                        "${(editProfileProvider.getProfileModel?.countryCode?.isNotEmpty ?? false) ? "+${editProfileProvider.getProfileModel!.countryCode} " : ""}${editProfileProvider.getProfileModel!.phone}\n",
                                                        style: CustomTextStyles.bodyLargeff000000,
                                                      )
                                                          : const TextSpan(text: ""),
                                                      editProfileProvider.getProfileModel!.phone == null ||
                                                          editProfileProvider.getProfileModel!.phone == ""
                                                          ? const TextSpan(text: "\n")
                                                          : editProfileProvider.getProfileModel!.phoneVerify == "1"
                                                          ? const TextSpan(text: "\n")
                                                          : TextSpan(
                                                        text: "Verify Phone\n\n",
                                                        style: CustomTextStyles.labelLargeff59a9f2.copyWith(
                                                          decoration: TextDecoration.underline,
                                                        ),
                                                        recognizer: TapGestureRecognizer()
                                                          ..onTap = () async {
                                                            await editProfileProvider.sendOtpPhoneFunction(context);
                                                            if (editProfileProvider.sendOtpPhoneStatus == 200) {
                                                              Future.delayed(Duration.zero, () {
                                                                Navigator.of(context).push(MaterialPageRoute(
                                                                  builder: (context) => const VerifyOtpPhoneScreen(),
                                                                ));
                                                              });
                                                            } else {
                                                              showToast(
                                                                context: context,
                                                                message: editProfileProvider.sendOtpPhoneMessage ?? "",
                                                              );
                                                            }
                                                          },
                                                      ),
                                                      editProfileProvider.getProfileModel!.emailVerify != "1" &&
                                                          editProfileProvider.getProfileModel!.email!.isNotEmpty ?
                                                      TextSpan(
                                                        text: "${editProfileProvider.getProfileModel!.email}\n",
                                                        style: CustomTextStyles.bodyLargeff000000,
                                                      ):
                                                      TextSpan(
                                                        text: "${editProfileProvider.getProfileModel!.email}\n\n",
                                                        style: CustomTextStyles.bodyLargeff000000,
                                                      ),
                                                      if (editProfileProvider.getProfileModel!.emailVerify != "1" &&
                                                          editProfileProvider.getProfileModel!.email!.isNotEmpty)
                                                        TextSpan(
                                                          text: "Verify Email\n\n",
                                                          style: CustomTextStyles.labelLargeff59a9f2.copyWith(
                                                            decoration: TextDecoration.underline,
                                                          ),
                                                          recognizer: TapGestureRecognizer()
                                                            ..onTap = () async {
                                                              await editProfileProvider.sendOtpFunction(context);
                                                              if (editProfileProvider.sendOtpStatus == 200) {
                                                                Future.delayed(Duration.zero, () {
                                                                  Navigator.of(context).push(MaterialPageRoute(
                                                                    builder: (context) => const VerifyOtpScreen(),
                                                                  ));
                                                                });
                                                              } else {
                                                                showToast(
                                                                  context: context,
                                                                  message: editProfileProvider.sendOtpMailMessage ?? "",
                                                                );
                                                              }
                                                            },
                                                        ),

                                                      TextSpan(
                                                        text: "Date Of Birth\n",
                                                        style: CustomTextStyles.titleMediumff000000,
                                                      ),
                                                      TextSpan(
                                                        text:
                                                        "${editProfileProvider.getProfileModel!.dob == null ? "" : dateFormatter(date: editProfileProvider.getProfileModel!.dob.toString())}\n\n",
                                                        style: CustomTextStyles.bodyLargeff000000,
                                                      ),
                                                      TextSpan(
                                                        text: "Interests\n",
                                                        style: CustomTextStyles.titleMediumff000000,
                                                      ),
                                                      TextSpan(
                                                        text: editProfileProvider.getProfileModel!.interests
                                                            ?.split(',')
                                                            .map((e) => e.trim())
                                                            .toSet()
                                                            .join(', '),
                                                        style: CustomTextStyles.bodyLargeff000000,
                                                      )
                                                    ],
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              SizedBox(
                                                height: 80,
                                                width: 291,
                                                child: SingleChildScrollView(
                                                  scrollDirection: Axis.vertical,
                                                  child: Text(
                                                    "${editProfileProvider.getProfileModel!.note}",
                                                    maxLines: 20,
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style: CustomTextStyles.bodyMediumGray700_1,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: Platform.isAndroid ? size.height * 0.03 : size.height * 0.01),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                    child: Row(
                                      mainAxisAlignment: (editProfileProvider.getProfileModel?.isPassword == 1)
                                          ? MainAxisAlignment.spaceBetween
                                          : MainAxisAlignment.center,
                                      children: [
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Consumer<DashBoardProvider>(
                                            builder: (context, dashBoardProvider, _) {
                                              return GestureDetector(
                                                onTap: () {
                                                  dashBoardProvider.changeCommentPage(index: 9);
                                                },
                                                child: Container(
                                                  width: size.width * 0.30,
                                                  height: size.height * 0.040,
                                                  decoration: BoxDecoration(
                                                    color: ColorsContent.newThemeColor,
                                                    borderRadius: const BorderRadius.only(
                                                      topLeft: Radius.circular(12),
                                                      topRight: Radius.circular(12),
                                                    ),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "Edit Profile",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        if (editProfileProvider.getProfileModel?.isPassword == 1)
                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Consumer<DashBoardProvider>(
                                              builder: (context, dashBoardProvider, _) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    showChangePasswordDialog(context, editProfileProvider);
                                                  },
                                                  child: Container(
                                                    width: size.width * 0.35,
                                                    height: size.height * 0.040,
                                                    decoration: BoxDecoration(
                                                      color: ColorsContent.blackText,
                                                      borderRadius: const BorderRadius.only(
                                                        topLeft: Radius.circular(12),
                                                        topRight: Radius.circular(12),
                                                      ),
                                                    ),
                                                    child: const Center(
                                                      child: Text(
                                                        "Change Password",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),
                        ),
                        Consumer<EditProfileProvider>(
                          builder: (context, editProfileProvider, _) {
                            return Container(
                              height: size.height * 0.11,
                              width: size.height * 0.11,
                              decoration: AppDecoration.fillBlueGray.copyWith(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadiusStyle.circleBorder54,
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage: NetworkImage(
                                  editProfileProvider.getProfileModel?.profileurl?.toString() ?? "",
                                ),
                                radius: size.width * 0.1,
                              ),
                            );
                          },
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
    )
        : const TokenExpireScreen();
  }


  /// Section Widget
}
