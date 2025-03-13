import 'dart:async';

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

class PhoneSignInScreen extends StatefulWidget {
  const PhoneSignInScreen({Key? key}) : super(key: key);

  @override
  _PhoneSignInScreenState createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends State<PhoneSignInScreen> {
  late PhoneSignInProvider phoneSignInProvider;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    phoneSignInProvider = Provider.of<PhoneSignInProvider>(context, listen: false);

    scheduleMicrotask(() {
      phoneSignInProvider.phoneNumberController.text = "";
      phoneSignInProvider.countryCode = "";
    });
  }

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
        ),
        body: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
            image: DecorationImage(
              image: AssetImage(ImageConstant.imgGroup22),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Form(
              key: _formKey,
              child: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.symmetric(horizontal: 47, vertical: 175),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 33),
                    CustomImageView(
                      imagePath: ImageConstant.imgLogo,
                      height: 68,
                      width: 280,
                    ),
                    const SizedBox(height: 39),
                    Padding(
                      padding: const EdgeInsets.only(left: 3, right: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Consumer<PhoneSignInProvider>(
                            builder: (context, phoneSignInProvider, _) {
                              return SizedBox(
                                height: 40,
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
                                      },
                                    );
                                  },
                                  child: Center(
                                    child: Text(
                                      "+${phoneSignInProvider.countryCode.toString()}",
                                      style: CustomTextStyles.titleSmallHelveticaOnPrimary,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Consumer<PhoneSignInProvider>(
                            builder: (context, phoneSignInProvider, _) {
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: CustomTextFormField(
                                    controller: phoneSignInProvider.phoneNumberController,
                                    hintText: "Phone number",
                                    hintStyle: theme.textTheme.bodySmall,
                                    textInputAction: TextInputAction.done,
                                    textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a phone number';
                                      } else if (value.length != 10) {
                                        return 'Phone number must be 10 digits';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: 290,
                      margin: const EdgeInsets.only(right: 7),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Your phone number will be used to improve your experience within Mental health app, as well as validate your account. If you sign up with SMS, SMS fees may apply",
                              style: CustomTextStyles.bodySmallNunitoff333333,
                            ),
                            TextSpan(
                              text: "\r\n",
                              style: CustomTextStyles.bodySmallNunitoff59a9f2,
                            ),
                            TextSpan(
                              text: "Learn more",
                              style: CustomTextStyles.labelLargeNunitoff59a9f2,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Consumer<PhoneSignInProvider>(
                      builder: (context, phoneSignInProvider, _) {
                        return CustomElevatedButton(
                          loading: phoneSignInProvider.loginLoading,
                          height: 40,
                          text: "Send Code",
                          margin: const EdgeInsets.only(right: 10),
                          buttonStyle: CustomButtonStyles.outlinePrimary,
                          buttonTextStyle: CustomTextStyles.titleSmallHelveticaOnSecondaryContainer,
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            if (phoneSignInProvider.phoneNumberController.text.isNotEmpty) {
                              await phoneSignInProvider.phoneLoginUser(
                                context,
                                phone: phoneSignInProvider.phoneNumberController.text,
                              );
                            } else {
                              showCustomSnackBar(
                                context: context, message: 'Enter your number',
                              );
                            }
                          },
                          alignment: Alignment.centerLeft,
                        );
                      },
                    ),
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
