import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/dash_borad_screen/dash_board_screen.dart';
import 'package:mentalhelth/screens/subscription_view/subscription_check_screen.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

import '../auth/sign_in/provider/sign_in_provider.dart';

class WebViewScreen extends StatefulWidget {
  final Uri initialUrl;

  const WebViewScreen({super.key, required this.initialUrl});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _hasRedirected = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) async {
            final uri = Uri.parse(url);

            // Check if path ends with "/success"
            if (!_hasRedirected && uri.pathSegments.isNotEmpty && uri.pathSegments.last == 'success') {
              _hasRedirected = true;

              // Optional: wait 5 seconds
              await Future.delayed(const Duration(seconds: 5));

              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const DashBoardScreen()),
                );
              }
            }
          },
        ),
      )
      ..loadRequest(widget.initialUrl);
  }

  @override
  Widget build(BuildContext context) {
    final signInProvider = Provider.of<SignInProvider>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const DashBoardScreen()
            ),
          );
        });
        return false; // prevent default back
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Subscription")),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}
