import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/privacy_screen/provider/privacy_policy_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../widgets/app_bar/appbar_leading_image.dart';
import '../no_internet/duplicate_screen.dart';

class TermsOfServicesScreen extends StatefulWidget {
  const TermsOfServicesScreen({Key? key})
      : super(
    key: key,
  );

  @override
  State<TermsOfServicesScreen> createState() => _TermsOfServicesScreenState();
}

class _TermsOfServicesScreenState extends State<TermsOfServicesScreen> {
  @override
  void initState() {
    PrivacyPolicyProvider privacyPolicyProvider =
    Provider.of<PrivacyPolicyProvider>(context, listen: false);
    privacyPolicyProvider.fetchPolicy(type: "terms");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ConnectivityWidget(
      child: SafeArea(
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color:ColorsContent.homeBackGroundColor,
            image: DecorationImage(
              image: AssetImage(
                ImageConstant.imgGroup193,
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              children: [
                buildAppBar(
                  context,
                  size,
                  heading: "Terms of Service",
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 27,
                    top: 20,
                    right: 27,
                  ),
                  child: Consumer<PrivacyPolicyProvider>(
                    builder: (context, policyProvider, _) {
                      return SizedBox(
                        height: size.height * 0.75,
                        child: policyProvider.policyModel == null
                            ? const Center(
                          child: Text("No Data"),
                        )
                            : policyProvider.policyModelLoading
                            ? const Center(
                          child: CircularProgressIndicator(),
                        )
                            : WebViewWidget(
                          controller: WebViewController()
                            ..setJavaScriptMode(
                                JavaScriptMode.unrestricted)
                            ..setBackgroundColor(Colors.transparent)
                            ..loadHtmlString(
                              '''
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body {
              background-color: ${ColorsContent.homeBackGroundColor};
              text-align: justify; /* Aligns text to justify */
              padding: 0px;
            }
          </style>
        </head>
        <body>
          ${policyProvider.policyModel!.description.toString()}
        </body>
        </html>
        ''',
                            ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
