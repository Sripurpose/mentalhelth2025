import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/dash_borad_screen/dash_board_screen.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../widgets/app_bar/appbar_leading_image.dart';

class InAppBrowserPaymentScreen extends StatefulWidget {
  final Uri initialUrl;
  const InAppBrowserPaymentScreen({Key? key, required this.initialUrl}) : super(key: key);

  @override
  State<InAppBrowserPaymentScreen> createState() => _InAppBrowserPaymentScreenState();
}

class _InAppBrowserPaymentScreenState extends State<InAppBrowserPaymentScreen> {
  late final WebViewController _controller;
  String? _currentUrl;
  Timer? _redirectTimer;
  bool _showLoadingOverlay = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _currentUrl = url;
              _progress = 0.0;
            });
            _redirectTimer?.cancel();
            debugPrint("Page started: $url");
          },
          onProgress: (progress) {
            setState(() {
              _progress = progress / 100.0;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _currentUrl = url;
              _progress = 1.0;
            });
            debugPrint("Page finished: $url");

            if (url.endsWith("/success")) {
              debugPrint("Matched success URL: $url");

              // Show loading overlay after 5 seconds
              Timer(const Duration(seconds: 5), () {
                if (mounted) {
                  setState(() {
                    _showLoadingOverlay = true;
                  });
                }
              });

              // Redirect after 10 seconds
              _redirectTimer = Timer(const Duration(seconds: 10), () {
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const DashBoardScreen()),
                        (route) => false,
                  );
                }
              });
            } else {
              _redirectTimer?.cancel();
              setState(() {
                _showLoadingOverlay = false;
              });
            }
          },
          onNavigationRequest: (request) => NavigationDecision.navigate,
        ),
      )
      ..loadRequest(widget.initialUrl);
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // disable system back
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBarWebScreen(
          context,
          MediaQuery.of(context).size,
          heading: "Numu Subscription",
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const DashBoardScreen()),
                  (route) => false,
            );
          },
        ),
        body: Stack(
          children: [
            Column(
              children: [
                if (_progress < 1.0)
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ColorsContent.newThemeColor,
                    ),
                  ),
                // WebView takes full remaining space and handles its own scroll
                Expanded(
                  child: WebViewWidget(controller: _controller),
                ),
              ],
            ),
            if (_showLoadingOverlay)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CupertinoActivityIndicator(
                    color: Colors.white,
                    radius: 15,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
