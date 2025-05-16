import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/auth/sign_in/screen_sign_in.dart';
import 'package:webview_flutter/webview_flutter.dart';

// This widget is a full-screen webview with a Done button.
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

  static const String successUrl = "https://staging4.featureme.live/v1/success";

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(widget.initialUrl)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _currentUrl = url;
            });
            debugPrint("Page started: $url");

            // Cancel any existing timer if user navigates away
            _redirectTimer?.cancel();
          },
          onPageFinished: (url) {
            setState(() {
              _currentUrl = url;
            });
            debugPrint("Page finished: $url");

            if (url == successUrl) {
              // Start 15 seconds timer after success page finished loading
              _redirectTimer = Timer(const Duration(seconds: 5), () {
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ScreenSignIn()),
                  );
                }
              });
            } else {
              // If navigated to some other page, cancel timer
              _redirectTimer?.cancel();
            }
          },
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentUrl ?? 'Loading...'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ScreenSignIn()),
              );
            },
            child: const Text(
              "Done",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}


