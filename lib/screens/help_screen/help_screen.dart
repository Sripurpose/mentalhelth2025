import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/core/image_constant.dart';
import '../../utils/theme/theme_helper.dart';
import '../../widgets/app_bar/appbar_leading_image.dart';

class HelpScreen extends StatefulWidget {
  final String url;

  const HelpScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
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
      );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
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
                  heading: "Help",
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
    );
  }
}
