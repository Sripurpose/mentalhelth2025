import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mentalhelth/screens/auth/sign_in/screen_sign_in.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/core/image_constant.dart';

class ChatGptBottomSheet extends StatefulWidget {
  final Uri initialUrl;
  final String chatTitle;
  const ChatGptBottomSheet({Key? key, required this.initialUrl,required this.chatTitle}) : super(key: key);

  @override
  State<ChatGptBottomSheet> createState() => _ChatGptBottomSheetState();
}

class _ChatGptBottomSheetState extends State<ChatGptBottomSheet> {
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

              // Close bottom sheet and redirect after 10 seconds
              _redirectTimer = Timer(const Duration(seconds: 10), () {
                if (mounted) {
                  Navigator.pop(context); // Close bottom sheet
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
    return Stack(
      children: [
        Column(
          children: [
            // Header with close button and title
            Container(
              color: Colors.white, // ⬅️ White background for header
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.chatTitle,
                    style: TextStyle(
                      fontSize: 18,
                      color: ColorsContent.newThemeColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      ImageConstant.numuChatClose, // Button icon
                    ),
                  ),
                ],
              ),
            ),

            // Progress indicator
            if (_progress < 1.0)
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  ColorsContent.newThemeColor,
                ),
              ),

            // WebView
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
          ],
        ),

        // Loading overlay
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

