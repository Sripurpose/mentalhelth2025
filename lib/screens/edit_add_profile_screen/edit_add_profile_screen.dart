import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/widgets/dropdown_widget.dart';
import 'package:mentalhelth/utils/theme/custom_button_style.dart';
import 'package:mentalhelth/widgets/background_image/background_imager.dart';
import 'package:mentalhelth/widgets/custom_elevated_button.dart';
import 'package:mentalhelth/widgets/custom_text_form_field.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:provider/provider.dart';

import '../../utils/theme/app_decoration.dart';
import '../../utils/theme/custom_text_style.dart';
import '../../utils/theme/theme_helper.dart';
import '../../widgets/app_bar/appbar_leading_image.dart';
import '../../widgets/custom_image_view.dart';
import '../home_screen/provider/home_provider.dart';
import '../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import '../token_expiry/tocken_expiry_warning_screen.dart';
import '../token_expiry/token_expiry.dart';
import 'model/get_category.dart';

class EditAddProfileScreen extends StatefulWidget {
  const EditAddProfileScreen({Key? key})
      : super(
    key: key,
  );

  @override
  State<EditAddProfileScreen> createState() =>
      _EditAddProfileScreenState();
}

class _EditAddProfileScreenState extends State<EditAddProfileScreen> {
  late HomeProvider homeProvider;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  late EditProfileProvider editProfileProvider;
  late DashBoardProvider dashBoardProvider;
  bool tokenStatus = false;
  var logger = Logger();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _isTokenExpired() async {
    await homeProvider.fetchChartView(context);
    await homeProvider.fetchJournals(initial: true);
    //await editProfileProvider.fetchUserProfile();
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
      _isTokenExpired();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return tokenStatus == false ?
      SafeArea(
      child: backGroundImager(
        size: size,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            buildAppBar(context, size),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Form(
                  key: _formKey,
                  child: Container(
                    width: double.maxFinite,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 25, vertical: 1),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: size.height * 0.1,
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.only(left: 1, bottom: 5),
                                  padding: const EdgeInsets.all(
                                    18,
                                  ),
                                  decoration: BoxDecoration(
                                    color: appTheme.gray200,
                                    borderRadius: BorderRadius.circular(
                                      30,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 40),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Text(
                                            "Name *",
                                            style: CustomTextStyles
                                                .bodyMediumGray700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      _buildMyProfile(context),
                                      const SizedBox(height: 11),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          child: Text(
                                            "Phone",
                                            style: CustomTextStyles
                                                .bodyMediumGray700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      _buildPhone(context),
                                      const SizedBox(height: 9),
                                      Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Text("Email *",
                                                  style: CustomTextStyles
                                                      .bodyMediumGray700))),
                                      const SizedBox(height: 2),
                                      _buildEmail(context),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Text(
                                            "Date Of Birth *",
                                            style: CustomTextStyles
                                                .bodyMediumGray700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Consumer<EditProfileProvider>(builder:
                                          (context, editProfileProvider, _) {
                                        return GestureDetector(
                                          onTap: () {
                                            editProfileProvider
                                                .selectDate(context);
                                          },
                                          child: Container(
                                            margin:
                                                const EdgeInsets.only(left: 10),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 10),
                                            decoration: AppDecoration
                                                .outlineGray700
                                                .copyWith(
                                              borderRadius: BorderRadiusStyle
                                                  .roundedBorder4,
                                              color: Colors.transparent,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Text(
                                                  editProfileProvider
                                                      .selectedDate,
                                                  style: CustomTextStyles
                                                      .bodyMediumOnPrimary,
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: 14),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Text(
                                            "Interests",
                                            style: CustomTextStyles.bodyMediumGray700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 1),

                                      Consumer<EditProfileProvider>(
                                        builder: (context, editProfileProvider, _) {
                                          // Ensure interests is a List<String>
                                          final String? interestsString = editProfileProvider.getProfileModel?.interests;
                                          editProfileProvider.profileInterests = interestsString != null
                                              ? interestsString.split(',').map((e) => e.trim()).toList() // Split and trim whitespace
                                              : [];
                                          final String? intrestIdString = editProfileProvider.getProfileModel?.interest_ids;
                                          editProfileProvider.profileInterestIds = intrestIdString != null
                                              ? intrestIdString.split(',').map((e) => e.trim()).toList() // Split and trim whitespace
                                              : [];
                                          final selectedCategories = editProfileProvider.selectedCategories;

                                          // Check if interests or selected categories are not empty.
                                          final isProfileInterestsNotEmpty = editProfileProvider.profileInterests.isNotEmpty;
                                          final areSelectedCategoriesNotEmpty = selectedCategories.isNotEmpty;
                                          logger.w("editProfileProvider.profileInterests-${editProfileProvider.profileInterests}");
                                          logger.w("selectedCategories-$selectedCategories");

                                          return Container(
                                            height: size.height * 0.05, // Adjust this height as needed
                                            margin: const EdgeInsets.only(left: 10),
                                            padding: const EdgeInsets.only(left: 2, right: 2),
                                            decoration: const ShapeDecoration(
                                              color: Colors.transparent,
                                              shape: RoundedRectangleBorder(),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () async {
                                                      // Open modal to select items
                                                      List<Category>? selectedCategories = await showModalBottomSheet(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return MultiSelectCategoryWidget(
                                                            categories: editProfileProvider.getCategoryModel?.category ?? [],
                                                            selectedCategories: editProfileProvider.selectedCategories,
                                                          );
                                                        },
                                                      );
                                                      // If categories are selected, update provider
                                                      if (selectedCategories != null) {
                                                        editProfileProvider.setSelectedCategories(selectedCategories);
                                                      }
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: SingleChildScrollView(
                                                            scrollDirection: Axis.horizontal,
                                                            child: Row(
                                                              children: areSelectedCategoriesNotEmpty
                                                                  ? selectedCategories.map((category) {
                                                                return Padding(
                                                                  padding: const EdgeInsets.only(right: 8.0), // Space between items
                                                                  child: Chip(
                                                                    label: Text(category.categoryName ?? ""),
                                                                    deleteIcon: const Icon(Icons.close),
                                                                    onDeleted: () {
                                                                      // Remove the item from the selected list
                                                                      editProfileProvider.removeSelectedCategory(category);
                                                                    },
                                                                  ),
                                                                );
                                                              }).toList()
                                                                  : isProfileInterestsNotEmpty
                                                                  ? editProfileProvider.profileInterests.map((interest) {
                                                                // Assuming you have a way to get the corresponding interest ID
                                                                final interestId = editProfileProvider.profileInterestIds[editProfileProvider.profileInterests.indexOf(interest)];
                                                                return Padding(
                                                                  padding: const EdgeInsets.only(right: 8.0), // Space between items
                                                                  child:
                                                                  Chip(
                                                                    label: Text(interest), // Use interest and its ID as the label
                                                                    deleteIcon: const Icon(Icons.close), // Add delete icon
                                                                    onDeleted: () {
                                                                      // Remove the interest from the profile interests list
                                                                      editProfileProvider.removeInterest(interest);
                                                                      editProfileProvider.removeInterestId(interestId);
                                                                      // No need to call removeInterestId() as it was removed
                                                                    },
                                                                  ),
                                                                );
                                                              }).toList()
                                                                  : [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      'Select Interests',
                                                                      style: CustomTextStyles.bodyMediumOnPrimary,
                                                                    ),
                                                                    const Gap(10),
                                                                    const Icon(Icons.arrow_drop_down),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),


                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),

                                    const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 9,
                                          ),
                                          child: Text(
                                            "About You",
                                            style: CustomTextStyles
                                                .bodyMediumGray700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      _buildAboutYouValue(context),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      _buildSave(
                                        context,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Consumer<EditProfileProvider>(
                            builder: (context, editProfileProvider, _) {
                          return Positioned(
                            top: size.height * 0.045,
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              elevation: 0,
                              margin: const EdgeInsets.all(
                                0,
                              ),
                              color: theme.colorScheme.primary.withOpacity(
                                1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusStyle.circleBorder54,
                              ),
                              child: Container(
                                height: size.height * 0.12,
                                width: size.height * 0.12,
                                decoration: AppDecoration.fillPrimary.copyWith(
                                  borderRadius:
                                      BorderRadiusStyle.circleBorder54,
                                ),
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        editProfileProvider.getImageFromGallery(
                                            context: context);
                                      },
                                      child: editProfileProvider.images != null
                                          ? Image.file(
                                              editProfileProvider.images!,
                                              height: 200,
                                              width: 200,
                                              fit: BoxFit.cover,
                                            )
                                          : CustomImageView(
                                              imagePath: editProfileProvider
                                                  .profileUrl
                                                  .toString(),
                                              height: size.height * 0.13,
                                              width: size.height * 0.13,
                                              radius: BorderRadius.circular(54),
                                              alignment: Alignment.center,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          bottom: size.height * 0.01,
                                        ),
                                        child: Text(
                                          "Change Photo",
                                          style: CustomTextStyles
                                              .blackTextStyleCustomWhiteW800(
                                            size: size.width * 0.03,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        })
                      ],
                    ),
                  ),
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
  Widget _buildMyProfile(BuildContext context) {
    return Consumer<EditProfileProvider>(
      builder: (context, editProfileProvider, _) {
        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 1),
          child: CustomTextFormField(
            controller: editProfileProvider.myProfileController,
            hintText: "",
            hintStyle: const TextStyle(
              color: Colors.black,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-Z0-9,. ]'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Section Widget
  Widget _buildPhone(BuildContext context) {
    return Consumer<EditProfileProvider>(
      builder: (context, editProfileProvider, _) {
        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 1),
          child: CustomTextFormField(
            isValids: editProfileProvider.phoneIsValid,
            textInputType: TextInputType.phone,
            controller: editProfileProvider.phoneController,
            hintText: "0000000000", // Phone number hint
            hintStyle: const TextStyle(
              color: Colors.black,
            ),
            readOnly: editProfileProvider.getProfileModel?.phoneVerify == "1", // Make field read-only if phone is verified
            prefixText: "+${editProfileProvider.getProfileModel?.countryCode ?? "+00"} ", // Add country code as prefix text
            prefixStyle: const TextStyle(
             // fontSize: 10,
              color: Colors.black,
            ),
            onChanged: (value) {
              editProfileProvider.phoneValidate(
                editProfileProvider.validatePhoneNumber(value),
              );
            },
          ),
        );
      },
    );
  }






  Widget _buildEmail(BuildContext context) {
    return Consumer<EditProfileProvider>(
      builder: (context, editProfileProvider, _) {
        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 1),
          child: Form(
            child: CustomTextFormField(
              hintStyle: const TextStyle(
                color: Colors.black,
              ),
              controller: editProfileProvider.emailController,
              hintText: "Enter your email",
              textInputType: TextInputType.emailAddress,
              readOnly: editProfileProvider.getProfileModel?.emailVerify == "1", // Set readOnly based on the condition
              validator: (value) {
                // Email validation logic
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                // Regular expression for validating email
                const String emailPattern =
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                final RegExp regex = RegExp(emailPattern);
                if (!regex.hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null; // Return null if the input is valid
              },
            ),
          ),
        );
      },
    );
  }

  /// Section Widget
  // Widget _buildInterestsValue(BuildContext context) {
  //   return Consumer<EditProfileProvider>(
  //     builder: (context, editProfileProvider, _) {
  //       return Padding(
  //         padding: const EdgeInsets.only(left: 10),
  //         child: CustomTextFormField(
  //           hintStyle: const TextStyle(
  //             color: Colors.black,
  //           ),
  //           controller: editProfileProvider.interestsValueController,
  //           hintText: "Music, Badminton",
  //         ),
  //       );
  //     },
  //   );
  // }

  /// Section Widget
  Widget _buildAboutYouValue(BuildContext context) {
    return Consumer<EditProfileProvider>(
        builder: (context, editProfileProvider, _) {
      return Padding(
          padding: const EdgeInsets.only(left: 9, right: 1),
          child: CustomTextFormField(
              controller: editProfileProvider.aboutYouValueController,
              hintText:
                  "",
              hintStyle: CustomTextStyles.bodyMediumGray70013,
              textInputAction: TextInputAction.done,
              maxLines: 4,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r"[a-zA-Z0-9,. ]"), // Allow only letters, numbers, space, comma, and period
              ),
            ],));
    });
  }

  /// Section Widget
  Widget _buildSave(BuildContext context) {
    return Consumer2<EditProfileProvider, DashBoardProvider>(
      builder: (contexts, editProfileProvider, dashBoardProvider, _) {
        return CustomElevatedButton(
          loading: editProfileProvider.editLoading,
          buttonStyle: CustomButtonStyles.outlinePrimary,
          width: 104,
          text: "Save",
          onPressed: () async {
            // Get the email entered by the user
            String email = editProfileProvider.emailController.text;

            // Regular expression for standard email validation
            String emailPattern =
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
            RegExp regex = RegExp(emailPattern);

            // Check if required fields are filled and if the email is valid
            if (editProfileProvider.myProfileController.text.isEmpty) {
              showToast(context: context, message: 'Please enter your name');
            } else if (!editProfileProvider.phoneIsValid) {
              showToast(context: context, message: 'Invalid phone number');
            } else if (editProfileProvider.selectedDate.isEmpty) {
              showToast(context: context, message: 'Select your date of birth');
            } else if (editProfileProvider.phoneController.text.isEmpty) {
              showToast(context: context, message: 'Enter your phone number');
            } else if (editProfileProvider.emailController.text.isEmpty) {
              showToast(context: context, message: 'Enter your email');
            } else if (editProfileProvider.aboutYouValueController.text.isEmpty) {
              showToast(context: context, message: 'Enter information about yourself');
            }
            // Custom email format validation using regex
            else if (!regex.hasMatch(email)) {
              showToast(
                  context: context,
                  message: 'Please enter a valid email address (e.g.,user@example.com)');
            }
            else {
              // If all validations pass, proceed with saving the profile
              await editProfileProvider.editProfileFunction(
                firstName: editProfileProvider.myProfileController.text,
                note: editProfileProvider.aboutYouValueController.text,
                profileimg: editProfileProvider.profileUrl.toString(),
                dob: editProfileProvider.date.toString(),
                phone: editProfileProvider.phoneController.text,
                email: email,  // Pass the validated email
                context: context,
                interestIds: editProfileProvider.selectedCategories.isEmpty
                    ? editProfileProvider.profileInterestIds  // Default if no categories are selected
                    : editProfileProvider.selectedCategories
                    .map((category) => category.id.toString())  // Convert categories to a list of IDs
                    .toList(),
              );
              // Navigate to the comment page
              dashBoardProvider.changeCommentPage(
                index: 8,
              );
            }
          },
        );
      },
    );
  }

}
