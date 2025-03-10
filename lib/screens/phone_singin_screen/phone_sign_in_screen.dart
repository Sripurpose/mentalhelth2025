import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mentalhelth/screens/phone_singin_screen/provider/phone_sign_in_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:mentalhelth/widgets/custom_elevated_button.dart';
import 'package:mentalhelth/widgets/custom_text_form_field.dart';
import 'package:provider/provider.dart';

import '../../utils/theme/custom_button_style.dart';
import '../../utils/theme/custom_text_style.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/functions/snack_bar.dart';

// ignore_for_file: must_be_immutable
class PhoneSignInScreen extends StatelessWidget {
  PhoneSignInScreen({Key? key}) : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            // IconButton(
            //   icon: Icon(
            //     Icons.arrow_back_ios,
            //     color: theme.colorScheme.primary, // You can set the color based on your theme
            //   ),
            //   onPressed: () {
            //     Navigator.pop(context);
            //   },
            // ),
          ],
        ),
        body: Container(
          // width: size.width,
          // height: size.height,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSecondaryContainer.withOpacity(
              1,
            ),
            image: DecorationImage(
              image: AssetImage(
                ImageConstant.imgGroup22,
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Form(
              key: _formKey,
              child: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.symmetric(
                  horizontal: 47,
                  vertical: 175,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 33,
                    ),
                    CustomImageView(
                      imagePath: ImageConstant.imgLogo,
                      height: 68,
                      width: 280,
                    ),
                    const SizedBox(
                      height: 39,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 3,
                        right: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Consumer<PhoneSignInProvider>(
                              builder: (context, phoneSignInProvider, _) {
                            return SizedBox(
                              height: 40,
                              // width: size.width * 0.2,
                              child: OutlinedButton(
                                style: CustomButtonStyles.outlineGrayTL5,
                                onPressed: () {
                                  showCountryPicker(
                                    context: context,
                                    exclude: <String>['KN', 'MF'],
                                    favorite: <String>['SE'],
                                    showPhoneCode: true,
                                    onSelect: (Country country) {
                                      phoneSignInProvider.addCountryCode(
                                        value: country.phoneCode.toString(),
                                      );
                                      print("Country code is ${phoneSignInProvider.countryCode}");
                                    },
                                    countryListTheme: CountryListThemeData(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(40.0),
                                        topRight: Radius.circular(40.0),
                                      ),
                                      inputDecoration: InputDecoration(
                                        labelText: 'Search',
                                        hintText: 'Start typing to search',
                                        prefixIcon: const Icon(Icons.search),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: const Color(0xFF8C98A8)
                                                .withOpacity(0.2),
                                          ),
                                        ),
                                      ),
                                      // Optional. Styles the text in the search field
                                      searchTextStyle: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 18,
                                      ),
                                    ),
                                  );
                                },
                                child: Center(
                                  child: Text(
                                    "+${phoneSignInProvider.countryCode.toString()}",
                                    style: CustomTextStyles
                                        .titleSmallHelveticaOnPrimary,
                                  ),
                                ),
                              ),
                            );
                          }),
                          Consumer<PhoneSignInProvider>(
                              builder: (context, phoneSignInProvider, _) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                ),
                                child: CustomTextFormField(

                                  controller: phoneSignInProvider.phoneNumberController,
                                  hintText: "Phone number",
                                  hintStyle: theme.textTheme.bodySmall,
                                  textInputAction: TextInputAction.done,
                                  textInputType: TextInputType.numberWithOptions(signed: true, decimal: true),
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
                                ),

                              ),
                            );
                          })
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: 290,
                      margin: const EdgeInsets.only(
                        right: 7,
                      ),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text:
                                "Your phone number will be used to improve your experience within Mental health app, as well as validate your account. If you sign up with SMS, SMS fees may apply",
                            style: CustomTextStyles.bodySmallNunitoff333333,
                          ),
                          TextSpan(
                            text: "\r\n",
                            style: CustomTextStyles.bodySmallNunitoff59a9f2,
                          ),
                          TextSpan(
                            text: "Learn more",
                            style: CustomTextStyles.labelLargeNunitoff59a9f2,
                          )
                        ]),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Consumer<PhoneSignInProvider>(
                        builder: (context, phoneSignInProvider, _) {
                      return CustomElevatedButton(
                        loading: phoneSignInProvider.loginLoading,
                        height: 40,
                        text: "Send Code",
                        margin: const EdgeInsets.only(
                          right: 10,
                        ),
                        buttonStyle: CustomButtonStyles.outlinePrimary,
                        buttonTextStyle: CustomTextStyles
                            .titleSmallHelveticaOnSecondaryContainer,
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          if (phoneSignInProvider
                              .phoneNumberController.text.isNotEmpty) {
                            await phoneSignInProvider.phoneLoginUser(
                              context,
                              phone: phoneSignInProvider
                                  .phoneNumberController.text,
                            );
                          } else {
                            showCustomSnackBar(
                                context: context, message: 'Enter your number');
                          }
                        },
                        alignment: Alignment.centerLeft,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
