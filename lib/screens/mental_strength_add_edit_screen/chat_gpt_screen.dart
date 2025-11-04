import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/auth/sign_in/screen_sign_in.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../widgets/app_bar/appbar_leading_image.dart';

class ChatGptScreen extends StatefulWidget {
  final Uri initialUrl;
  const ChatGptScreen({Key? key, required this.initialUrl}) : super(key: key);

  @override
  State<ChatGptScreen> createState() => _InAppBrowserScreenState();
}

class _InAppBrowserScreenState extends State<ChatGptScreen> {
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
            // progress is from 0 to 100
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

              // Redirect after a total of 15 seconds
              _redirectTimer = Timer(const Duration(seconds: 10), () {
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ScreenSignIn()),
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
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Scaffold(
          appBar: buildAppBarWebScreen(
            context,
            size,
            heading: "Numu Chat",
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          body: Column(
            children: [
              if (_progress < 1.0)
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(ColorsContent.newThemeColor),
                ),
              Expanded(
                child: WebViewWidget(controller: _controller),
              ),
            ],
          ),
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
    );
  }
}
