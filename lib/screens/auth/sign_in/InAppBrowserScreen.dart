import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/auth/sign_in/screen_sign_in.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../widgets/app_bar/appbar_leading_image.dart';

class InAppBrowserScreen extends StatefulWidget {
  final Uri initialUrl;
  const InAppBrowserScreen({Key? key, required this.initialUrl}) : super(key: key);

  @override
  State<InAppBrowserScreen> createState() => _InAppBrowserScreenState();
}

class _InAppBrowserScreenState extends State<InAppBrowserScreen> {
  late final WebViewController _controller;
  String? _currentUrl;
  Timer? _redirectTimer;
  bool _showLoadingOverlay = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  /// ✅ Initialize WebView and clear cache before loading
  Future<void> _initializeWebView() async {
    await _clearWebViewCache(); // Clear cache before loading

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
                    MaterialPageRoute(builder: (_) => const ScreenSignIn()),
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

  /// ✅ Clear only WebView cache (no cookies)
  Future<void> _clearWebViewCache() async {
    try {
      final tempController = WebViewController();
      await tempController.clearCache();
      debugPrint("✅ WebView cache cleared");
    } catch (e) {
      debugPrint("⚠️ Error clearing WebView cache: $e");
    }
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: false,
      appBar: buildAppBarWebScreen(
        context,
        MediaQuery.of(context).size,
        heading: "Numu Registration",
        onTap: () => Navigator.of(context).pop(),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (_progress < 1.0)
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(ColorsContent.newThemeColor),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom,
                  ),
                  child: WebViewWidget(controller: _controller),
                ),
              ),
            ],
          ),
          if (_showLoadingOverlay)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CupertinoActivityIndicator(
                    color: Colors.white,
                    radius: 15,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}