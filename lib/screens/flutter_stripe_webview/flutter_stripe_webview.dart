import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/auth/sign_in/provider/sign_in_provider.dart';
import 'package:mentalhelth/screens/auth/subscription_success_screen/subscription_success_screen.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/utils/logic/shared_prefrence.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StripeWebView extends StatefulWidget {
  final String url;
  final bool phone;

  const StripeWebView({Key? key, required this.url, this.phone = false})
      : super(key: key);

  @override
  State<StripeWebView> createState() => _StripeWebViewState();
}

class _StripeWebViewState extends State<StripeWebView> {
  final WebViewController _controller = WebViewController();
  bool isZoomed = false;

  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<void> getLoginsDetails({required BuildContext context}) async {
    String? email = await getUserEmailSharePref();
    String? password = await getUserPasswordSharePref();
    SignInProvider signInProvider =
        Provider.of<SignInProvider>(context, listen: false);

    if (widget.phone) {
      await removeUserDetailsSharePref(context: context);
      showCustomSnackBar(
        context: context,
        message: "Success fully created please login now",
      );
    } else {
      await signInProvider.loginUser(
        context,
        email: email.toString(),
        password: password.toString(),
      );
    }
  }

  @override
  void initState() {
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            // setState(() {
            //   Navigator.of(context).pop();
            // });
            if (isZoomed) {
              _controller.runJavaScript("document.body.style.zoom = '2.0';");
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('action=success')) {
              isZoomed = true;
              _controller.runJavaScript("document.body.style.zoom = '2.0';");
              HomeProvider homeProvider =
                  Provider.of<HomeProvider>(context, listen: false);
              EditProfileProvider editProfileProvider =
                  Provider.of<EditProfileProvider>(context, listen: false);
              Future.delayed(const Duration(seconds: 10), () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubscriptionSuccessScreen(),
                  ),
                );

                await getLoginsDetails(context: context);
              //  homeProvider.fetchChartView(context);
              //  homeProvider.fetchJournals(initial: true);
                editProfileProvider.fetchUserProfile();
              });
            }
            return NavigationDecision.navigate;
          },

          // onNavigationRequest: (request) {
          //   log(request.url.toString(), name: "requesturl");
          //   // if (request.url != widget.url) {
          //   //   Navigator.of(context).pop();
          //   // }
          //   return NavigationDecision.navigate;
          // },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.url),
      );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              WebViewWidget(
                controller: _controller,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
