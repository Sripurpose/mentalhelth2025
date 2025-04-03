
import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/privacy_screen/provider/privacy_policy_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../widgets/app_bar/appbar_leading_image.dart';
import '../no_internet/duplicate_screen.dart';

class TermsServiceScreen extends StatefulWidget {
  const TermsServiceScreen({Key? key})
      : super(
          key: key,
        );

  @override
  State<TermsServiceScreen> createState() => _TermsServiceScreenState();
}

class _TermsServiceScreenState extends State<TermsServiceScreen> {
  @override
  void initState() {
    PrivacyPolicyProvider privacyPolicyProvider =
        Provider.of<PrivacyPolicyProvider>(context, listen: false);
    privacyPolicyProvider.fetchPolicy(
      type: "terms",
    );
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
            child: Column(
              children: [
                buildAppBar(
                  context,
                  size,
                  heading: "Terms Of Service",
                  onTap: () {
                    Navigator.of(context).pop(); // Navigate back
                  },
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
                        height: size.height * 0.7,
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
                                      ..setBackgroundColor(
                                        Colors.transparent,
                                      )
                                      ..loadHtmlString(
                                        policyProvider.policyModel!.description
                                            .toString(),
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
