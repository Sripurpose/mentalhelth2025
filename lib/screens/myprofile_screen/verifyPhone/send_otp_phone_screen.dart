import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mentalhelth/screens/myprofile_screen/verifyPhone/verifyOtpScreenPhone.dart';
import 'package:mentalhelth/screens/phone_singin_screen/provider/phone_sign_in_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:mentalhelth/widgets/custom_elevated_button.dart';
import 'package:mentalhelth/widgets/custom_text_form_field.dart';
import 'package:provider/provider.dart';

import '../../../utils/theme/custom_button_style.dart';
import '../../../utils/theme/custom_text_style.dart';
import '../../../widgets/custom_image_view.dart';
import '../../../widgets/functions/snack_bar.dart';
import '../../edit_add_profile_screen/provider/edit_provider.dart';

// ignore_for_file: must_be_immutable
class SendOtpPhoneScreen extends StatefulWidget {
  SendOtpPhoneScreen({Key? key}) : super(key: key);

  @override
  _SendOtpPhoneScreenState createState() => _SendOtpPhoneScreenState();
}

class _SendOtpPhoneScreenState extends State<SendOtpPhoneScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 47,
                  vertical: 175,
                ),
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
                          Consumer<EditProfileProvider>(
                              builder: (context, editProfileProvider, _) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: CustomTextFormField(
                                      controller: editProfileProvider
                                          .sendOtpPhoneController,
                                      hintText: "Phone number",
                                      hintStyle: theme.textTheme.bodySmall,
                                      textInputAction: TextInputAction.done,
                                      textInputType: TextInputType.phone,
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
                              })
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Consumer<EditProfileProvider>(
                        builder: (context, editProfileProvider, _) {
                          return CustomElevatedButton(
                            loading: editProfileProvider.sendOtpPhoneLoading,
                            height: 40,
                            text: "Verify",
                            margin: const EdgeInsets.only(right: 10),
                            buttonStyle: CustomButtonStyles.outlinePrimary,
                            buttonTextStyle: CustomTextStyles
                                .titleSmallHelveticaOnSecondaryContainer,
                            onPressed: () async {
                              if(editProfileProvider.sendOtpPhoneController.text.isNotEmpty){
                                FocusScope.of(context).unfocus();
                                await editProfileProvider.sendOtpPhoneFunction(context);
                                if(editProfileProvider.sendOtpPhoneStatus == 200){

                                  Navigator.of(context)
                                      .push(
                                    MaterialPageRoute(
                                      builder: (context) => const VerifyOtpPhoneScreen(),
                                    ),
                                  );

                                  //Navigator.of(context).pop();

                                }else{
                                  showToast(
                                    context: context,
                                    message: editProfileProvider.sendOtpPhoneMessage ?? "",
                                  );
                                }
                              }else{
                                showToast(
                                  context: context,
                                  message: "Please enter your phone number",
                                );
                              }
                            },
                            alignment: Alignment.centerLeft,
                          );
                        }),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        "A 6 digit code has been sent to your phone!",
                        style: CustomTextStyles.bodyMedium12,
                      ),
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

