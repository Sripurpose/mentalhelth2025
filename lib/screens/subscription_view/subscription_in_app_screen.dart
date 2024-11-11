import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/core/image_constant.dart';
import '../../utils/logic/shared_prefrence.dart';
import '../../utils/theme/theme_helper.dart';
import '../../widgets/app_bar/appbar_leading_image.dart';
import '../auth/sign_in/provider/sign_in_provider.dart';

class SubscriptionInAppScreen extends StatefulWidget {
  final String url;

  const SubscriptionInAppScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<SubscriptionInAppScreen> createState() => _SubscriptionInAppScreenState();
}

class _SubscriptionInAppScreenState extends State<SubscriptionInAppScreen> {
  late SignInProvider signInProvider;
  late WebViewController _controller;

  @override
  void initState() {
    signInProvider = Provider.of<SignInProvider>(context, listen: false);
    super.initState();
    _controller = WebViewController()
      ..clearCache() // Clears the cache
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            // Inject CSS to justify text and add padding
            await _controller.runJavaScript('''
              document.body.style.textAlign = "justify";
              document.body.style.padding = "0 60px"; // Adjust the padding as needed
            ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.url), // Loading the Terms of Service URL
        headers: {
          "Cache-Control": "no-cache, no-store, must-revalidate",
          "Pragma": "no-cache",
          "Expires": "0",
        },
      );
  }

  Future<void> _performApiCallOnBackPress() async {
    await signInProvider.fetchSettings(context);
    // TODO: Implement your API call logic here
    // You can use http package or any other method to perform an API call
    // Example:
    // final response = await http.post('https://api.example.com/your-endpoint');
    // if (response.statusCode == 200) { ... }
    print("API call performed on back press");
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        // Perform your API call when the back button is pressed
        await _performApiCallOnBackPress();
        // Return true to allow back navigation
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
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
                    heading: "Subscription",
                  ),
                  // Use Expanded to allow WebView to take remaining space in the Column
                  Expanded(
                    child: WebViewWidget(
                      controller: _controller,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
